# ✨ MuleSoft MCP Made Simple by Ray

Unlock the power of MuleSoft’s Anypoint Platform with **MCP**, a complete guide and toolkit for building Model‑Context‑Protocol (MCP) servers integrated with MuleSoft APIs. Make your AI smarter by letting it access live data, take action and elevate integration workflows.

---
## ✅ What Makes This So Cool?

- **Empower AI Agents**: Give your LLMs real-time access to Anypoint Platform—no more guesswork or stale info.  
- **Seamless API Interactions**: Define tools that can fetch, modify and manage your APIs using natural language.  
- **Effortless Setup**: Full working templates and examples to get you started—no copy-paste frustration!

---
## Demystify MuleSoft MCP Demo Overview

While this repository provides a comprehensive and robust MCP client to interact with any compliant MCP server, it's important to understand how MuleSoft itself facilitates the exposure of its applications and APIs as MCP servers.

MuleSoft is actively developing and enhancing its capabilities for the Model Context Protocol. Central to this is the [MuleSoft MCP Connector](https://docs.mulesoft.com/mcp-connector/latest/). This connector allows MuleSoft developers to easily expose Anypoint Platform assets (like APIs, integrations and even entire Mule applications) as MCP-compliant services. This enables AI agents and other MCP clients to discover, understand and interact with your MuleSoft deployments in a standardized way.

For the most up-to-date information and to learn how to configure your MuleSoft applications as MCP servers, please refer to the official MuleSoft documentation for the [MuleSoft MCP Connector](https://docs.mulesoft.com/mcp-connector/latest/). This official connector is the foundation upon which your MuleSoft MCP server implementation will be built, making it the ideal counterpart for the client provided in this repository.

---
## 🚀 Cool Things You Can Do with This

1. **See Your APIs in Action**  
   Easily pull live info from Anypoint Platform like what APIs exist and how they’re built.

2. **Pre-Built Tools That Just Work**  
   Use ready-made features (like "get my projects" or "build me a RAML") without writing code from scratch.

3. **Works the Way You Want**  
   Choose how your tools talk—via real-time streams (SSE) or regular HTTP. It’s flexible.

4. **Start Simple, Learn Fast**  
   Comes with a small example (a calculator!) so you can get hands-on and understand how everything works before going big.

---
## Objective:
Automating multi-step business processes through natural language commands to a MuleSoft-powered MCP Server.

## 🔨 What You’ll Build

- An MCP server ready to fetch, query, and create Design Center assets.  
- AI-driven workflows that let you *talk* to your Anypoint Platform—no manual dev required.

---
## 👥 Who Is This For?

- **MuleSoft Developers** wanting AI-integrated API workflows.  
- **AI Engineers** building agents that live inside enterprise environments.  
- **Architects** looking for smarter, interactive API experience with minimal effort.

## Prereq:
- As of **2025-06-05**:
  - Mule Runtime Version **4.9.3** or above
  - Java version **17**
  
## Scenarios/Use Case:
### Scenario 1:
- As a MuleSoft Designer/Developer/Architect, I want to check the Assets my team created in the Design Center without signing in to Anypoint Platform, navigating to Design Center. I want to use an MCP Client like Claude or any available tool that can communicate to a MCP server.
### Scenario 2:
- As a MuleSoft Architect, I want to check if I have an API Governance Profile create and ready to use without signing in to Anypoint Platform.
### Scenario 2:
- As a MuleSoft Architect, I want to check if any of the API published in the exchange have an API Governance applied and conformant. I want to use an MCP client instead of going through the process of signing in to Anypoint Platform, navigating to API Exchange and API Governance and verify. I want it simple.
----
# Let's Begin...
### Step 1
- Lets create a Connected App. Login to Anypoint Platform -> Access Management -> Connected App. (If you already have an available Connected App in the Anypoint Platform, proceed to step 3)
### Step 2
- Create an App and name it reference to MCP demo (ie: my-1st-mcp-client-app) and save the Client_ID and Client_Secret
### Step 3
- Add the following scope
  - API Governance
    - Governance Administrator
  - Design Center
    - Design Center Creator
    - Design Center Developer
    - Design Center Viewer
  - Exchange
    - Exchange Administrator
    - Exchange Contributor
    - Exchange Creator
    - Exchange Viewer
### Step 4
- Change the value for client_id and client_secret in the app.yaml
### Step 5
- Lets run the app. Make sure your runtime version is **4.9.3** or above and Java version is **17**
- Right Click on the Project - Select Run As - Select Mule Application (configure)
- Click Arguments tab
- Add the `-Dmule.http.service.implementation=NETTY` to VM Arguments
- Click Run
----
# What's Next? Lets configure the MCP Client (ie: Claude)
### Step 1
- Open Claude application -> Go to Claude Settings
### Step 2
- Click Developer from the right selection -> Click Edit Config and it will open a Finder or Windows Explorer
### Step 3
- Open the **_claude_dekstop_config.json_** file to any text editor
### Step 4
- Add the folowing config (**_Only use one configuration either Localhost or CloudHub_**). Make sure the Mule App is running.

  - **For Localhost App:**
  ```yaml
  {
      "mcpServers": {
        "xh-demystify-mulesoft-mcp": {
          "command": "npx",
          "args": [ 
             "-y", "supergateway", "--sse",
             "http://localhost:8081/sse", "--ssePath", 
             "/sse", "--messagePath","/message"
          ]
        }
      }
  }
  ```
  - **For CloudHub App:**
  ```yaml
  {
      "mcpServers": {
        "xh-demystify-mulesoft-mcp": {
          "command": "npx",
          "args": [ 
             "-y", "supergateway", "--sse", 
             "https://<REPLACE_WITH_YOUR_CLOUDHUB_URL>/sse", "--ssePath", 
             "/sse", "--messagePath","/message"
          ]
        }
      }
  }
  ```
### Step 5
- Let's restart the Claude App and make sure the Mule App is running (ie: Localhost or CloudHub).
----
# Now what? Test MuleSoft MCP Server and MCP Client?
- Lets test the MuleSoft MCP Server and MCP Client (ie: Claude) by testing the scenario listed at the beginning of this exercise:
### Scenario 1:
- Ask Claude with the following:
  - `Check how many APIs are in my Design Center.`
### Scenario 2:
- Ask Claude to verify if there's an existing API Governance:
  - `Do I have Governance Profile created?`
### Scenario 3:
- Ask Claude to check if are there any API that use the API Governance Profile
  - `List the APIs attached to that profile.`
# There you go!
### Expand what you have learned and share. Sharing of knowledge is power!
- By Ray

## What If I Encountered An Error in Claude?
- Open the **Claude Settings**
- Click the **Developer** and if the status is **Failed**, click the **OpenLogFolder**
- Open the file `mcp-server-xh-demystify-mulesoft-mcp.log` and check if you see a suggestion like `sudo chown -R 502:20 "/Users...`

