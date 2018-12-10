class Parser
  def parse_expression
    left = parse_operator_and

    while @cur_token.name == :OP_DOR
      retrn_tkn = @cur_token
      next_token
      right = parse_operator_and
      left = BinaryExpression.new(retrn_tkn.name, left, right)
    end

    left
  end

  def parse_operator_and
    left = parse_relational

    while @cur_token.name == :OP_DAND
      retrn_tkn = @cur_token
      next_token
      right = parse_relational
      left = BinaryExpression.new(retrn_tkn.name, left, right)
    end

    left
  end

  def parse_relational
    left = parse_math

    while [:OP_DE, :OP_GE, :OP_LE, :OP_NE, :OP_G, :OP_L].include?(@cur_token.name)
      retrn_tkn = @cur_token
      next_token
      right = parse_math
      left = BinaryExpression.new(retrn_tkn.name, left, right)
    end

    left
  end

  def parse_math
    left = parse_term

    while [:OP_PLUS, :OP_MINUS].include?(@cur_token.name)
      retrn_tkn = @cur_token
      next_token
      right = parse_term
      left = BinaryExpression.new(retrn_tkn.name, left, right)
    end

    left
  end

  def parse_term
    left = parse_unary

    while [:OP_MULTIPLY, :OP_DIVIDE, :OP_MOD].include?(@cur_token.name)
      retrn_tkn = @cur_token
      next_token
      right = parse_unary
      left = BinaryExpression.new(retrn_tkn.name, left, right)
    end

    left
  end

  def parse_unary
    return parse_factor unless [:OP_MINUS, :OP_N, :OP_PLUS].include?(@cur_token.name)

    oper = @cur_token.name
    next_token
    return UnaryExpression.new(oper, parse_unary)
  end

  def parse_factor
    case @cur_token.name
    when :OP_PAREN_O
      next_token
      expr = parse_expression
      expect(:OP_PAREN_C)
      return expr
    when :IDENT
      if peek == :OP_PAREN_O
        return parse_function_call
      else
        tkn = expect(:IDENT)
        return VarExpression.new(tkn)
      end
    when :BOOL
      tkn = expect(:BOOL)
      return ConstBoolExpression.new(tkn)
    when :LIT_STR
      tkn = expect(:LIT_STR)
      return ConstStringExpression.new(tkn)
    else
      return parse_constant
    end
  end

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
