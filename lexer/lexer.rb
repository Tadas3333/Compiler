require_relative 'charprocessor'

class Lexer
  def initialize(file_name)
    @file_name = file_name
  end

  def get_tokens
    @tokens = []

    # Check if file exists
    unless File.file?(@file_name)
      puts "File '#{@file_name}' doesn't exist!"
      @tokens
    end

    # Read a file
    processor = CharProcessor.new(@tokens)
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
