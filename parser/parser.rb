
require_relative '../token'
require_relative '../status'
require_relative '../error'

class Parser
  def initialize(tokens)
    @tokens = tokens
    @index = 0
    @cur_token = @tokens[@index]
    @indent = 0
  end

  # <start> ::= <statements> EOF
  # <statements> ::= <statement> {<statement>}
  def parse_program
    @indent += 1
    while @cur_token.name != :EOF
      parse_statement
    end
    @indent -= 1
  end

  def accept(name)
    return if @cur_token.name != name

    next_token
  end

  def expect(name)
    if @cur_token.name != name
      token_error("Expected #{name}, found #{@cur_token.name}")
      return
    end

    next_token
  end

  def next_token
    @index += 1
    @cur_token = @tokens[@index]
  end

  def token_error(message)
    Error.new(message, Status.new(@cur_token.file_name, @cur_token.line))
  end

  def print_method(name)
    puts "  " * @indent + name + " (#{@cur_token.name})"
  end

  ##############################################################################
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
    when :IDENT; parse_function_call_variable_assignment
    when :KW_INT, :KW_FLOAT, :KW_STRING; parse_variable_function_declaration
    else
      token_error("Unexpected type! Got #{@cur_token.name}!")
    end
    @indent -= 1
  end

=begin
<function-call-variable-assignment> ::= <identifier> <function-call-args>
			| <identifier> "=" <unary-expression> ";"
			| <identifier> "=" <string> ";"
=end
  def parse_function_call_variable_assignment
    @indent += 1
    print_method(__method__.to_s)

    parse_ident
    if @cur_token.name == :OP_E
      accept(@cur_token.name)
      if @cur_token.name == :LIT_STR
        parse_string
      else
        parse_unary_expression
      end
      expect(:S_SCOL)
    else
      parse_function_call_args
    end
    @indent -= 1
  end

=begin
<function-call-args> ::= "(" <call-args> ")" ";"
			| "(" ")" ";"
<call-args> ::= <unary-expression> {"," <unary-expression>}
=end
  def parse_function_call_args
    @indent += 1
    print_method(__method__.to_s)

    expect(:OP_PAREN_O)
    while accept(:OP_PAREN_C).nil?
      if @cur_token.name == :S_COM
        accept(@cur_token.name)
      end
      parse_unary_expression
    end
    expect(:S_SCOL)
    @indent -= 1
  end

=begin
<variable-function-declaration> ::=	 <type-and-ident> <funtion-declaration-args-and-block>
			| <type-and-ident> ";"
			| <type-and-ident> "=" <unary-expression> ";"
			| <type-and-ident> "=" <string> ";"
=end
  def parse_variable_function_declaration
    @indent += 1
    print_method(__method__.to_s)

    parse_type
    parse_ident
    if @cur_token.name == :OP_PAREN_O
      parse_function_declaration_args_and_block
    elsif @cur_token.name == :OP_E
      accept(@cur_token.name)

      if @cur_token.name == :LIT_STR
        parse_string
      else
        parse_unary_expression
      end
      expect(:S_SCOL)
    else
      expect(:S_SCOL)
    end
    @indent -= 1
  end

=begin
<funtion-declaration-args-and-block> ::= "(" <dec-args> ")" <statement-region>
			| "(" ")" <statement-region>
<dec-args> ::= <dec-arg> {"," <dec-arg>}
=end
  def parse_function_declaration_args_and_block
    @indent += 1
    print_method(__method__.to_s)

    expect(:OP_PAREN_O)

    while accept(:OP_PAREN_C).nil?
      if @cur_token.name == :S_COM
        accept(@cur_token.name)
      end
      parse_dec_arg
    end

    parse_statement_region
    @indent -= 1
  end

=begin
<dec-arg> ::= <unary-expression>
            | <type-and-ident>
            | <identifier>
=end
  def parse_dec_arg
    @indent += 1
    print_method(__method__.to_s)

    case @cur_token.name
    when :IDENT; parse_ident
    when :KW_INT, :KW_FLOAT, :KW_STRING
      parse_type
      parse_ident
      if @cur_token.name == :OP_E
        accept(@cur_token.name)
        parse_unary_expression
      end
    else; parse_unary_expression
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
    else
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
    else
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
      accept(@cur_token.name)
      expect(:S_SCOL)
    when :KW_RETURN
      accept(@cur_token.name)
      if @cur_token.name != :S_SCOL
        parse_unary_expression
      end
      expect(:S_SCOL)
    else; token_error("Unexpected type! Got #{@cur_token.name}!")
    end
    @indent -= 1
  end

=begin
<type> ::= "int"
            | "string"
            | "float"
=end
  def parse_type
    @indent += 1
    print_method(__method__.to_s)

    case @cur_token.name
    when :KW_INT; parse_kw_int
    when :KW_STRING; parse_kw_string
    when :KW_FLOAT; parse_kw_float
    else; token_error("Unexpected type! Got #{@cur_token.name}!")
    end
    @indent -= 1
  end

  def parse_ident
    @indent += 1
    print_method(__method__.to_s)

    expect(:IDENT)
    @indent -= 1
  end

  def parse_kw_string
    @indent += 1
    print_method(__method__.to_s)

    expect(:KW_STRING)
    @indent -= 1
  end

  def parse_kw_int
    @indent += 1
    print_method(__method__.to_s)

    expect(:KW_INT)
    @indent -= 1
  end

  def parse_kw_float
    @indent += 1
    print_method(__method__.to_s)

    expect(:KW_FLOAT)
    @indent -= 1
  end

  def parse_string
    @indent += 1
    print_method(__method__.to_s)

    expect(:LIT_STR)
    @indent -= 1
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
    while accept(:OP_PAREN_C).nil?
      parse_statement
    end
    @indent -= 1
  end

=begin
<unary-expression> ::= {<unary-symbol>} <expression>
<unary-symbol> ::= "-"
			| "!"
=end
  def parse_unary_expression
    @indent += 1
    print_method(__method__.to_s)

    if @cur_token.name == :OP_MINUS
      accept(@cur_token.name)
      parse_unary_expression
    elsif @cur_token.name == :OP_N
      accept(@cur_token.name)
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
      accept(@cur_token.name)
      parse_unary_expression
    when :OP_OR, :OP_DOR
      accept(@cur_token.name)
      parse_unary_expression
    else
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
      accept(@cur_token.name)
      parse_relational_exp
    else
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
      accept(@cur_token.name)
      parse_math
    else
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
      accept(@cur_token.name)
      parse_term
    else
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
        accept(@cur_token.name)
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
      accept(@cur_token.name)
    when :IDENT
      parse_ident_and_function_call
    else
      token_error("Unexpected type! Got #{@cur_token.name}!")
    end
    @indent -= 1
  end

=begin
<identifier-and-function-call> ::= <identifier>
			| <identifier> "(" ")"
			| <identifier> "(" <call-args> ")"
=end
  def parse_ident_and_function_call
    @indent += 1
    print_method(__method__.to_s)

    parse_ident

    if @cur_token.name == :OP_PAREN_O
      accept(@cur_token.name)

      while accept(:OP_PAREN_C).nil?
        if @cur_token.name == :S_COM
          accept(@cur_token.name)
        end
        parse_unary_expression
      end
    end

    @indent -= 1
  end

end
