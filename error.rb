require_relative 'status'

class Error
  def initialize(message = '', status)
    puts "An Error has occured! #{message}"
    puts "Line: #{status.line}, Index: #{status.index}"
    exit
  end
end
