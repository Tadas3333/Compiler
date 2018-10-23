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
    else; raise "Unprocessed state #{@state}"
    end

    @status.next_index
  end

  # Process new line symbol
  def process_new_line
    @status.next_line

    @skip_next = true if ((@cur_type == :S_NL && @next_type == :S_CR) ||
                          (@cur_type == :S_CR && @next_type == :S_NL))
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
