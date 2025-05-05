def process_query(query)
  puts "Processed query: #{query}"
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
