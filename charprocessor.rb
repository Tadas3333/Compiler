require_relative 'table'

class CharProcessor
  def initialize(tokens)
    @table = Table.new
    @table.table_top

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
      else #:NON
        complete_sym_equal(char)
      end

    ############################################################################
    when '&'
      case @state
      when :STRING
        add_to_buffer(char)
      when :LIT_INT, :LIT_FLOAT, :IDENT
        complete(@state)
        add_to_empty_buffer(char)
        complete(:OP_AND)
      else #:NON
        if get_last_token == :OP_AND && @first_line_symbol == false
          remove_last_token
          add_to_empty_buffer(char)
          add_to_buffer(char)
          complete(:OP_DAND)
        else
          add_to_empty_buffer(char)
          complete(:OP_AND)
        end
      end

    ############################################################################
    when '|'
      case @state
      when :STRING
        add_to_buffer(char)
      when :LIT_INT, :LIT_FLOAT, :IDENT
        complete(@state)
        add_to_empty_buffer(char)
        complete(:OP_OR)
      else #:NON
        if get_last_token == :OP_OR && @first_line_symbol == false
          remove_last_token
          add_to_empty_buffer(char)
          add_to_buffer(char)
          complete(:OP_DOR)
        else
          add_to_empty_buffer(char)
          complete(:OP_OR)
        end
      end

    ############################################################################
    when '+'
      complete_simple_sym(char,:OP_PLUS)

    ############################################################################
    when '-'
      complete_simple_sym(char,:OP_MINUS)

    ############################################################################
    when '*'
      complete_simple_sym(char,:OP_MULTIPLY)

    ############################################################################
    when '/'
      complete_simple_sym(char,:OP_DIVIDE)

    ############################################################################
    when '>'
      complete_simple_sym(char,:OP_G)

    ############################################################################
    when '<'
      complete_simple_sym(char,:OP_L)

    ############################################################################
    when '!'
      complete_simple_sym(char,:OP_N)

    ############################################################################
    when ','
      complete_simple_sym(char,:SYM_COM)

    ############################################################################
    when '@'
      complete_simple_sym(char,:SYM_AT)

    ############################################################################
    when '$'
      complete_simple_sym(char,:SYM_DOL)

    ############################################################################
    when '('
      complete_simple_sym(char,:OP_PAREN_O)

    ############################################################################
    when ')'
      complete_simple_sym(char,:OP_PAREN_C)

    ############################################################################
    when '{'
      complete_simple_sym(char,:OP_BRACE_O)

    ############################################################################
    when '}'
      complete_simple_sym(char,:OP_BRACE_C)

    ############################################################################
    when ';'
      complete_simple_sym(char,:SYM_SEMICOL)

    ############################################################################
    when ' '
      case @state
      when :STRING
        add_to_buffer(char)
      when :NON # Do nothing
      else # :LIT_INT, :LIT_FLOAT, :IDENT
        complete(@state)
      end

    ############################################################################
    when "\r"
      case @state
      when :STRING
        print_error("No ending comma was found!")
        return false
      when :NON
        @first_line_symbol = true
      else # :LIT_INT, :LIT_FLOAT, :IDENT
        complete(@state)
        @first_line_symbol = true
      end

    ############################################################################
    when "\n"
      case @state
      when :STRING
        print_error("No ending comma was found!")
        return false
      when :NON
        @first_line_symbol = true
      else # :LIT_INT, :LIT_FLOAT, :IDENT
        complete(@state)
        @first_line_symbol = true
      end

      @line_id += 1

    ############################################################################
    when :EOF # End Of File
      case @state
      when :STRING
        print_error("No ending comma was found!")
        return false
      when :NON # Do nothing
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
    else #:NON
      add_to_empty_buffer(char)
      complete(token)
    end
  end

  def complete(type)
    # Display table when it's end of file
    if type == :EOF
      @tokens.push(:EOF)
      @values.push('')
      @token_lines.push(@line_id)

      @table.show(@tokens, @values, @token_lines)
      return
    end

    # Merge array to a string
    @buffer = @buffer.join

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
