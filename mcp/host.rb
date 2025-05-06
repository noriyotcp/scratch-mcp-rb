require 'dotenv'
require 'anthropic'
require_relative './client'

Dotenv.load

module MCP
  class Host
    attr_reader :client, :anthropic_client

    def initialize(server_file_path:)
      @client = MCP::Client.new(server_file_path: server_file_path)
      @anthropic_client = Anthropic::Client.new(access_token: ENV.fetch('ANTHROPIC_API_KEY', nil), log_errors: true)
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

        puts process_query(input)
      end
    end

    private

    def process_query(query)
      messages = [
        { role: 'user', content: query }
      ]

      response = @client.list_tools
      available_tools = response[:tools].map do |tool|
        {
          name: tool[:name],
          description: tool[:description],
          input_schema: tool[:input_schema]
        }
      end

      response = @anthropic_client.messages(
        parameters: {
          model: 'claude-3-7-sonnet-20250219',
          system: 'Respond only in Japanese.',
          messages: messages,
          max_tokens: 1000,
          tools: available_tools
        }
      )

      if response['content'].empty?
        puts 'No response from server.'
      else
        puts response['content'][0]['text']
      end

      final_text = []
      assistant_message_content = []
      response['content'].each do |content|
        if content['type'] == 'text'
          final_text << content['text']
          assistant_message_content << content
        elsif content['type'] == 'tool_use'
          tool_name = content['name']
          tool_args = content['args']

          result = @client.call_tool(name: tool_name, args: tool_args)
          final_text.push("[Calling tool: #{tool_name} with args: #{tool_args}]")

          assistant_message_content.push(content)
          messages.push(
            { role: 'assistant', content: assistant_message_content }
          )
          messages.push({
            role: 'user',
            content: [
              {
                'type': 'tool_result',
                'tool_use_id': content['id'],
                'content': result.to_s
              }
            ]
          })

          response = @anthropic_client.messages(
            parameters: {
              model: 'claude-3-7-sonnet-20250219',
              max_tokens: 1000,
              messages: messages,
              tools: available_tools
            }
          )

          final_text.push(response['content'][0]['text'])
        end
      end

      final_text.join("\n")
    rescue StandardError => e
      puts "Error processing query: #{e.message}"
    end
  end
end
