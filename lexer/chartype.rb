require_relative '../error'

class CharType
  attr_reader :type

  def initialize(char, status)
    case char
    when 'a'..'z', 'A'..'Z'; @type = :LETTER
    when '0'..'9'; @type = :NUMBER
    when ' '; @type = :SPACE
    when ';'; @type = :S_SEMICOL
    when '.'; @type = :S_DOT
    when '&'; @type = :OP_AND
    when '|'; @type = :OP_OR
    when "\\"; @type = :S_ESC
    when "'"; @type = :S_SCOM
    when "\""; @type = :S_DCOM
    when '+'; @type = :OP_PLUS
    when '-'; @type = :OP_MINUS
    when '/'; @type = :OP_DIVIDE
    when '*'; @type = :OP_MULTIPLY
    when '='; @type = :OP_E
    when '>'; @type = :OP_G
    when '<'; @type = :OP_L
    when '!'; @type = :OP_N
    when ','; @type = :S_COM
    when ':'; @type = :S_COL
    when '@'; @type = :S_AT
    when '$'; @type = :S_DOL
    when '('; @type = :OP_PAREN_O
    when ')'; @type = :OP_PAREN_C
    when '{'; @type = :OP_BRACE_O
    when '}'; @type = :OP_BRACE_C
    when "\n"; @type = :S_NL
    when "\r"; @type = :S_CR
    when :EOF; @type = :S_EOF
    else; Error.new("Unknown character '#{char}' type", status)
    end
  end
end
