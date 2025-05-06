module MCP
  class StdioConnection
    def initialize(input = $stdin, output = $stdout)
      @input = input
      @output = output
      @output.sync = true # Ensure output is flushed immediately
    end

    # Reads the next line from the input stream
    # Returns nil if end of input is reached
    def read_next_message
      @input.gets&.chomp
    end

    # Sends a message to the output stream
    # Appends a newline character
    def send_message(message)
      @output.puts(message)
    end
  end
end
