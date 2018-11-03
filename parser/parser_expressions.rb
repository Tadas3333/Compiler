class Parser
=begin
<unary-expression> ::= {<unary-symbol>} <expression>
<unary-symbol> ::= "-"
			| "!"
=end
  def parse_unary_expression
    @indent += 1
    print_method(__method__.to_s)

    if @cur_token.name == :OP_MINUS
      next_token
      parse_unary_expression
    elsif @cur_token.name == :OP_N
      next_token
      parse_unary_expression
    else
      parse_expression
    end

    @indent -= 1
  end

=begin
<expression> ::= <relational-exp> {<logical-symbol> <unary-expression>}
=end
  def parse_expression
    @indent += 1
    print_method(__method__.to_s)

    parse_relational_exp

    case @cur_token.name
    when :OP_AND, :OP_DAND
      next_token
      parse_unary_expression
    when :OP_OR, :OP_DOR
      next_token
      parse_unary_expression
    end

    @indent -= 1
  end

=begin
<relational-exp> ::= <math> {<relational-symbol> <math>}
=end
  def parse_relational_exp
    @indent += 1
    print_method(__method__.to_s)

    parse_math

    case @cur_token.name
    when :OP_DE, :OP_GE, :OP_LE, :OP_NE, :OP_G, :OP_L
      next_token
      parse_relational_exp
    end

    @indent -= 1
  end

=begin
<math> ::= <term> {"+"|"-" <term>}
=end
  def parse_math
    @indent += 1
    print_method(__method__.to_s)

    parse_term

    case @cur_token.name
    when :OP_PLUS, :OP_MINUS
      next_token
      parse_math
    end

    @indent -= 1
  end

=begin
<term> ::= <factor> {"*"|"/" <factor>}
=end
  def parse_term
    @indent += 1
    print_method(__method__.to_s)

    parse_factor

    case @cur_token.name
    when :OP_MULTIPLY, :OP_DIVIDE
      next_token
      parse_term
    end

    @indent -= 1
  end

=begin
<factor> ::= "(" <unary-expression> ")""
            | <constant>
=end
  def parse_factor
    @indent += 1
    print_method(__method__.to_s)

    if @cur_token.name == :OP_PAREN_O
      next_token
      parse_unary_expression
      expect(:OP_PAREN_C)
    else
      parse_constant
    end

    @indent -= 1
  end

=begin
<constant> ::= <digits>
            | <digits> "." <digits>
            | <digits> "."
            | "." <digits>
			      | <identifier-and-function-call>
=end
  def parse_constant
    @indent += 1
    print_method(__method__.to_s)

    case @cur_token.name
    when :LIT_INT, :LIT_FLOAT
      next_token
    when :IDENT
      parse_ident_and_function_call
    else
      token_error("Unexpected type! Found #{@cur_token.name}")
    end

    @indent -= 1
  end

=begin
<identifier-and-function-call> ::= <identifier>
			| <identifier> "(" ")"
			| <identifier> "(" <call-arguments> ")"
=end
  def parse_ident_and_function_call
    @indent += 1
    print_method(__method__.to_s)

    parse_ident

    if @cur_token.name == :OP_PAREN_O
      next_token

      if @cur_token.name != :OP_PAREN_C
        parse_unary_expression
      end

      while @cur_token.name != :OP_PAREN_C
        expect(:S_COM)
        parse_unary_expression
      end

      next_token
    end
    
    @indent -= 1
  end
end
