require_relative '../server'
require_relative '../tools/dice'
require_relative '../tools/timer'

module MCP
  class MainServer
    def initialize
      @server = MCP::Server.new

      # ツールクラスのインスタンスを生成
      @dice_tool = MCP::Tools::Dice.new
      @timer_tool = MCP::Tools::Timer.new
    end

    def register_all_tools
      # 各ツールを登録 - インスタンスからツール定義を取得
      register_tools(@dice_tool.tools)
      register_tools(@timer_tool.tools)

      # 将来的に他のツールも追加
    end

    def register_tools(tools)
      tools = [tools] unless tools.is_a?(Array)
      tools.each do |tool|
        @server.register_tool(
          name: tool[:name],
          description: tool[:description],
          input_schema: tool[:input_schema],
          handler: tool[:handler]
        )
      end
    end

    def run
      register_all_tools
      @server.run
    end
  end
end

# サーバーの実行
if __FILE__ == $PROGRAM_NAME
  server = MCP::MainServer.new
  server.run
end
