#!/usr/bin/env sh
# POSIX sh compatible
# Probes three modes:
#  1) SSE full URL (BASE + ssePath)
#  2) SSE base+paths message endpoint (BASE + messagePath)
#  3) Streamable HTTP endpoint (BASE + httpPath)
#
# Usage:
#   ./detect_mcp_transport_v4.sh https://xh-mcp-by-ray.codecrates.xyz \
#     --ssePath /mcp/sse \
#     --messagePath /mcp/message \
#     --httpPath /mcp \
#     --auth "Authorization: Bearer <TOKEN>" \
#     --header "X-My-Header: another-header-value"

set -eu

BASE_URL="${1:-}"
[ -n "${BASE_URL}" ] || { echo "ERROR: Provide base URL (e.g., https://xh-mcp-by-ray.cloudhub.io)"; exit 2; }
shift || true

SSE_PATH="/sse"
MSG_PATH="/message"
HTTP_PATH="/"
AUTH_HEADER=""
EXTRA_HEADERS=""

while [ $# -gt 0 ]; do
  case "$1" in
    --ssePath)     SSE_PATH="${2:?}"; shift 2 ;;
    --messagePath) MSG_PATH="${2:?}"; shift 2 ;;
    --httpPath)    HTTP_PATH="${2:?}"; shift 2 ;;
    --auth)        AUTH_HEADER="${2:?}"; shift 2 ;;
    --header)      EXTRA_HEADERS="${EXTRA_HEADERS}
$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

# Build a curl config file for headers (safe quoting)
CURL_CFG="$(mktemp 2>/dev/null || printf '/tmp/curlcfg.%s' "$$")"
trap 'rm -f "$CURL_CFG"' EXIT

if [ -n "$AUTH_HEADER" ]; then
  printf 'header = "%s"\n' "$AUTH_HEADER" >> "$CURL_CFG"
fi
printf '%s\n' "$EXTRA_HEADERS" | while IFS= read -r H; do
  [ -n "$H" ] || continue
  printf 'header = "%s"\n' "$H" >> "$CURL_CFG"
done

FULL_SSE_URL="${BASE_URL%/}${SSE_PATH}"
MSG_URL="${BASE_URL%/}${MSG_PATH}"
HTTP_URL="${BASE_URL%/}${HTTP_PATH}"

probe_sse() {
  echo "→ Probing FULL SSE URL: $FULL_SSE_URL"
  RESP_HEADERS="$(curl -sS -D - -o /dev/null --connect-timeout 5 --max-time 5 \
    -H 'Accept: text/event-stream' \
    -K "$CURL_CFG" \
    "$FULL_SSE_URL" || true)"
  STATUS_LINE="$(printf '%s\n' "$RESP_HEADERS" | head -n 1)"
  CT_LINE="$(printf '%s\n' "$RESP_HEADERS" | awk 'BEGIN{IGNORECASE=1} /^Content-Type:/{print; exit}')"

  echo "$STATUS_LINE" | grep -qE 'HTTP/[0-9.]+\s+200' || { echo "ℹ️ SSE: not 200"; return 1; }
  echo "$CT_LINE"    | grep -qi 'text/event-stream'     || { echo "ℹ️ SSE: Content-Type not event-stream"; return 1; }

  echo "✅ SSE endpoint OK (200 + text/event-stream)."
  return 0
}

probe_message() {
  echo "→ Probing MESSAGE endpoint: $MSG_URL"
  RESP="$(curl -sS -i --connect-timeout 5 --max-time 5 \
    -H 'Content-Type: application/json' \
    -K "$CURL_CFG" \
    -X POST "$MSG_URL" \
    -d '{"jsonrpc":"2.0","id":1,"method":"ping","params":{}}' || true)"

  STATUS_LINE="$(printf '%s\n' "$RESP" | head -n 1)"
  BODY="$(printf '%s\n' "$RESP" | awk 'f{print} /^(\r)?$/{f=1}')"

  echo "$STATUS_LINE" | grep -qE 'HTTP/[0-9.]+\s+200' || { echo "ℹ️ Message: not 200"; return 1; }
  printf '%s' "$BODY" | grep -q '"jsonrpc"' || { echo "ℹ️ Message: body not JSON-RPC looking"; return 1; }

  echo "✅ Message endpoint OK (200 + JSON-RPC-ish)."
  return 0
}

