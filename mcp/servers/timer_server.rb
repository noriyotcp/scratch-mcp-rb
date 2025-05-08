require_relative '../server'
require_relative '../tools/timer'

server = MCP::Server.new

timer_tools = MCP::Tools::Timer.new.tools
timer_tools = [timer_tools] unless timer_tools.is_a?(Array)

timer_tools.each do |tool|
  server.register_tool(
    name: tool[:name],
    description: tool[:description],
    input_schema: tool[:input_schema],
    handler: tool[:handler]
  )
end

# サーバー実行
server.run
