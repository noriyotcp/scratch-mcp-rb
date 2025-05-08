require_relative '../server'
require_relative '../tools/dice'

server = MCP::Server.new

dice_tools = MCP::Tools::Dice.new.tools
dice_tools = [dice_tools] unless dice_tools.is_a?(Array)

dice_tools.each do |tool|
  server.register_tool(
    name: tool[:name],
    description: tool[:description],
    input_schema: tool[:input_schema],
    handler: tool[:handler]
  )
end

# サーバー実行
server.run
