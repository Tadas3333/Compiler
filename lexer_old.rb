
class Lexer
  attr_reader :line_id
  attr_reader :printed_count
  attr_reader :state
  attr_reader :successful

  def initialize(file_name, lines_read = 1, printed_count = 0, is_include_file = false)
    @file_name = file_name
    @line_id = lines_read
    @printed_count = printed_count
    @is_include_file = is_include_file
    @successful = false
  end

  def start
    unless File.file?(@file_name)
      puts "File '#{@file_name}' doesn't exist!"
      return false
    end

    lines = File.readlines(@file_name)
    print_table_top unless @is_include_file
    @local_line_id = 1

    # Iterate through all lines in a file
    lines.each do |line|
      @current_line = line.strip

      @index = 0
      @state = :EMPTY
      # Iterate through every symbol in a line
      while @state != :END_OF_LINE && @state != :ERROR
        scan
        @index += 1
      end

      return false if @state == :ERROR

      @line_id += 1
      @local_line_id +=1
    end

    unless lines.empty?
      @state = :EOF
      print_line unless @is_include_file
    else
      puts "File '#{@file_name}' is empty!"
    end
    @successful = true
    true
  end

  def check_end_of_line
    if @index >= @current_line.length
      if @state == :STRING
        @state = :ERROR
        print_line
        puts "Error Message: No comma to end string"
      end

      if @state == :INCLUDE
        @state = :ERROR
        print_line
        puts "Error Message: No include file specified!"
      end

      @state = :END_OF_LINE
    end
  end

  def peek
    @index += 1

    @old_state = @state
    check_end_of_line
    peek_state = @state
    @state = @old_state

    return if peek_state == :ERROR || peek_state == :END_OF_LINE

    char = @current_line[@index]

    case char
    when '"' peek_type = :SYM_DCOM
    when "'" peek_type = :SYM_SCOM
    when '\\' peek_type = :SYM_ESC
    when '/' peek_type = :OP_DIVIDE
    when '0'..'9' peek_type = :LIT_INT
    when 'a'..'z', 'A'..'Z', '_' peek_type = :IDENT
    when '+' peek_type = :OP_PLUS
    when '-' peek_type = :OP_MINUS
    when '*' peek_type = :OP_MULTIPLY
    when '>' peek_type = :OP_G
    when '<' peek_type = :OP_L
    when '=' peek_type = :OP_E
    when '!' peek_type = :OP_N
    when ' ' peek_type = :EMPTY
    when ',' peek_type = :SYM_COM
    when '.' peek_type = :SYM_DOT
    when '&' peek_type = :OP_AND
    when '|' peek_type = :OP_OR
    when '@' peek_type = :SYM_ETA
    when '$' peek_type = :SYM_DOL
    when '(' peek_type = :OP_PAREN_O
    when ')' peek_type = :OP_PAREN_C
    when '{' peek_type = :OP_BRACE_O
    when '}' peek_type = :OP_BRACE_C
    when ';' peek_type = :SYM_SEMICOL
    else peek_type = :ERROR
    end

    @index -= 1
    peek_type
end

def scan
  check_end_of_line
  return if @state == :ERROR || @state == :END_OF_LINE

  char = @current_line[@index]
  @last_read_char = char

  #puts "CURRENT CHARACTER: #{char}"

  case char
  when '"' @type = :SYM_DCOM
  when "'" @type = :SYM_SCOM
  when '\\' @type = :SYM_ESC
  when '/' @type = :OP_DIVIDE
  when '0'..'9'
    @type = :LIT_INT

  when 'a'..'z', 'A'..'Z', '_'
    @type = :IDENT
  when '+' @type = :OP_PLUS
  when '-' @type = :OP_MINUS
  when '*' @type = :OP_MULTIPLY
  when '>' @type = :OP_G
  when '<' @type = :OP_L
  when '=' @type = :OP_E
  when '!' @type = :OP_N
  when ' ' @type = :EMPTY
  when ',' @type = :SYM_COM
  when '.' @type = :SYM_DOT
  when '&' @type = :OP_AND
  when '|' @type = :OP_OR
  when '@' @type = :SYM_ETA
  when '$' @type = :SYM_DOL
  when '(' @type = :OP_PAREN_O
  when ')' @type = :OP_PAREN_C
  when '{' @type = :OP_BRACE_O
  when '}' @type = :OP_BRACE_C
  when ';' @type = :SYM_SEMICOL
  else @type = :ERROR
  end

  print_line
end


