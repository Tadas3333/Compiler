
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
      @reading_string = false
      @reading_float = false
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

    if @index >= @current_line.length
      if @reading_string
        @last_type = :ERROR
        print_line
        puts "Error Message: No comma to end string"
        return @last_type
      end

      return @last_type = :END_OF_LINE
    end

    char = @current_line[@index]
    @last_read_char = char
    #puts "CURRENT CHARACTER: #{char}" unless peek
    case char
    when '"'
      unless peek
        unless @reading_string
          # If string read mode is off
          @reading_string = true
          @string_open_symbol = :SYM_DCOM
          @buffer = []
          @last_type = :SYM_DCOM
        else
          # If string read mode is on
          if @string_open_symbol == :SYM_DCOM
            # Same open and close symbols, check if no escape symbol before
            if @last_type == :SYM_ESC
              @buffer.push(char)
              @last_type = :LIT_STR
            else
              @reading_string = false
              @last_type = :LIT_STR
              print_line
            end
          else
            # String read mode was started with single comma
            @buffer.push(char)
            @last_type = :LIT_STR
          end
        end
      else
        @last_type = :SYM_DCOM
      end
    when "'"
      unless peek
        unless @reading_string
          # If string read mode is off
          @reading_string = true
          @string_open_symbol = :SYM_SCOM
          @buffer = []
          @last_type = :SYM_SCOM
        else
          # If string read mode is on
          if @string_open_symbol == :SYM_SCOM
            # Same open and close symbols, check if no escape symbol before
            if @last_type == :SYM_ESC
              @buffer.push(char)
              @last_type = :LIT_STR
            else
              @reading_string = false
              @last_type = :LIT_STR
              print_line
            end
          else
            # String read mode was started with double comma
            @buffer.push(char)
            @last_type = :LIT_STR
          end
        end
      else
        @last_type = :SYM_SCOM
      end
    when '\\'
      unless peek
        # If reading string, then check if we are trying to escape char
        if @reading_string
          origin_last_type = @last_type
          res = scan(true)
          @last_type = origin_last_type
          # Check if next character after escape symbol is escapeable
          if (res == :SYM_ESC || res == :SYM_SCOM || res == :SYM_DCOM ||
             (res == :IDENT && (@last_read_char == 'n' || @last_read_char == 'r'))) && @last_type != :SYM_ESC
            @last_type = :SYM_ESC
          else
            if @last_type == :SYM_ESC
              @last_type = :LIT_STR
              @buffer.push(char)
            else
              @last_type = :ERROR
              print_line
              puts "Error Message: Escape symbol isn't escaping symbol"
            end
          end
        else
          # Just escape symbol
          @last_type = :SYM_ESC
          print_line
        end
      else
        @last_type = :SYM_ESC
      end
    when '/'
      unless peek
        if @reading_string
          @buffer.push(char)
          @last_type = :LIT_STR
        else
          # Check if we are trying to commment
          if scan(true) == :OP_DIVIDE
            @index = @current_line.length
            @last_type = :OP_DIVIDE
          else
            @last_type = :OP_DIVIDE
            print_line
          end
        end
      else
        @last_type = :OP_DIVIDE
      end
    when '0'..'9'
      unless peek
        if @reading_string
          @buffer.push(char)
          @last_type = :LIT_STR
        else
          # Clear buffer if last character was not :LIT_INT and not :LIT_FLOAT
          if @last_type != :LIT_INT && !@reading_float
            @buffer = []
          end

          # Add character to buffer
          @buffer.push(char)

          # Check if we are done reading int/float
          next_type = scan(true)
          if next_type == :LIT_INT
            # We are not done reading this number
            @last_type = :LIT_INT
          elsif next_type == :SYM_DOT
            if @reading_float
              # Another float detected, end current one
              @last_type = :LIT_FLOAT
              print_line
              @reading_float = false
            else
              # This number is part of float, don't print anything yet
              @last_type = :LIT_INT
            end
          else
            # Finished reading int/float
            if @reading_float
              @last_type = :LIT_FLOAT
              print_line
              @reading_float = false
            else
              @last_type = :LIT_INT
              print_line
            end
          end
        end
      else
        @last_type = :LIT_INT
      end
    when 'a'..'z', 'A'..'Z'
      unless peek
        if @reading_string
          if (char == 'n' || char == 'r') && @last_type == :SYM_ESC
            @buffer.push('\\')
          end

          @buffer.push(char)
          @last_type = :LIT_STR
        else
          # Clear buffer if last character was not :IDENT
          if @last_type != :IDENT
            @buffer = []
          end

          # Add character to buffer
          @buffer.push(char)

          # Print buffer if next character is not :IDENT
          if scan(true) != :IDENT
            if !scan_keyword
              @last_type = :IDENT
              print_line
            end
          end
        end

      else
        @last_type = :IDENT
      end
    when '+'
      if @reading_string && !peek
        @buffer.push(char)
        @last_type = :LIT_STR
      else
        @last_type = :OP_PLUS
        print_line unless peek
      end
    when '-'
      if @reading_string && !peek
        @buffer.push(char)
        @last_type = :LIT_STR
      else
        @last_type = :OP_MINUS
        print_line unless peek
      end
    when '*'
      if @reading_string && !peek
        @buffer.push(char)
        @last_type = :LIT_STR
      else
        @last_type = :OP_MULTIPLY
        print_line unless peek
      end
    when '>'
      unless peek
        if @reading_string
          @buffer.push(char)
          @last_type = :LIT_STR
        else
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
        end
      else
        @last_type = :OP_G
      end
    when '<'
      unless peek
        if @reading_string
          @buffer.push(char)
          @last_type = :LIT_STR
        else
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
        end
      else
        @last_type = :OP_L
      end
    when '='
      unless peek
        if @reading_string
          @buffer.push(char)
          @last_type = :LIT_STR
        else
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
        end
      else
        @last_type = :OP_E
      end
    when '!'
      unless peek
        if @reading_string
          @buffer.push(char)
          @last_type = :LIT_STR
        else
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
        end
      else
        @last_type = :OP_N
      end
    when ' '
      if @reading_string && !peek
        @buffer.push(char)
        @last_type = :LIT_STR
      else
        @last_type = :EMPTY
      end
    when ','
      if @reading_string && !peek
        @buffer.push(char)
        @last_type = :LIT_STR
      else
        @last_type = :SYM_COM
        print_line unless peek
      end
    when '.'
      unless peek
        if @reading_string
          @buffer.push(char)
          @last_type = :LIT_STR
        else
          original_last_type = @last_type
          future_last_type = scan(true)
          # Check for X.X float
          if original_last_type == :LIT_INT && future_last_type == :LIT_INT
            @last_type = :LIT_FLOAT
            @buffer.push(char)
            @reading_float = true
          # Check for X. float
          elsif original_last_type == :LIT_INT && future_last_type != :LIT_INT
            @last_type = :LIT_FLOAT
            @buffer.push(char)
            print_line
          # Check for .X float
          elsif original_last_type != :LIT_INT && future_last_type == :LIT_INT
            @last_type = :LIT_FLOAT
            @buffer = []
            @buffer.push(char)
            @reading_float = true
          else
            @last_type = :SYM_DOT
            print_line
          end
        end
      else
        @last_type = :SYM_DOT
      end
    when '@'
      if @reading_string && !peek
        @buffer.push(char)
        @last_type = :LIT_STR
      else
        @last_type = :SYM_ETA
        print_line unless peek
      end
    when '$'
      if @reading_string && !peek
        @buffer.push(char)
        @last_type = :LIT_STR
      else
        @last_type = :SYM_DOL
        print_line unless peek
      end
    when '('
      if @reading_string && !peek
        @buffer.push(char)
        @last_type = :LIT_STR
      else
        @last_type = :OP_PAREN_O
        print_line unless peek
      end
    when ')'
      if @reading_string && !peek
        @buffer.push(char)
        @last_type = :LIT_STR
      else
        @last_type = :OP_PAREN_C
        print_line unless peek
      end
    when '{'
      if @reading_string && !peek
        @buffer.push(char)
        @last_type = :LIT_STR
      else
        @last_type = :OP_BRACE_O
        print_line unless peek
      end
    when '}'
      if @reading_string && !peek
        @buffer.push(char)
        @last_type = :LIT_STR
      else
        @last_type = :OP_BRACE_C
        print_line unless peek
      end
    when ';'
      if @reading_string && !peek
        @buffer.push(char)
        @last_type = :LIT_STR
      else
        @last_type = :SYM_SEMICOL
        print_line unless peek
      end
    else
      @last_type = :ERROR
      unless peek
        print_line
        puts "Error Message: Unknown symbol used"
      end
    end

    @index -= 1 if peek
    @last_type
  end

  def scan_keyword
    word = @buffer.join
    case word
    when 'if'
      @last_type = :KW_IF
    when 'elseif'
      @last_type = :KW_ELSEIF
    when 'else'
      @last_type = :KW_ELSE
    when 'int'
      @last_type = :KW_INT
    when 'float'
      @last_type = :KW_FLOAT
    when 'char'
      @last_type = :KW_CHAR
    when 'while'
      @last_type = :KW_WHILE
    when 'break'
      @last_type = :KW_BREAK
    when 'continue'
      @last_type = :KW_CONTINUE
    when 'return'
      @last_type = :KW_RETURN
    else
      return false
    end

    print_line
    true
  end

  def print_line
    case @last_type
    when :LIT_INT, :LIT_STR, :LIT_FLOAT
      print_formated_line(@last_type,@buffer.join)
    when :IDENT
      print_formated_line("#{@last_type}\t",@buffer.join)
    when :OP_PLUS, :OP_MINUS, :OP_MULTIPLY, :OP_DIVIDE, :SYM_COM, :SYM_SEMICOL,
         :SYM_ETA, :SYM_DOL, :SYM_ESC, :OP_BRACE_O, :OP_BRACE_C, :OP_PAREN_O,
         :OP_PAREN_C, :KW_ELSEIF, :KW_ELSE, :KW_FLOAT, :KW_CHAR, :KW_WHILE,
         :KW_BREAK, :KW_CONTINUE, :KW_RETURN, :SYM_DOT
      print_formated_line(@last_type, '')
    when :EOF, :OP_E, :OP_DE, :OP_G, :OP_L, :OP_GE, :OP_LE, :OP_N, :OP_NE,
        :KW_IF, :KW_INT
      print_formated_line("#{@last_type}\t", '')
    when :TABLE
      puts "ID\t|LN\t|TYPE\t\t|VALUE"
      puts "----------------------------------------"
    when :ERROR
      puts "Error! File: #{@file_name} Line: #{@line_id} Index: #{@index}"
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
