require_relative '../status'
require_relative '../error'
require_relative '../token'
require_relative 'table'
require_relative 'charprocessor_states.rb'

class CharProcessor
  attr_accessor :skip_next

  def initialize(tokens, status, show)
    @tokens = tokens
    @state = :DEFAULT
    @status = status
    @skip_next = false

    @show = show
    @table = Table.new
    @table.table_top if @show == true
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
  - :SL_COMMENT
  - :DL_COMMENT
=end

  def process(cur_char, next_char)
    @cur_char = cur_char
    @next_char = next_char

    case @state
    when :DEFAULT; process_default
    when :IDENT; process_ident
    when :LIT_INT; process_lit_int
    when :LIT_FLOAT; process_lit_float
    when :STRING_SCOM; process_string_scom
    when :STRING_DCOM; process_string_dcom
    when :ESCAPE; process_escape
    when :SL_COMMENT; process_single_line_comment
    when :ML_COMMENT; process_multi_line_comment
    else; raise "Unprocessed state #{@state}"
    end
  end

  def finish(char)
    process(char, :EOF)
    complete(:EOF, nil)
  end

  # Process new line symbol
  def process_new_line
    @status.line += 1

    @skip_next = true if ((@cur_char == "\n" && @next_char == "\r") ||
                          (@cur_char == "\r" && @next_char == "\n"))
  end

  # Process operator AND
  def process_and
    if @next_char == "&"
      complete(:OP_DAND, nil)
      @skip_next = true
    else
      complete(:OP_AND, nil)
    end
  end

  # Process operator OR
  def process_or
    if @next_char == "|"
      complete(:OP_DOR, nil)
      @skip_next = true
    else
      complete(:OP_OR, nil)
    end
  end

  # Process relational operator
  def process_relational(type, type_n_eq)
    if @next_char == "="
      complete(type_n_eq, nil)
      @skip_next = true
    else
      complete(type, nil)
    end
  end

  # Complete token
  def complete(name, value)
    token = Token.new(name, value, @status.file_name, @status.line)
    @tokens.push(token)
    @state = :DEFAULT

    @table.show(token, @status) if @show == true
  end
end
