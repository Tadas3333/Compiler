
class Parser
=begin
<function-statement> ::= <type> <identifier> "(" <parameters> ")" <statement-region>
			| <type> <identifier> "(" ")" <statement-region>
<parameters> ::= <type> <identifier> {"," <type> <identifier>}
=end
  def parse_function_statement
    f_type = parse_type
    f_ident = expect(:IDENT)
    params = Parameters.new

    expect(:OP_PAREN_O)

    if @cur_token.name != :OP_PAREN_C
      p_type = parse_type
      p_ident = expect(:IDENT)
      p_value = nil

      if @cur_token.name == :OP_E
        next_token
        p_value = parse_expression
      end

      params.add_parameter(Parameter.new(p_type, p_ident, p_value))
    end

    while @cur_token.name != :OP_PAREN_C
      expect(:S_COM)
      p_type = parse_type
      p_ident = expect(:IDENT)
      p_value = nil

      if @cur_token.name == :OP_E
        next_token
        p_value = parse_expression
      end

      params.add_parameter(Parameter.new(p_type, p_ident, p_value))
    end

    next_token
    f_statements = parse_statement_region
    return FunctionDefinition.new(f_ident, params, f_type, f_statements)
  end

=begin
<statement-region> ::= ":" "(" <statements> ")"
					 | ":" "(" ")"
<statements> ::= <statement> {<statement>}
=end
  def parse_statement_region
    expect(:OP_BRACE_O)

    node = StatementsRegion.new

    while @cur_token.name != :OP_BRACE_C
      node.add_statement(parse_statement)
    end

    next_token
    return node
  end

=begin
<statement> ::= <jei-statement>
            | <pakolei-statement>
      			| <jump-statement>
      			| <call-statement>
      			| <assignment-statement>
      			| <declaration-statement>
=end
  def parse_statement
    case @cur_token.name
    when :KW_IF
      return parse_if_statement
    when :KW_WHILE
      return parse_while_statement
    when :KW_BREAK, :KW_CONTINUE, :KW_RETURN
      return parse_jump_statement
    when :IDENT
      if peek == :OP_E
        return parse_assignment_statement
      else
        return parse_call_statement
      end
    when :KW_INT, :KW_FLOAT, :KW_STRING
      return parse_declaration_statement
    else
      token_error("Unexpected type! Found #{@cur_token.name}")
    end
  end

=begin
<call-statement> ::= <function-call> ";"
=end
  def parse_call_statement
    c_expr = parse_function_call
    expect(:S_SCOL)
    return c_expr
  end

=begin
<assignment-statement> ::= <identifier> "=" <expression> ";"
=end
  def parse_assignment_statement
    s_ident = expect(:IDENT)
    expect(:OP_E)
    s_exp = parse_expression
    expect(:S_SCOL)
    return AssignmentStatement.new(s_ident, s_exp)
  end

=begin
<declaration-statement> ::=	 | <type> <identifier> ";"
			| <type> <identifier> "=" <expression> ";"
=end
  def parse_declaration_statement
    v_type = parse_type
    v_name = expect(:IDENT)
    v_expr = nil

    if @cur_token.name == :OP_E
      next_token
      v_expr = parse_expression
      expect(:S_SCOL)
    else
      expect(:S_SCOL)
    end

    return DeclarationStatement.new(v_type, v_name, v_expr)
  end

=begin
<jei-statement> ::= "jei" "(" <expression> ")" <statement-region>
            | "jei" "(" <expression> ")" <statement-region> <kitaip-jei-statement>
            | "jei" "(" <expression> ")" <statement-region> <kitaip-statement>
=end
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

=begin
<kitaip-jei-statement> ::= "kitaip-jei" "(" <expression> ")" <statement-region>
            | "kitaip-jei" "(" <expression> ")" <statement-region> <kitaip-jei-statement>
            | "kitaip-jei" "(" <expression> ")" <statement-region> <kitaip-statement>
=end
  def parse_elseif_statement
    expect(:KW_ELSEIF)
    expect(:OP_PAREN_O)
    s_expr = parse_expression
    expect(:OP_PAREN_C)
    s_statements = parse_statement_region

    return Branch.new(s_expr, s_statements)
  end

=begin
<kitaip-statement> ::= "kitaip" <statement-region>
=end
  def parse_else_statement
    expect(:KW_ELSE)
    s_statements = parse_statement_region

    return ElseStatement.new(s_statements)
  end

=begin
<pakolei-statement> ::= "pakolei" "(" <expression> ")" <statement-region>
=end
  def parse_while_statement
    expect(:KW_WHILE)
    expect(:OP_PAREN_O)
    s_expr = parse_expression
    expect(:OP_PAREN_C)
    s_statements = parse_statement_region

    return WhileStatement.new(s_expr, s_statements)
  end

=begin
<jump-statement> ::= "nutraukti" ";"
            | "testi" ";"
			| "grazinti" ";"
			| "grazinti" <expression> ";"
=end
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
