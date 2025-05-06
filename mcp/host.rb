require 'dotenv'
require 'anthropic'
require_relative './client'

Dotenv.load

module MCP
  class Host
    attr_reader :client

    def initialize(server_file_path:)
      @client = MCP::Client.new(server_file_path: server_file_path)
    end

    def connect_to_server
      @client.initialize_connection
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
      # 通常のクエリ処理
      puts "Processing query: #{query}"
      begin
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
        else
          puts response['content'][0]['text']
        end
      rescue StandardError => e
        puts "Error processing query: #{e.message}"
      end
    end
  end
end
