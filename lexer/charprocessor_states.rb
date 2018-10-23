require_relative 'keywords'

class CharProcessor
  # Process :DEFAULT state
  def process_default
    @buffer = []

    case @cur_type
    when :LETTER; process_ident
    when :NUMBER; process_lit_int
    when :S_SCOM; process_string_scom
    when :S_DCOM; process_string_dcom
    when :OP_AND; process_and
    when :OP_OR; process_or
    when :OP_G; process_greater
    when :OP_L; process_less
    when :OP_E; process_equal
    when :OP_N; process_not
    when :OP_DIVIDE
      if @next_type == :OP_DIVIDE
        process_comment
      else
        complete(@cur_type)
      end
    when :S_DOT
      if @next_type == :NUMBER
       process_lit_float
     else
       complete(@cur_type)
     end
    when :S_SEMICOL, :OP_PLUS, :OP_MINUS, :OP_MULTIPLY, :S_COM,
         :S_AT, :S_DOL, :OP_PAREN_O, :OP_PAREN_C, :OP_BRACE_O, :OP_BRACE_C,
         :SYM_ESCP, :S_COL, :S_ESC
      complete(@cur_type)
    when :S_NL, :S_CR; process_new_line
    when :SPACE, :S_EOF; # Do nothing
    else; raise "Unprocessed character type #{@cur_type}"
    end
  end

  ##############################################################################
  # Process :IDENT state
  def process_ident
    @state = :IDENT

    # Add current character to the buffer
    @buffer.push(@cur_char)

    # Check next character
    if (@next_type != :LETTER && @next_type != :NUMBER)
      buff = @buffer.join
      keywords = Keywords.new
      type = keywords.get_keyword(buff)

      if type != :IDENT
        complete(type, '')
      else
        complete(type, buff)
      end
    end
  end

  ##############################################################################
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

  ##############################################################################
  # Process :LIT_FLOAT state
  def process_lit_float
    @state = :LIT_FLOAT

    # Add current character to the buffer
    @buffer.push(@cur_char)

    # Check next character
    Error.new('Invalid float', @status) if (@next_type == :LETTER ||
                                            @next_type == :S_DOT)
    complete(:LIT_FLOAT, @buffer.join) if @next_type != :NUMBER
  end

  ##############################################################################
  # Process :STRING_SCOM state
  def process_string_scom
    if @state != :STRING_SCOM
      @state = :STRING_SCOM
      return # Don't save first comma symbol
    end

    case @cur_type
    when :S_SCOM
      complete(:LIT_STR, @buffer.join)
    when :S_NL, :S_CR
      Error.new('No string end was found', @status)
    when :S_ESC
      @old_state = @state
      @state = :ESCAPE
    else
      @buffer.push(@cur_char)

      if @next_type == :S_SCOM
        complete(:LIT_STR, @buffer.join)
        @skip_next = true
        @state = :DEFAULT
      end
    end
  end

  ##############################################################################
  # Process :STRING_DCOM state
  def process_string_dcom
    if @state != :STRING_DCOM
      @state = :STRING_DCOM
      return # Don't save first comma symbol
    end

    case @cur_type
    when :S_DCOM
      complete(:LIT_STR, @buffer.join)
    when :S_NL, :S_CR
      Error.new('No string end was found', @status)
    when :S_ESC
      @old_state = @state
      @state = :ESCAPE
    else
      @buffer.push(@cur_char)

      if @next_type == :S_DCOM
        complete(:LIT_STR, @buffer.join)
        @skip_next = true
      end
    end
  end

  ##############################################################################
  # Process :ESCAPE state
  def process_escape
    Error.new('No string end was found', @status) if (@cur_type == :S_NL ||
                                                      @cur_type == :S_CR)
    case @cur_char
    when 'n'
      sym = "*NEWLINE*"
      @buffer.concat(sym.split)
    when 'r'
      sym = "*CARRIAGE*"
      @buffer.concat(sym.split)
    when "\\", "'", "\""
      @buffer.push(@cur_char)
    else
      Error.new('Unknown symbol is escaped', @status)
    end

    @state = @old_state
  end

  ##############################################################################
  # Process :COMMENT state
  def process_comment
    @state = :COMMENT

    if @next_type == :S_NL || @next_type == :S_CR
      @state = :DEFAULT
    end
  end
end
