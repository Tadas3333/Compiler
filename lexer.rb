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
      return @tokens
    end

    # Read a file
    processor = CharProcessor.new(@tokens)
    File.open(@file_name,'r').each_char do |char|
      unless processor.process(char)
        break
      end
    end
    processor.process(:EOF)
    @tokens
  end
end

lx = Lexer.new('lexer_input_3.txt')
tokens = lx.get_tokens
