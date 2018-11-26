require_relative 'status'

class Error
  def initialize(message = '', status)
    puts "#{status.file_name}:#{status.line}: error: #{message}"
    exit
  end
end

class NoExitError
  def initialize(message = '', status)
    puts "#{status.file_name}:#{status.line}: error: #{message}"
    $error_found = true
  end
end
