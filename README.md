# How To Implement a MuleSoft MCP listener tool?
## Demystify MuleSoft MCP Demo
- The application will demo the MuleSoft MCP Connector Beta.
## Scenarios/Use Case:
### Scenario 1:
- As a MuleSoft Designer/Developer/Architect, I want to check the Assets my team created in the Design Center without signing in to Anypoint Platform, navigating to Design Center. I want to use an MCP Client like Claude, Cursor or any available tool that can communicate to a MCP server.
### Scenario 2:
- As a MuleSoft Architect, I want to check if I have an API Governance Profile create and ready to use without signing in to Anypoint Platform.
### Scenario 2:
- As a MuleSoft Architect, I want to check if any of the API published in the exchange have an API Governance applied and conformant. I want to use an MCP client instead of going through the process of signing in to Anypoint Platform, navigating to API Exchange and API Governance and verify. I want it simple.
----
# Let's Begin...
### Step 1
- Lets create a Connected App. Login to Anypoint Platform -> Access Management -> Connected AppIf you already have an available Connected App in the Anypoint Platform, jump to step x)
### Step 2
- Create an App and name it reference to MCP demo (ie: my-1st-mcp-client-app) and save the Client_ID and Client_Secret
### Step 3
- Add the following scope
### Step 4
- Change the value for client_id and client_secret in the app.yaml
### Step 5
- Lets run the app. Make sure your runtime version is 4.3 or above
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
- Open the claude_dekstop_config.json to any text editor
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
- Lets test the MuleSoft MCP Server and MCP Client (ie: Cursor, Claude) by testing the scenario listed at the beginning of this exercise:
### Scenario 1:
- Ask Claude or Cursor the following:
  - `Check how many APIs are in my Design Center.`
### Scenario 2:
- Ask Claude or Cursor to verify if there's an existing API Governance:
  - `Do I have Governance Profile created?`
### Scenario 3:
- Ask Claude or Cursor to check if are there any API that use the API Governance Profile
  - `List the APIs attached to that profile.`
