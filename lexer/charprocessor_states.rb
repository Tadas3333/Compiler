class CharProcessor
  # Process :DEFAULT state
  def process_default
    @buffer = []

    case @cur_type
    when :LETTER; process_ident
    when :NUMBER; process_lit_int
    when :S_NL, :S_CR; process_new_line
    when :S_DOT
      if @next_type == :NUMBER
       process_lit_float
     else
       complete(@cur_type)
     end
    when :S_SEMICOL, :OP_PLUS, :OP_MINUS, :OP_MULTIPLY, :OP_DIVIDE, :S_COM,
         :S_AT, :S_DOL, :OP_PAREN_O, :OP_PAREN_C, :OP_BRACE_O, :OP_BRACE_C
      complete(@cur_type)
    when :SPACE, :S_EOF; # Do nothing
    else; raise "Unprocessed character type #{@cur_type}"
    end
  end

  # Process :IDENT state
  def process_ident
    @state = :IDENT

    # Add current character to the buffer
    @buffer.push(@cur_char)

    # Check next character
    complete(:IDENT, @buffer.join) if (@next_type != :LETTER &&
                                       @next_type != :NUMBER)
  end

  # Process :LIT_INT state
  def process_lit_int
    @state = :LIT_INT

    # Add current character to the buffer
    @buffer.push(@cur_char)

    # Check next character
    Error.new('Invalid integer', @status) if @next_type == :LETTER

    if @next_type == :S_DOT
      @state = :LIT_FLOAT
    elsif @next_type != :NUMBER
      complete(:LIT_INT, @buffer.join)
    end
  end

  # Process :LIT_FLOAT state
  def process_lit_float
    @state = :LIT_FLOAT

    # Add current character to the buffer
    @buffer.push(@cur_char)

    # Check next character
    Error.new('Invalid float', @status) if @next_type == :LETTER
    complete(:LIT_FLOAT, @buffer.join) if @next_type != :NUMBER
  end
end
