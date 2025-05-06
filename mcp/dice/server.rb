require_relative '../server'

server = MCP::Server.new

# Diceツールの登録
server.register_tool(
  name: 'dice',
  description: 'Roll a dice with the specified number of sides',
  input_schema: {
    type: 'object',
    properties: {
      sides: {
        type: 'integer',
        description: 'Number of sides on the dice',
        default: 6
      }
    },
    required: ['sides']
  }
)

# サーバー実行
server.run
