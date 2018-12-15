
class Parser
  def parse_function_statement
    f_type = parse_type
    f_pointer_depth = 0

    while @cur_token.name == :OP_MULTIPLY do
      f_pointer_depth += 1
      next_token
    end

    f_ident = expect(:IDENT)
    params = Parameters.new

    expect(:OP_PAREN_O)

    if @cur_token.name != :OP_PAREN_C
      p_type = parse_type
      pointer_depth = 0

      while @cur_token.name == :OP_MULTIPLY
        pointer_depth += 1
        next_token
      end

      p_ident = expect(:IDENT)
      p_value = nil

      if @cur_token.name == :OP_E
        next_token
        p_value = parse_expression
      end

      params.add_parameter(Parameter.new(p_type, p_ident, p_value, pointer_depth))
    end

    while @cur_token.name != :OP_PAREN_C
      expect(:S_COM)
      p_type = parse_type

      pointer_depth = 0

      while @cur_token.name == :OP_MULTIPLY
        pointer_depth += 1
        next_token
      end

      p_ident = expect(:IDENT)
      p_value = nil

      if @cur_token.name == :OP_E
        next_token
        p_value = parse_expression
      end

      params.add_parameter(Parameter.new(p_type, p_ident, p_value, pointer_depth))
    end

    next_token
    f_statements = parse_statement_region
    return FunctionDefinition.new(f_ident, params, f_type, f_pointer_depth, f_statements)
  end

  def parse_statement_region
    expect(:OP_BRACE_O)

    node = StatementsRegion.new

    while @cur_token.name != :OP_BRACE_C
      node.add_statement(parse_statement)
    end

    next_token
    return node
  end

  def parse_statement
    case @cur_token.name
    when :KW_IF
      return parse_if_statement
    when :KW_WHILE
      return parse_while_statement
    when :KW_BREAK, :KW_CONTINUE, :KW_RETURN
      return parse_jump_statement
    when :IDENT
      if peek == :OP_E || peek == :OP_SQBR_O
        return parse_assignment_statement
      else
        return parse_expression_statement
      end
    when :KW_INT, :KW_FLOAT, :KW_TYPE_BOOL, :KW_VOID, :KW_STRING
      return parse_declaration_statement
    else
      return parse_expression_statement
    end
  end

  def parse_expression_statement
    c_expr = parse_expression
    expect(:S_SCOL)
    return c_expr
  end

  def parse_assignment_statement
    s_ident = expect(:IDENT)

    index_exprs = nil

    if @cur_token.name == :OP_SQBR_O
      index_exprs = []

      while @cur_token.name == :OP_SQBR_O
        next_token
        index_exprs << parse_expression
        expect(:OP_SQBR_C)
      end
    end

    expect(:OP_E)
    s_exp = parse_expression
    expect(:S_SCOL)
    return AssignmentStatement.new(s_ident, index_exprs, s_exp)
  end

  def parse_declaration_statement
    v_type = parse_type

    if @cur_token.name == :OP_MULTIPLY
      case v_type
      when :LIT_INT; v_type = :INT_POINTER
      when :LIT_FLOAT; v_type = :FLOAT_POINTER
      when :LIT_STR; v_type = :STRING_POINTER
      when :BOOL; v_type = :BOOL_POINTER
      when :VOID; token_error('void pointer')
      else raise 'unknown type'
      end
    end

    pointer_depth = 0

    while @cur_token.name == :OP_MULTIPLY
      pointer_depth += 1
      next_token
    end

    v_name = expect(:IDENT)
    v_expr = nil

    if @cur_token.name == :OP_E
      next_token
      v_expr = parse_expression
      expect(:S_SCOL)
    else
      expect(:S_SCOL)
    end

    return DeclarationStatement.new(v_type, v_name, v_expr, pointer_depth)
  end

  def parse_if_statement
    branches = []
    expect(:KW_IF)
    expect(:OP_PAREN_O)
    s_expr = parse_expression
    expect(:OP_PAREN_C)
    s_statements = parse_statement_region

    branches.push(Branch.new(s_expr, s_statements));

    while @cur_token.name == :KW_ELSEIF
      branches.push(parse_elseif_statement)
    end

    else_statement = nil

    if @cur_token.name == :KW_ELSE
      else_statement = parse_else_statement
    end

    return IfStatement.new(branches, else_statement)
  end

  def parse_elseif_statement
    expect(:KW_ELSEIF)
    expect(:OP_PAREN_O)
    s_expr = parse_expression
    expect(:OP_PAREN_C)
    s_statements = parse_statement_region

    return Branch.new(s_expr, s_statements)
  end

  def parse_else_statement
    expect(:KW_ELSE)
    s_statements = parse_statement_region

    return ElseStatement.new(s_statements)
  end

  def parse_while_statement
    expect(:KW_WHILE)
    expect(:OP_PAREN_O)
    s_expr = parse_expression
    expect(:OP_PAREN_C)
    s_statements = parse_statement_region

    return WhileStatement.new(s_expr, s_statements)
  end

  def parse_jump_statement
    case @cur_token.name
    when :KW_BREAK
      token = expect(:KW_BREAK)
      expect(:S_SCOL)
      return BreakStatement.new(token)
    when :KW_CONTINUE
      token = expect(:KW_CONTINUE)
      expect(:S_SCOL)
      return ContinueStatement.new(token)
    when :KW_RETURN
      token = expect(:KW_RETURN)
      s_expr = nil

      if @cur_token.name != :S_SCOL
        s_expr = parse_expression
      end

      expect(:S_SCOL)
      return ReturnStatement.new(token, s_expr)
    else
      token_error("Unexpected type! Found #{@cur_token.name}")
    end


  end
end
