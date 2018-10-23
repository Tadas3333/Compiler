require_relative 'table'

class CharProcessor
  def initialize(tokens)
    @table = Table.new

    @tokens = tokens
    @values = []
    @token_lines = []

    @state = :NON
    @index = 0
    @line_id = 1

    @escape_symbol_used = false
    @first_line_symbol = true
  end

=begin
  States:
  - :NON (default)
  - :IDENT
  - :LIT_INT
  - :LIT_FLOAT
  - :STRING
  - :COMMENT
=end

  def process(char)
    case char
    ############################################################################
    when 'a'..'z', 'A'..'Z', '_'
      case @state
      when :IDENT
        add_to_buffer(char)
      when :LIT_INT
        @state = :IDENT
        add_to_buffer(char)
      when :LIT_FLOAT
        complete(@state)
        @state = :IDENT
        add_to_empty_buffer(char)
      when :STRING
        if char == 'r' || char == 'n'
          if @escape_symbol_used == true
            @escape_symbol_used = false
            add_to_buffer('\\')
          end
        end

        add_to_buffer(char)
      when :COMMENT
        # Do nothing
      else # :NON
        @state = :IDENT
        add_to_empty_buffer(char)
      end

    ############################################################################
    when '0'..'9'
      case @state
      when :NON
        # Check if last symbol was a '.', then this should turn into a float
        if get_last_token == :SYM_DOT && @first_line_symbol == false
          remove_last_token
          @state = :LIT_FLOAT
          add_to_empty_buffer('.')
          add_to_buffer(char)
        else
          @state = :LIT_INT
          add_to_empty_buffer(char)
        end
      when :COMMENT
        # Do nothing
      else # :LIT_INT, :LIT_FLOAT, :STRING, :IDENT
        add_to_buffer(char)
      end

    ############################################################################
    when '.'
      case @state
      when :NON
        add_to_empty_buffer(char)
        complete(:SYM_DOT)
      when :LIT_INT
        @state = :LIT_FLOAT
        add_to_buffer(char)
      when :LIT_FLOAT
        complete(:LIT_FLOAT)
        add_to_empty_buffer(char)
        complete(:SYM_DOT)
      when :STRING
        add_to_buffer(char)
      when :COMMENT
        # Do nothing
      else #:IDENT
        complete(:IDENT)
        add_to_empty_buffer(char)
        complete(:SYM_DOT)
      end

    ############################################################################
    when '"', "'"
      case @state
      when :NON
        @state = :STRING
        empty_buffer
        @string_symbol = char
      when :LIT_INT
        complete(:LIT_INT)
        @state = :STRING
        empty_buffer
        @string_symbol = char
      when :LIT_FLOAT
        complete(:LIT_FLOAT)
        @state = :STRING
        empty_buffer
        @string_symbol = char
      when :IDENT
        complete(:IDENT)
        @state = :STRING
        empty_buffer
        @string_symbol = char
      when :COMMENT
        # Do nothing
      else #:STRING
        # Check if this symbol was escaped
        if @escape_symbol_used == true
          @escape_symbol_used = false
          add_to_buffer(char)
        else
          # Check if string was opened with this symbol
          if @string_symbol == char
            complete(:STRING)
          else
            add_to_buffer(char)
          end
        end
      end

    ############################################################################
    when '\\'
      case @state
      when :NON
        add_to_empty_buffer(char)
        complete(:SYM_ESC)
      when :LIT_INT
        complete(:LIT_INT)
        add_to_empty_buffer(char)
        complete(:SYM_ESC)
      when :LIT_FLOAT
        complete(:LIT_FLOAT)
        add_to_empty_buffer(char)
        complete(:SYM_ESC)
      when :IDENT
        complete(:IDENT)
        add_to_empty_buffer(char)
        complete(:SYM_ESC)
      when :COMMENT
        # Do nothing
      else #:STRING
        if @escape_symbol_used == true
          add_to_buffer(char)
          @escape_symbol_used = false
        else
          @escape_symbol_used = true
        end
      end

    ############################################################################
    when '='
      case @state
      when :STRING
        add_to_buffer(char)
      when :LIT_INT, :LIT_FLOAT, :IDENT
        complete(@state)
        complete_sym_equal(char)
      when :COMMENT
        # Do nothing
      else #:NON
        complete_sym_equal(char)
      end

    ############################################################################
    when '/'
      case @state
      when :STRING
        add_to_buffer(char)
      when :LIT_INT, :LIT_FLOAT, :IDENT
        complete(@state)
        add_to_empty_buffer(char)
        complete(:OP_DIVIDE)
      when :COMMENT
        # Do nothing
      else #:NON
        # Check for comment start
        if get_last_token == :OP_DIVIDE && @first_line_symbol == false
          remove_last_token
          @state = :COMMENT
        else
          add_to_empty_buffer(char)
          complete(:OP_DIVIDE)
        end
      end

    ############################################################################
    when '&'; complete_log_op(char, :OP_AND, :OP_DAND)
    when '|'; complete_log_op(char, :OP_OR, :OP_DOR)
    when '+'; complete_simple_sym(char,:OP_PLUS)
    when '-'; complete_simple_sym(char,:OP_MINUS)
    when '*'; complete_simple_sym(char,:OP_MULTIPLY)
    when '>'; complete_simple_sym(char,:OP_G)
    when '<'; complete_simple_sym(char,:OP_L)
    when '!'; complete_simple_sym(char,:OP_N)
    when ','; complete_simple_sym(char,:SYM_COM)
    when '@'; complete_simple_sym(char,:SYM_AT)
    when '$'; complete_simple_sym(char,:SYM_DOL)
    when '('; complete_simple_sym(char,:OP_PAREN_O)
    when ')'; complete_simple_sym(char,:OP_PAREN_C)
    when '{'; complete_simple_sym(char,:OP_BRACE_O)
    when '}'; complete_simple_sym(char,:OP_BRACE_C)
    when ';'; complete_simple_sym(char,:SYM_SEMICOL)

    ############################################################################
    when ' '
      case @state
      when :STRING
        add_to_buffer(char)
      when :NON, :COMMENT # Do nothing
      else # :LIT_INT, :LIT_FLOAT, :IDENT
        complete(@state)
      end

    ############################################################################
    when "\r"
      return false unless complete_end_of_line

    ############################################################################
    when "\n"
      return false unless complete_end_of_line

      @line_id += 1

    ############################################################################
    when :EOF # End Of File
      case @state
      when :STRING
        print_error("No ending comma was found!")
        return false
      when :NON, :COMMENT # Do nothing
      else # :LIT_INT, :LIT_FLOAT, :IDENT
        complete(@state)
      end

      complete(:EOF)

    ############################################################################
    else # Unprocessed Char
      print_error("Unprocessed character #{char}")
      return false
    end

    @index += 1
    true
  end

  # Completes '=' symbol
  def complete_sym_equal(char)
    last_token = get_last_token
    if @first_line_symbol == false
      if last_token == :OP_G # Last symbol '>'
        remove_last_token
        add_to_empty_buffer('>')
        add_to_buffer('=')
        complete(:OP_GE) # Complete as '>='
      elsif last_token == :OP_L # Last symbol '<'
        remove_last_token
        add_to_empty_buffer('<')
        add_to_buffer('=')
        complete(:OP_LE) # Complete as '<='
      elsif last_token == :OP_N # Last symbol '!'
        remove_last_token
        add_to_empty_buffer('!')
        add_to_buffer('=')
        complete(:OP_NE)  # Complete as '!='
      elsif last_token == :OP_E # Last symbol '='
        remove_last_token
        add_to_empty_buffer('=')
        add_to_buffer('=')
        complete(:OP_DE)  # Complete as '=='
      else
        add_to_empty_buffer(char)
        complete(:OP_E)  # Complete as '='
      end
    else
      add_to_empty_buffer(char)
      complete(:OP_E)  # Complete as '='
    end
  end

  # Completes a simple symbol
  def complete_simple_sym(char, token)
    case @state
    when :STRING
      add_to_buffer(char)
    when :LIT_INT, :LIT_FLOAT, :IDENT
      complete(@state)
      add_to_empty_buffer(char)
      complete(token)
    when :COMMENT
      # Do nothing
    else #:NON
      add_to_empty_buffer(char)
      complete(token)
    end
  end

  # Complete End of Line Symols (\r and \n)
  def complete_end_of_line
    case @state
    when :STRING
      print_error("No ending comma was found!")
      return false
    when :NON
      @first_line_symbol = true
    when :COMMENT
      @state = :NON
      @first_line_symbol = true
    else # :LIT_INT, :LIT_FLOAT, :IDENT
      complete(@state)
      @first_line_symbol = true
    end
    true
  end

  # Complete Logical Operator
  def complete_log_op(char, type, type_double)
    case @state
    when :STRING
      add_to_buffer(char)
    when :LIT_INT, :LIT_FLOAT, :IDENT
      complete(@state)
      add_to_empty_buffer(char)
      complete(type)
    when :COMMENT
      # Do nothing
    else #:NON
      if get_last_token == type && @first_line_symbol == false
        remove_last_token
        add_to_empty_buffer(char)
        add_to_buffer(char)
        complete(type_double)
      else
        add_to_empty_buffer(char)
        complete(type)
      end
    end
  end

  def get_keyword
    case @buffer
    when 'if'
      return :KW_IF
    when 'elseif'
      return :KW_ELSEIF
    when 'else'
      return :KW_ELSE
    when 'int'
      return :KW_INT
    when 'float'
      return :KW_FLOAT
    when 'char'
      return :KW_CHAR
    when 'while'
      return :KW_WHILE
    when 'break'
      return :KW_BREAK
    when 'continue'
      return :KW_CONTINUE
    when 'return'
      return :KW_RETURN
    else
      return :IDENT
    end
  end

  def complete(type)
    # Display table when it's end of file
    if type == :EOF
      @table.table_top

      @tokens.push(:EOF)
      @values.push('')
      @token_lines.push(@line_id)

      @table.show(@tokens, @values, @token_lines)
      return
    end

    # Merge array to a string
    @buffer = @buffer.join

    # Check for a keyword (will set type to KW_ if it's a keyword)
    if type == :IDENT
      type = get_keyword
    end

    # Save values
    @tokens.push(type)
    @values.push(@buffer)
    @token_lines.push(@line_id)

    # Reset variables
    @state = :NON
    @first_line_symbol = false
  end

  def add_to_empty_buffer(char)
    @buffer = []
    @buffer.push(char)
  end

  def add_to_buffer(char)
    @buffer.push(char)
  end

  def empty_buffer
    @buffer = []
  end

  def get_last_token
    @tokens.last
  end

  def remove_last_token
    @tokens.pop
    @values.pop
    @token_lines.pop
  end

  def print_error(custom_message = '')
    puts "Error occured! Line: #{@line_id}, Index: #{@index}"
    unless custom_message.empty?
      puts custom_message
    end
  end
end