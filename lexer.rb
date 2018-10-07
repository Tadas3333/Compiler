

class Lexer

  def initialize(file_name)
    @file_name = file_name
  end

  def start
    unless File.file?(@file_name)
      puts "File '#{@file_name}' doesn't exist!"
      return false
    end

    lines = File.readlines(@file_name)
    @line_id = 1
    @printed_count = 0
    @last_type = :TABLE
    print_line

    # Iterate through all lines in a file
    lines.each do |line|
      @last_type = :EMPTY
      @current_line = line.strip

      @index = 0
      # Iterate through every symbol in a line
      while @last_type != :END_OF_LINE && @last_type != :ERROR
        scan
        @index += 1
      end

      return false if @last_type == :ERROR

      @line_id += 1
    end

    unless lines.empty?
      @last_type = :EOF
      print_line
    else
      puts "File '#{@file_name}' is empty!"
    end

    true
  end

  def scan(peek = false)
    @index += 1 if peek
    return @last_type = :END_OF_LINE if @index >= @current_line.length

    char = @current_line[@index]
    #puts "CURRENT CHARACTER: #{char}"
    case char
    when '0'..'9'

      unless peek
        # Clear buffer if last character was not :LIT_INT
        if @last_type != :LIT_INT
          @buffer = []
        end

        # Add character to buffer
        @buffer.push(char)

        # Print buffer if next character is not :LIT_INT
        if scan(true) != :LIT_INT
          @last_type = :LIT_INT
          print_line
        end

      else
        @last_type = :LIT_INT
      end

    when 'a'..'z', 'A'..'Z'

      unless peek
        # Clear buffer if last character was not :LIT_STR
        if @last_type != :LIT_STR
          @buffer = []
        end

        # Add character to buffer
        @buffer.push(char)

        # Print buffer if next character is not :LIT_STR
        if scan(true) != :LIT_STR
          @last_type = :LIT_STR
          print_line
        end

      else
        @last_type = :LIT_STR
      end

    when '+'
      @last_type = :OP_PLUS
      print_line unless peek
    when '-'
      @last_type = :OP_MINUS
      print_line unless peek
    when '*'
      @last_type = :OP_MULTIPLY
      print_line unless peek
    when '/'
      @last_type = :OP_SUBTRACT
      print_line unless peek
    when '>'
      unless peek
        # Check if not >=
        if scan(true) != :OP_E
          @last_type = :OP_G
          print_line
        else
          @last_type = :OP_GE
          print_line

          # Skip '=' symbol
          @index += 1
        end
      else
        @last_type = :OP_G
      end
    when '<'
      unless peek
        # Check if not <=
        if scan(true) != :OP_E
          @last_type = :OP_L
          print_line
        else
          @last_type = :OP_LE
          print_line

          # Skip '=' symbol
          @index += 1
        end
      else
        @last_type = :OP_L
      end
    when '='
      unless peek
        # Check if not ==
        if scan(true) != :OP_E
          @last_type = :OP_E
          print_line
        else
          @last_type = :OP_DE
          print_line

          # Skip '=' symbol
          @index += 1
        end
      else
        @last_type = :OP_E
      end
    when '!'
      unless peek
        # Check if not !=
        if scan(true) != :OP_E
          @last_type = :OP_N
          print_line
        else
          @last_type = :OP_NE
          print_line

          # Skip '=' symbol
          @index += 1
        end
      else
        @last_type = :OP_N
      end
    when ' '
      @last_type = :EMPTY
    else
      @last_type = :ERROR
      print_line unless peek
    end

    @index -= 1 if peek
    @last_type
  end

  def print_line
    case @last_type
    when :LIT_INT, :LIT_STR
      print_formated_line(@last_type,@buffer.join)
    when :OP_PLUS, :OP_MINUS, :OP_MULTIPLY, :OP_SUBTRACT
      print_formated_line(@last_type, '')
    when :EOF, :OP_E, :OP_DE, :OP_G, :OP_L, :OP_GE, :OP_LE, :OP_N, :OP_NE
      print_formated_line("#{@last_type}\t", '')
    when :TABLE
      puts "ID\t|LN\t|TYPE\t\t|VALUE"
      puts "----------------------------------------"
    when :ERROR
      puts "Error! File: #{@file_name} Line: #{@line_id} Unknown Symbol: #{@current_line[@index]}"
    else
      puts "Unknown @last_type!"
    end
  end

  def print_formated_line(type, value)
    puts "#{@printed_count}\t|#{@line_id}\t|#{type}\t|#{value}"
    @printed_count += 1
  end
end

lex = Lexer.new('lexer_input.txt')
lex.start