probe_http() {
  echo "→ Probing STREAMABLE HTTP endpoint: $HTTP_URL"
  RESP="$(curl -sS -i --connect-timeout 5 --max-time 5 \
    -H 'Content-Type: application/json' \
    -K "$CURL_CFG" \
    -X POST "$HTTP_URL" \
    -d '{"jsonrpc":"2.0","id":1,"method":"ping","params":{}}' || true)"

  STATUS_LINE="$(printf '%s\n' "$RESP" | head -n 1)"
  BODY="$(printf '%s\n' "$RESP" | awk 'f{print} /^(\r)?$/{f=1}')"

  echo "$STATUS_LINE" | grep -qE 'HTTP/[0-9.]+\s+200' || { echo "ℹ️ HTTP: not 200"; return 1; }
  printf '%s' "$BODY" | grep -q '"jsonrpc"' || { echo "ℹ️ HTTP: body not JSON-RPC looking"; return 1; }

  echo "✅ Streamable HTTP endpoint OK (200 + JSON-RPC-ish)."
  return 0
}

SSE_OK=false
MSG_OK=false
HTTP_OK=false

if probe_sse; then SSE_OK=true; fi
if probe_message; then MSG_OK=true; fi
if probe_http; then HTTP_OK=true; fi

echo
echo "================ Decision ================"

if $SSE_OK && $MSG_OK && ! $HTTP_OK; then
cat <<JSON
Use SSE (Base URL + paths). Paste into claude_desktop_config.json:

{
  "mcpServers": {
    "my-mulesoft-mcp": {
      "command": "npx",
      "args": [
        "-y",
        "supergateway",
        "--sse", "${BASE_URL%/}",
        "--ssePath", "${SSE_PATH}",
        "--messagePath", "${MSG_PATH}"
      ]
    }
  }
}
JSON

elif $SSE_OK && ! $MSG_OK && ! $HTTP_OK; then
cat <<JSON
Use SSE (Full URL). Paste into claude_desktop_config.json:

{
  "mcpServers": {
    "my-mulesoft-mcp": {
      "command": "npx",
      "args": [
        "-y",
        "supergateway",
        "--sse",
        "${FULL_SSE_URL}"
      ]
    }
  }
}
JSON

elif ! $SSE_OK && ! $MSG_OK && $HTTP_OK; then
cat <<JSON
Use Streamable HTTP. Paste into claude_desktop_config.json:

{
  "mcpServers": {
    "my-mulesoft-mcp": {
      "command": "npx",
      "args": [
        "-y",
        "supergateway",
        "--streamableHttp",
        "${HTTP_URL}"
      ]
    }
  }
}
JSON

elif $SSE_OK && $HTTP_OK; then
cat <<JSON
Both SSE and Streamable HTTP are available.
Default to SSE for persistent sessions, or Streamable HTTP if your infra/load balancer dislikes long-lived connections.

SSE (Full URL) example:
{
  "mcpServers": {
    "my-mulesoft-mcp": {
      "command": "npx",
      "args": ["-y","supergateway","--sse","${FULL_SSE_URL}"]
    }
  }
}

Streamable HTTP example:
{
  "mcpServers": {
    "my-mulesoft-mcp": {
      "command": "npx",
      "args": ["-y","supergateway","--streamableHttp","${HTTP_URL}"]
    }
  }
}
JSON

else
cat <<'TXT'
Neither mode clearly succeeded.
• Verify paths and auth
• Try: curl -i <base-url>
• Confirm SSE path returns Content-Type: text/event-stream
• Confirm HTTP path accepts POST JSON-RPC at /mcp (or your configured --httpPath)
TXT
fi

echo "=========================================="