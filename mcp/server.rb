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

    def register_tool(name:, description:, input_schema:, handler:)
      @tools[name] = {
        name: name,
        description: description,
        input_schema: input_schema,
        handler: handler
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

      raise "Method not allowed: #{request[:method]}" if !@initialized && !allowed_methods.include?(request[:method])

      case request[:method]
      when 'initialize'
        @logger.info('RPC: initialize')
        {
          jsonrpc: '2.0',
          id: 1,
          result: {
            protocolVersion: '2025-03-26',
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
            input_schema: tool[:input_schema]
          }
        end
        {
          jsonrpc: '2.0',
          id: request[:id],
          result: {
            tools: tools
          }
        }
      when 'tools/call'
        @logger.info('RPC: tools/call')
        tool_name = request[:params][:name]
        tool_args = request[:params][:args]
        tool = @tools[tool_name]

        raise "Tool not found: #{tool_name}" if tool.nil?

        result = tool[:handler].call(tool_args)
        {
          jsonrpc: '2.0',
          id: request[:id],
          result: {
            content: result
          }
        }
      end
    end
  end
end
