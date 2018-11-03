
class Parser
=begin
<function-statement> ::= <type> <identifier> "(" <declaration-arguments> ")" <statement-region>
			| <type> <identifier> "(" ")" <statement-region>
<declaration-arguments> ::= <declaration-argument> {<declaration-argument>}
=end
  def parse_function_statement
    @indent += 1
    print_method(__method__.to_s)

    parse_type
    parse_ident

    expect(:OP_PAREN_O)

    if @cur_token.name != :OP_PAREN_C
      parse_declaration_argument
    end

    while @cur_token.name != :OP_PAREN_C
      expect(:S_COM)
      parse_declaration_argument
    end

    next_token
    parse_statement_region

    @indent -= 1
  end

=begin
<declaration-argument> ::= <unary-expression>
            | <type> <identifier>
            | <identifier>
=end
  def parse_declaration_argument
    @indent += 1
    print_method(__method__.to_s)

    case @cur_token.name
    when :IDENT
      parse_ident
    when :KW_INT, :KW_FLOAT, :KW_STRING
      parse_type
      parse_ident

      if @cur_token.name == :OP_E
        next_token
        parse_unary_expression
      end

    else
      parse_unary_expression
    end

    @indent -=1
  end

=begin
<statement-region> ::= ":" "(" <statements> ")"
					 | ":" "(" ")"
<statements> ::= <statement> {<statement>}
=end
  def parse_statement_region
    @indent += 1
    print_method(__method__.to_s)

    expect(:S_COL)
    expect(:OP_PAREN_O)

    while @cur_token.name != :OP_PAREN_C
      parse_statement
    end

    next_token

    @indent -=1
  end

=begin
<statement> ::= <jei-statement>
      | <pakolei-statement>
			| <jump-statement>
			| <function-call-variable-assignment>
			| <variable-function-declaration>
=end
  def parse_statement
    @indent += 1
    print_method(__method__.to_s)

    case @cur_token.name
    when :KW_IF; parse_if_statement
    when :KW_WHILE; parse_while_statement
    when :KW_BREAK, :KW_CONTINUE, :KW_RETURN; parse_jump_statement
    when :IDENT; parse_call_and_assignment_statement
    when :KW_INT, :KW_FLOAT, :KW_STRING; parse_declaration_statement
    else; token_error("Unexpected type! Found #{@cur_token.name}")
    end

    @indent -= 1
  end

=begin
<call-and-assignment-statement> ::= <identifier> "(" <call-arguments> ")" ";"
			| <identifier> "(" ")" ";"
			| <identifier> "=" <unary-expression> ";"
			| <identifier> "=" <string> ";"
<call-arguments> ::= <unary-expression> {"," <unary-expression>}
=end
  def parse_call_and_assignment_statement
    @indent += 1
    print_method(__method__.to_s)

    parse_ident

    if @cur_token.name == :OP_E # Variable assignment statement
      next_token

      if @cur_token.name == :LIT_STR
        parse_string
      else
        parse_unary_expression
      end

      expect(:S_SCOL)
    else # Function call statement
      expect(:OP_PAREN_O)

      if @cur_token.name != :OP_PAREN_C
        parse_unary_expression
      end

      while @cur_token.name != :OP_PAREN_C
        expect(:S_COM)
        parse_unary_expression
      end

      next_token
      expect(:S_SCOL)
    end

    @indent -= 1
  end

=begin
<declaration-statement> ::= <type> <identifier> ";"
			| <type> <identifier> "=" <unary-expression> ";"
			| <type> <identifier> "=" <string> ";"

=end
  def parse_declaration_statement
    @indent += 1
    print_method(__method__.to_s)

    parse_type
    parse_ident

    if @cur_token.name == :OP_E # Variable declaration with assignment stmt
      next_token

      if @cur_token.name == :LIT_STR
        parse_string
      else
        parse_unary_expression
      end

      expect(:S_SCOL)
    else # Variable declaration statement
      expect(:S_SCOL)
    end

    @indent -= 1
  end

=begin
<jei-statement> ::= "jei" "(" <unary-expression> ")" <statement-region>
            | "jei" "(" <unary-expression> ")" <statement-region> <kitaip-jei-statement>
            | "jei" "(" <unary-expression> ")" <statement-region> <kitaip-statement>
=end
  def parse_if_statement
    @indent += 1
    print_method(__method__.to_s)

    expect(:KW_IF)
    expect(:OP_PAREN_O)
    parse_unary_expression
    expect(:OP_PAREN_C)
    parse_statement_region

    case @cur_token.name
    when :KW_ELSEIF; parse_elseif_statement
    when :KW_ELSE; parse_else_statement
    end

    @indent -= 1
  end

=begin
<kitaip-jei-statement> ::= "kitaip-jei" "(" <unary-expression> ")" <statement-region>
            | "kitaip-jei" "(" <unary-expression> ")" <statement-region> <kitaip-jei-statement>
            | "kitaip-jei" "(" <unary-expression> ")" <statement-region> <kitaip-statement>
=end
  def parse_elseif_statement
    @indent += 1
    print_method(__method__.to_s)

    expect(:KW_ELSEIF)
    expect(:OP_PAREN_O)
    parse_unary_expression
    expect(:OP_PAREN_C)
    parse_statement_region

    case @cur_token.name
    when :KW_ELSEIF; parse_elseif_statement
    when :KW_ELSE; parse_else_statement
    end

    @indent -= 1
  end

=begin
<kitaip-statement> ::= "kitaip" <statement-region>
=end
  def parse_else_statement
    @indent += 1
    print_method(__method__.to_s)

    expect(:KW_ELSE)
    parse_statement_region

    @indent -= 1
  end

=begin
<pakolei-statement> ::= "pakolei" "(" <unary-expression> ")" <statement-region>
=end
  def parse_while_statement
    @indent += 1
    print_method(__method__.to_s)

    expect(:KW_WHILE)
    expect(:OP_PAREN_O)
    parse_unary_expression
    expect(:OP_PAREN_C)
    parse_statement_region

    @indent -= 1
  end

=begin
<jump-statement> ::= "nutraukti" ";"
            | "testi" ";"
			| "grazinti" ";"
			| "grazinti" <unary-expression> ";"
=end
  def parse_jump_statement
    @indent += 1
    print_method(__method__.to_s)

    case @cur_token.name
    when :KW_BREAK, :KW_CONTINUE
      next_token
      expect(:S_SCOL)
    when :KW_RETURN
      next_token

      if @cur_token.name != :S_SCOL
        parse_unary_expression
      end

      expect(:S_SCOL)
    else
      token_error("Unexpected type! Found #{@cur_token.name}")
    end

    @indent -= 1
  end
end
