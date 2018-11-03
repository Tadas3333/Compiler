require_relative 'charprocessor'
require_relative '../status'

class Lexer
  def initialize(file_name, show = false)
    @file_name = file_name
    @show = show
  end

  def get_tokens
    @tokens = []

    # Check if file exists
    unless File.file?(@file_name)
      puts "File '#{@file_name}' doesn't exist!"
      @tokens
    end

    # Read a file
    status = Status.new(@file_name)
    processor = CharProcessor.new(@tokens, status, @show)
    last_char = :NON

    File.open(@file_name,'r').each_char do |char|
      if last_char == :NON
        last_char = char
      elsif processor.skip_next == true
        processor.skip_next = false
        last_char = char
      else
        processor.process(last_char, char)
        last_char = char
      end
    end

    processor.finish(last_char)
    @tokens
  end
end
