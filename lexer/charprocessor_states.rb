require_relative 'keywords'

class CharProcessor
  # Process :DEFAULT state
  def process_default
    @buffer = "";

    case @cur_char
    when 'a'..'z', 'A'..'Z'; process_ident
    when '0'..'9'; process_lit_int
    when "'"; process_string_scom
    when "\""; process_string_dcom
    when '&'; process_and
    when '|'; process_or
    when '>'; process_relational(:OP_G, :OP_GE)
    when '<'; process_relational(:OP_L, :OP_LE)
    when '='; process_relational(:OP_E, :OP_DE)
    when '!'; process_relational(:OP_N, :OP_NE)
    when '+'; complete(:OP_PLUS, nil)
    when '-'; complete(:OP_MINUS, nil)
    when '*'; complete(:OP_MULTIPLY, nil)
    when '%'; complete(:OP_MOD, nil)
    when ','; complete(:S_COM, nil)
    when ':'; complete(:S_COL, nil)
    when ';'; complete(:S_SCOL, nil)
    when '@'; complete(:S_AT, nil)
    when '$'; complete(:S_DOL, nil)
    when '('; complete(:OP_PAREN_O, nil)
    when ')'; complete(:OP_PAREN_C, nil)
    when '{'; complete(:OP_BRACE_O, nil)
    when '}'; complete(:OP_BRACE_C, nil)
    when '_'; complete(:S_UND, nil)
    when "\\"; complete(:S_ESC, nil)
    when "\n", "\r"; process_new_line
    when " ", :S_EOF, :NON; # Do nothing
    when '/'
      if @next_char == '/'
        process_single_line_comment
        @skip_next = true
      elsif @next_char == '*'
        process_multi_line_comment
        @skip_next = true
      else
        complete(:OP_DIVIDE, nil)
      end
    when '.'
      case @next_char
      when'0'..'9'
        process_lit_float
      else
        complete(:S_DOT, nil)
      end
    else; raise "Unprocessed character #{@cur_char}"
    end
  end

  ##############################################################################
  # Process :IDENT state
  def process_ident
    @state = :IDENT

    # Add current character to the buffer
    @buffer += @cur_char

    # Check next character
    case @next_char
    when 'a'..'z', 'A'..'Z', '0'..'9', '_'
      # Do nothing
    else
      keywords = Keywords.new
      type = keywords.get_keyword(@buffer)

      if type != :IDENT && type != :BOOL
        complete(type, nil)
      else
        complete(type, @buffer)
      end
    end
  end

  ##############################################################################
  # Process :LIT_INT state
  def process_lit_int
    @state = :LIT_INT

    # Add current character to the buffer
    @buffer += @cur_char

    # Check next character
    case @next_char
    when 'a'..'z', 'A'..'Z'
      Error.new('Invalid integer', @status)
    when '.'
        @state = :LIT_FLOAT
    when '0'..'9'
      # Do nothing
    else
      complete(:LIT_INT, @buffer.to_i)
    end
  end

  ##############################################################################
  # Process :LIT_FLOAT state
  def process_lit_float
    @state = :LIT_FLOAT

    # Add current character to the buffer
    @buffer += @cur_char

    # Check next character
    case @next_char
    when 'a'..'z', 'A'..'Z', '.'
      Error.new('Invalid float', @status)
    when '0'..'9'
      # Do nothing
    else
      complete(:LIT_FLOAT, @buffer.to_f)
    end
  end

  ##############################################################################
  # Process :STRING_SCOM state
  def process_string_scom
    if @state != :STRING_SCOM
      @state = :STRING_SCOM
      return # Don't save first comma symbol
    end

    case @cur_char
    when "'"
      complete(:LIT_STR, @buffer)
    when "\n", "\r"
      Error.new('No string end was found', @status)
    when "\\"
      @old_state = @state
      @state = :ESCAPE
    else
      @buffer += @cur_char

      if @next_char == "'"
        complete(:LIT_STR, @buffer)
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

    case @cur_char
    when "\""
      complete(:LIT_STR, @buffer)
    when "\n", "\r"
      Error.new('No string end was found', @status)
    when "\\"
      @old_state = @state
      @state = :ESCAPE
    else
      @buffer += @cur_char

      if @next_char == "\""
        complete(:LIT_STR, @buffer)
        @skip_next = true
      end
    end
  end

  ##############################################################################
  # Process :ESCAPE state
  def process_escape
    Error.new('No string end was found', @status) if (@cur_char == "\n" ||
                                                      @cur_char == "\r")
    case @cur_char
    when 'n'
      @buffer += "\n"
    when 'r'
      @buffer += "\r"
    when "\\", "'", "\""
      @buffer += @cur_char
    else
      Error.new('Unknown symbol is escaped', @status)
    end

    @state = @old_state
  end

  ##############################################################################
  # Process :SL_COMMENT state
  def process_single_line_comment
    @state = :SL_COMMENT

    if @next_char == "\n" || @next_char == "\r"
      @state = :DEFAULT
    end
  end

  ##############################################################################
  # Process :SL_COMMENT state
  def process_multi_line_comment
    @state = :ML_COMMENT

    if @cur_char == "*" && @next_char == "/"
      @state = :DEFAULT
      @skip_next = true
    elsif @cur_char == "\n" || @cur_char == "\r"
      process_new_line
    end
  end
end
