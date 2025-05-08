# Scratch MCP

It's based on [YuheiNakasaka's scratch-mcp-rb](https://github.com/YuheiNakasaka/scratch-mcp-rb/tree/main)

---

Almost scratch MCP Host/Client/Server in Ruby

- [MCP Specification](https://modelcontextprotocol.io/specification/2025-03-26)
- [MCP Client](https://modelcontextprotocol.io/quickstart/client)
- [MCP Server](https://modelcontextprotocol.io/quickstart/server)
- [MCP Schema](https://github.com/modelcontextprotocol/modelcontextprotocol/blob/3ba3181c7779da74b24f0c083eb7055b6fc9d928/schema/2025-03-26/schema.ts)

# Usage

0. Set up environment:

```bash
cp .env.example .env
```

1. Install dependencies:

```bash
bundle install
```

2. Run:

```bash
# Start the main MCP server
ruby main.rb
# Start the specific MCP server
ruby main.rb mcp/servers/dice_server.rb
ruby main.rb mcp/servers/timer_server.rb
```

# Current implementation

- Transports
  - stdio only
- MCP Servers
  - the dice server(`mcp/servers/dice_server.rb`)
  - the timer server(`mcp/servers/timer_server.rb`)
  - the main MCP server(`mcp/servers/main_server.rb`)

# Supported MCP Protocol
- Initialization
  - initialize request
  - initialize response
  - initialized notification
- Ping
- Operation
  - Tools
    - Protocol Messages
      - listing tools
      - calling tools
    - Tool Result
      - text content only
- Shutdown
