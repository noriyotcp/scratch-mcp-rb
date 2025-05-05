require 'dotenv'
require 'anthropic'

Dotenv.load

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

  pust response['content'][0]['text']
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

file_path = ARGV[0]

if file_path.nil? || !File.exist?(file_path)
  puts 'Please provide a server file path.'
  exit
end

chat_loop
