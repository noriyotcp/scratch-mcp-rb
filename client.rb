require 'dotenv'
require 'anthropic'
require 'json'
require 'open3'

Dotenv.load

module MCPClient
  class Client
    attr_reader :connection

    def initialize(server_file_path:)
      @server_file_path = server_file_path
      @connection = Connection.new(server_file_path)
    end

    def connect_to_server
      @connection.initialize_connection
      puts 'Connected to server!'
    rescue StandardError => e
      puts "Error connecting to server: #{e.message}"
      exit(1)
    end

    def chat_loop
      puts 'MCP Client started!'
      puts 'Type "exit" to quit.'

      loop do
        print '> '
        input = $stdin.gets.chomp

        if input.downcase == 'exit'
          puts 'Exiting...'
          break
        end

        process_query(input)
      end
    end

    private

    def process_query(query)
      puts "Processed query: #{query}"
      client = Anthropic::Client.new(access_token: ENV.fetch('ANTHROPIC_API_KEY', nil), log_errors: true)

      response = client.messages(
        parameters: {
          model: 'claude-3-7-sonnet-20250219',
          system: 'Respond only in Japanese.',
          messages: [
            { role: 'user', content: query }
          ],
          max_tokens: 1000
        }
      )

      if response['content'].empty?
        puts 'No response from server.'
      end

      puts response['content'][0]['text']
    end
  end

  class Connection
    attr_reader :stdin, :stdout, :stderr, :wait_thr

    def initialize(server_file_path)
      @stdin, @stdout, @stderr, @wait_thr = Open3.popen3("ruby #{server_file_path}")
    end

    def send_request(request)
      @stdin.puts(JSON.generate(request))
      response = @stdout.gets

      raise 'No response from server' unless response

      result = JSON.parse(response, symbolize_names: true)
      raise "Server error: #{result[:error][:message]} (#{result[:error][:code]})" if result[:error]
      result[:result]
    rescue JSON::ParserError => e
      raise "Invalid JSON response: #{e.message}"
    end

    def send_notification(notification)
      @stdin.puts(JSON.generate(notification))
      @stdin.flush
    end

    # Initialize connection
    # https://modelcontextprotocol.io/specification/2025-03-26/basic/lifecycle
    def initialize_connection
      # Initialize request/initialize response
      response = send_request({
        jsonrpc: '2.0',
        method: 'initialize',
        params: {
          protocolVersion: '2024-11-05',
          capabilities: {
            roots: {
              listChanged: true,
            },
            sampling: {}
          },
          clientInfo: {
            name: 'MCP Client',
            version: '1.0.0',
          }
        },
        id: 1
      })

      # initialized notification
      send_notification({
        jsonrpc: '2.0',
        method: 'notifications/initialized'
      })

      response
    end
  end
end

def main
  file_path = ARGV[0]

  if file_path.nil? || !File.exist?(file_path)
    puts 'Please provide a server file path.'
    exit
  end

  client = MCPClient::Client.new(server_file_path: file_path)
  client.connect_to_server
  client.chat_loop
end

main