=begin
  def scan()
    check_end_of_line
    return if @last_type == :ERROR || @last_type == :END_OF_LINE

    char = @current_line[@index]
    @last_read_char = char
    #puts "CURRENT CHARACTER: #{char}" unless peek
    case char
    when '"'
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

            if @reading_include
              include_file
            else
              print_line
            end
          end
        else
          # String read mode was started with single comma
          @buffer.push(char)
          @last_type = :LIT_STR
        end
      end
    when "'"
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

            if @reading_include
              include_file
            else
              print_line
            end
          end
        else
          # String read mode was started with double comma
          @buffer.push(char)
          @last_type = :LIT_STR
        end
      end
    when '\\'
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
    when '/'
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
    when '0'..'9'
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
    when 'a'..'z', 'A'..'Z', '_'
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
    when '+'
      @last_type = :OP_PLUS

      if @reading_string
        @buffer.push(char)
      else
        print_line
      end
    when '-'
      @last_type = :OP_MINUS

      if @reading_string
        @buffer.push(char)
      else
        print_line
      end
    when '*'
      @last_type = :OP_MULTIPLY

      if @reading_string
        @buffer.push(char)
      else
        print_line
      end
    when '>'
      if @reading_string
        @buffer.push(char)
        @last_type = :OP_G
      else
        if peek != :OP_E
          @last_type = :OP_G
        else
          @last_type = :OP_GE
          @index += 1
        end
        print_line
      end
    when '<'
      if @reading_string
        @buffer.push(char)
        @last_type = :OP_L
      else
        if peek != :OP_E
          @last_type = :OP_L
        else
          @last_type = :OP_LE
          @index += 1
        end
        print_line
      end
    when '='
      if @reading_string
        @buffer.push(char)
        @last_type = :OP_E
      else
        if peek != :OP_E
          @last_type = :OP_E
        else
          @last_type = :OP_EE
          @index += 1
        end
        print_line
      end
    when '!'
      if @reading_string
        @buffer.push(char)
        @last_type = :OP_N
      else
        if peek != :OP_E
          @last_type = :OP_N
        else
          @last_type = :OP_NE
          @index += 1
        end
        print_line
      end
    when ' '
      @last_type = :EMPTY

      if @reading_string
        @buffer.push(char)
      end
    when ','
      @last_type = :SYM_COM

      if @reading_string
        @buffer.push(char)
      else
        print_line
      end
    when '.'
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
    when '&'
      unless peek
        if @reading_string
          @buffer.push(char)
          @last_type = :LIT_STR
        else
          # If last type was AND, print as double AND
          if @last_type == :OP_AND
            @last_type = :OP_DAND
            @buffer.push(char)
            print_line
          else
            # If next is AND, clear buffer and push current char
            if scan(true) == :OP_AND
              @last_type = :OP_AND
              @buffer = []
              @buffer.push(char)
            else
              # If no AND found on both sides, print just single AND
              @last_type = :OP_AND
              print_line
            end
          end
        end
      else
        @last_type = :OP_AND
      end
    when '|'
      unless peek
        if @reading_string
          @buffer.push(char)
          @last_type = :LIT_STR
        else
          # If last type was OR, print as double OR
          if @last_type == :OP_OR
            @last_type = :OP_DOR
            @buffer.push(char)
            print_line
          else
            # If next is OR, clear buffer and push current char
            if scan(true) == :OP_OR
              @last_type = :OP_OR
              @buffer = []
              @buffer.push(char)
            else
              # If no OR found on both sides, print just single OR
              @last_type = :OP_OR
              print_line
            end
          end
        end
      else
        @last_type = :OP_OR
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

    @last_type
  end
=end

  def scan_keyword
    word = @buffer.join

    case word
    when 'if' @type = :KW_IF
    when 'elseif' @type = :KW_ELSEIF
    when 'else' @type = :KW_ELSE
    when 'int' @type = :KW_INT
    when 'float' @type = :KW_FLOAT
    when 'char' @type = :KW_CHAR
    when 'while' @type = :KW_WHILE
    when 'break' @type = :KW_BREAK
    when 'continue' @type = :KW_CONTINUE
    when 'return' @type = :KW_RETURN
    when 'include' @type = :KW_INCLUDE
    else return false
    end

    print_line
    true
  end

  def include_file
=begin
    @reading_include = false
    @buffer = @buffer.join
    inc = Lexer.new(@buffer, @line_id, @printed_count, true)
    inc.start

    return @type = :ERROR if inc.last_type == :ERROR || inc.successful == false

    @line_id = inc.line_id-1
    @printed_count = inc.printed_count
=end
  end

  def print_table_top
    puts "ID\t|LN\t|TYPE\t\t|VALUE"
    puts "----------------------------------------"
  end

  def print_line
    case @state
    when :LIT_INT, :LIT_STR, :LIT_FLOAT
      print_formated_line(@type,@buffer.join)
    when :IDENT
      print_formated_line("#{@type}\t",@buffer.join)
    when :OP_PLUS, :OP_MINUS, :OP_MULTIPLY, :OP_DIVIDE, :SYM_COM, :SYM_SEMICOL,
         :SYM_ETA, :SYM_DOL, :SYM_ESC, :OP_BRACE_O, :OP_BRACE_C, :OP_PAREN_O,
         :OP_PAREN_C, :KW_ELSEIF, :KW_ELSE, :KW_FLOAT, :KW_CHAR, :KW_WHILE,
         :KW_BREAK, :KW_CONTINUE, :KW_RETURN, :SYM_DOT, :OP_DAND, :KW_INCLUDE
      print_formated_line(@type, '')
    when :EOF, :OP_E, :OP_DE, :OP_G, :OP_L, :OP_GE, :OP_LE, :OP_N, :OP_NE,
        :KW_IF, :KW_INT, :OP_AND, :OP_OR, :OP_DOR
      print_formated_line("#{@type}\t", '')
    when :ERROR
      puts "Error! File: #{@file_name} Line: #{@local_line_id} Index: #{@index}"
    else
      puts "Unknown @last_type!"
    end
  end

  def print_formated_line(type, value)
    puts "#{@printed_count}\t|#{@line_id}\t|#{type}\t|#{value}"
    @printed_count += 1
  end

end

lex = Lexer.new('lexer_input_3.txt')
lex.start
