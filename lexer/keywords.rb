class Keywords
  def initialize
  end

  def get_keyword(ident)
    case ident
    when 'if'; return :KW_IF
    when 'elseif'; return :KW_ELSEIF
    when 'else'; return :KW_ELSE
    when 'int'; return :KW_INT
    when 'float'; return :KW_FLOAT
    when 'string'; return :KW_STRING
    when 'void'; return :KW_VOID
    when 'bool'; return :KW_TYPE_BOOL
    when 'true', 'false'; return :BOOL
    when 'while'; return :KW_WHILE
    when 'break'; return :KW_BREAK
    when 'continue'; return :KW_CONTINUE
    when 'return'; return :KW_RETURN
    else; return :IDENT
    end
  end
end
