class Parser
=begin
<expression> ::= <operator-and> {"||" <operator-and>}
=end
  def parse_expression
    left = parse_operator_and

    while @cur_token.name == :OP_DOR
      retrn_tkn = @cur_token
      next_token
      right = parse_operator_and
      left = LogicalExpression.new(retrn_tkn.name, left, right)
    end

    left
  end

=begin
<operator-and> ::= <relational> {"&&" <relational>}
=end
  def parse_operator_and
    left = parse_relational

    while @cur_token.name == :OP_DAND
      retrn_tkn = @cur_token
      next_token
      right = parse_relational
      left = LogicalExpression.new(retrn_tkn.name, left, right)
    end

    left
  end

=begin
<relational> ::= <math> {<relational-symbol> <math>}
=end
  def parse_relational
    left = parse_math

    while [:OP_DE, :OP_GE, :OP_LE, :OP_NE, :OP_G, :OP_L].include?(@cur_token.name)
      retrn_tkn = @cur_token
      next_token
      right = parse_math
      left = RelationalExpression.new(retrn_tkn.name, left, right)
    end

    left
  end

=begin
<math> ::= <term> {"+"<term>, "-" <term>}
=end
  def parse_math
    left = parse_term

    while [:OP_PLUS, :OP_MINUS].include?(@cur_token.name)
      retrn_tkn = @cur_token
      next_token
      right = parse_term
      left = ArithmeticExpression.new(retrn_tkn.name, left, right)
    end

    left
  end

=begin
<term> ::= <unary> {"*" <unary>,"/" <unary>}
=end
  def parse_term
    left = parse_unary

    while [:OP_MULTIPLY, :OP_DIVIDE].include?(@cur_token.name)
      retrn_tkn = @cur_token
      next_token
      right = parse_unary
      left = ArithmeticExpression.new(retrn_tkn.name, left, right)
    end

    left
  end

=begin
<unary> ::= <factor>
            | {"-","!","+"} <factor>
=end
  def parse_unary
    return parse_factor unless [:OP_MINUS, :OP_N, :OP_PLUS].include?(@cur_token.name)

    node = nil
    first_node = nil

    while [:OP_MINUS, :OP_N, :OP_PLUS].include?(@cur_token.name)
      if node != nil
        new_node = UnaryExpression.new(@cur_token.name, nil)
        node.factor = new_node
        node = new_node
      else
        first_node = UnaryExpression.new(@cur_token.name, nil)
        node = first_node
      end
      next_token
    end

    token_error("No unary expression found!") if node == nil || first_node == nil

    node.factor = parse_factor
    first_node
  end

=begin
<factor> ::= "(" <expression> ")""
            | <constant>
            | <identifier>
            | <function-call>
            | <string>
=end
  def parse_factor
    case @cur_token.name
    when :OP_PAREN_O
      next_token
      expr = parse_expression
      expect(:OP_PAREN_C)
      return BraceExpression.new(expr)
    when :IDENT
      if peek == :OP_PAREN_O
        return parse_function_call
      else
        tkn = expect(:IDENT)
        return VarExpression.new(tkn)
      end
    when :LIT_STR
      tkn = expect(:LIT_STR)
      return ConstStringExpression.new(tkn)
    else
      return parse_constant
    end
  end

=begin
<function-call> ::= <identifier> "(" ")"
			| <identifier> "(" <arguments> ")"
<arguments> ::= <expression> {"," <expression>}
=end
  def parse_function_call
    s_ident = expect(:IDENT)
    expect(:OP_PAREN_O)
    arguments = []

    if @cur_token.name != :OP_PAREN_C
      arguments.push(parse_expression)
    end

    while @cur_token.name != :OP_PAREN_C
      expect(:S_COM)
      arguments.push(parse_expression)
    end

    next_token
    return CallExpression.new(s_ident, arguments)
  end

=begin
<constant> ::= <digits>
            | <digits> "." <digits>
            | <digits> "."
            | "." <digits>
=end
  def parse_constant
    case @cur_token.name
    when :LIT_INT
      return_token = @cur_token
      next_token
      return ConstIntExpression.new(return_token)
    when :LIT_FLOAT
      return_token = @cur_token
      next_token
      return ConstFloatExpression.new(return_token)
    else
      token_error("Unexpected type! Found #{@cur_token.name}")
    end
  end
end
