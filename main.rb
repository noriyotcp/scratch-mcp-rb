require_relative 'mcp/host'

def main
  file_path = ARGV[0] || 'mcp/servers/main_server.rb'

  if file_path.nil? || !File.exist?(file_path)
    puts 'Please provide a server file path.'
    exit
  end

  host = MCP::Host.new(server_file_path: file_path)
  host.connect_to_server
  host.chat_loop
ensure
  host&.client&.close
end

main if $PROGRAM_NAME == __FILE__
