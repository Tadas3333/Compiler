class Table
  def initialize
    @printed_count = 0
  end

  def table_top
    puts "ID\t|LN\t|TYPE\t\t|VALUE"
    puts "----------------------------------------"
  end

  def show(tokens, values, lines)
    index = 0
    tokens.each do |token|
      case token
      when :LIT_INT, :LIT_STRING, :LIT_FLOAT, :IDENT, :STRING
        if token.length > 6
          show_token_with_value_longtoken(token, lines[index], values[index])
        else
          show_token_with_value(token, lines[index], values[index])
        end
      else
        if token.length > 6
          show_token_longtoken(token, lines[index])
        else
          show_token(token, lines[index])
        end
      end

      index += 1
    end

  end

  def show_token(type, line)
    puts "#{@printed_count}\t|#{line}\t|#{type}\t\t|"
    @printed_count += 1
  end

  def show_token_longtoken(type, line)
    puts "#{@printed_count}\t|#{line}\t|#{type}\t|"
    @printed_count += 1
  end

  def show_token_with_value(type, line, value)
    puts "#{@printed_count}\t|#{line}\t|#{type}\t\t|#{value}"
    @printed_count += 1
  end

  def show_token_with_value_longtype(type, line, value)
    puts "#{@printed_count}\t|#{line}\t|#{type}\t|#{value}"
    @printed_count += 1
  end
end
