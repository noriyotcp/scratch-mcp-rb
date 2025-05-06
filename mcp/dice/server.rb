require 'json'

module MCP
  module Dice
    class Server
      def initialize(stdin, stdout)
        @stdin = stdin
        @stdout = stdout
      end

      def process_message(message)
        request = JSON.parse(message, symbolize_names: true)

        case request[:method]
        when 'initialize'
          JSON.generate({
            jsonrpc: '2.0',
            id: 1,
            result: {
              protocolVersion: '2024-11-05',
              capabilities: {
                logging: {},
                prompts: {
                  listChanged: true
                },
                resources: {
                  subscribe: true,
                  listChanged: true
                },
                tools: {
                  listChanged: true
                }
              },
              serverInfo: {
                name: 'MCP Client',
                version: '1.0.0'
              },
              instructions: 'Optional instructions for the client'
            }
          })
        when 'notifications/initialized'
          nil
        end
      end
    end
  end
end
