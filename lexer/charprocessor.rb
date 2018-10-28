require_relative '../status'
require_relative '../error'
require_relative '../token'
require_relative 'chartype'
require_relative 'table'
require_relative 'charprocessor_states.rb'

class CharProcessor
  attr_accessor :skip_next

  def initialize(tokens)
    @tokens = tokens
    @state = :DEFAULT
    @status = Status.new
    @skip_next = false
    @table = Table.new
  end

=begin
  States:
  - :DEFAULT
  - :IDENT
  - :LIT_INT
  - :LIT_FLOAT
  - :STRING_SCOM
  - :STRING_DCOM
  - :ESCAPE
  - :COMMENT
=end

  def process(cur_char, next_char)
    @cur_char = cur_char
    @next_char = next_char
    @cur_type = char_type(@cur_char)
    @next_type = char_type(@next_char)

    case @state
    when :DEFAULT; process_default
    when :IDENT; process_ident
    when :LIT_INT; process_lit_int
    when :LIT_FLOAT; process_lit_float
    when :STRING_SCOM; process_string_scom
    when :STRING_DCOM; process_string_dcom
    when :ESCAPE; process_escape
    when :COMMENT; process_comment
    else; raise "Unprocessed state #{@state}"
    end

    @status.next_index
  end

  def finish(char)
    process(char, :EOF)
    complete(:EOF)
  end

  # Process new line symbol
  def process_new_line
    @status.next_line

    @skip_next = true if ((@cur_type == :S_NL && @next_type == :S_CR) ||
                          (@cur_type == :S_CR && @next_type == :S_NL))
  end

  # Process operator AND
  def process_and
    if @next_type == :OP_AND
      complete(:OP_DAND)
      @skip_next = true
    else
      complete(:OP_AND)
    end
  end

  # Process operator OR
  def process_or
    if @next_type == :OP_OR
      complete(:OP_DOR)
      @skip_next = true
    else
      complete(:OP_OR)
    end
  end

  # Process operator GREATER
  def process_greater
    if @next_type == :OP_E
      complete(:OP_GE)
      @skip_next = true
    else
      complete(:OP_G)
    end
  end

  # Process operator LESS
  def process_less
    if @next_type == :OP_E
      complete(:OP_LE)
      @skip_next = true
    else
      complete(:OP_L)
    end
  end

  # Process operator EQUAL
  def process_equal
    if @next_type == :OP_E
      complete(:OP_DE)
      @skip_next = true
    else
      complete(:OP_E)
    end
  end

  # Process operator NOT
  def process_not
    if @next_type == :OP_E
      complete(:OP_NE)
      @skip_next = true
    else
      complete(:OP_N)
    end
  end

  # Complete token
  def complete(name, value='')
    token = Token.new(name, value)
    @tokens.push(token)
    @state = :DEFAULT

    @table.show(token, @status)
  end

  # Get character type
  def char_type(char)
    chartype = CharType.new(char, @status)
    chartype.type
  end
end
