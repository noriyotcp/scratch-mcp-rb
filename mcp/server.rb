require 'json'
require_relative 'stdio_connection'
require_relative 'logger'

module MCP
  class Server
    attr_reader :initialized, :tools

    def initialize
      @connection = StdioConnection.new
      @initialized = false
      @logger = Logger.new('tmp/mcp.log')
      @tools ||= {}
    end

    def run
      loop do
        next_message = @connection.read_next_message
        if next_message.nil?
          puts 'Connection closed.'
          break
        end

        response = process_message(next_message)
        next if response.nil?

        @connection.send_message(JSON.generate(response))
      end
    end

    def register_tool(name:, description:, input_schema:)
      @tools[name] = {
        name: name,
        description: description,
        input_schema: input_schema
      }
    end

    private

    def allowed_methods
      %w[
        initialize
        notifications/initialized
        ping
        tools/list
      ]
    end

    def process_message(message)
      request = JSON.parse(message, symbolize_names: true)

      if !@initialized && !allowed_methods.include?(request[:method])
        raise "Method not allowed: #{request[:method]}"
      end

      case request[:method]
      when 'initialize'
        @logger.info('RPC: initialize')
        {
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
        }
      when 'notifications/initialized'
        @logger.info('RPC: notifications/initialized')
        @initialized = true
        nil
      when 'ping'
        @logger.info('RPC: ping')
        {
          jsonrpc: '2.0',
          id: request[:id],
          result: 'pong'
        }
      when 'tools/list'
        @logger.info('RPC: tools/list')
        tools = @tools.map do |name, tool|
          {
            name:,
            description: tool[:description],
            input_schema: tool[:input_schema],
          }
        end
        {
          jsonrpc: '2.0',
          id: request[:id],
          result: {
            tools: tools
          }
        }
      end
    end
  end
end
