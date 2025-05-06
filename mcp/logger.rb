require 'fileutils'

module MCP
  class Logger
    def initialize(log_file_path)
      FileUtils.mkdir_p(File.dirname(log_file_path))
      @log_file = File.open(log_file_path, 'a')
    end

    def info(message)
      @log_file.puts(message)
    end
  end
end
