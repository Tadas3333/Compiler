class Keywords
  def initialize
  end

  def get_keyword(ident)
    case ident
    when 'jei'; return :KW_IF
    when 'kitjei'; return :KW_ELSEIF
    when 'kitaip'; return :KW_ELSE
    when 'int'; return :KW_INT
    when 'float'; return :KW_FLOAT
    when 'char'; return :KW_CHAR
    when 'pakolei'; return :KW_WHILE
    when 'nutraukti'; return :KW_BREAK
    when 'testi'; return :KW_CONTINUE
    when 'grazinti'; return :KW_RETURN
    else; return :IDENT
    end
  end
end
