require_relative 'mcp/host'

def main
  file_path = ARGV[0]

  if file_path.nil? || !File.exist?(file_path)
    puts 'Please provide a server file path.'
    exit
  end

  host = MCP::Host.new(server_file_path: file_path)
  host.connect_to_server
  host.chat_loop
end

main if $PROGRAM_NAME == __FILE__
