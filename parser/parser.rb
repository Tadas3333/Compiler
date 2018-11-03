
require_relative '../token'
require_relative '../status'
require_relative '../error'
require_relative 'parser_statements'
require_relative 'parser_expressions'
require_relative 'abstract_syntax_tree'

class Parser
  def initialize(tokens)
    @tokens = tokens
    @index = 0
    @cur_token = @tokens[@index]
    @indent = 0;
  end

  # <start> ::= <functions> EOF
  # <functions> ::= <function-statement> {<function-statement>}
  def parse_program
    while @cur_token.name != :EOF
      parse_function_statement
    end
    puts "Parse success!"
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
    puts "  " * @indent + "#{name} (#{@cur_token.name})"
  end

  ##############################################################################

=begin
<type> ::= "int"
            | "string"
            | "float"
=end
  def parse_type
    case @cur_token.name
    when :KW_INT;parse_kw_int
    when :KW_STRING; parse_kw_string
    when :KW_FLOAT; parse_kw_float
    else; token_error("Unexpected type! Found #{@cur_token.name}")
    end
  end

  def parse_ident
    expect(:IDENT)
  end

  def parse_kw_string
    expect(:KW_STRING)
  end

  def parse_kw_int
    expect(:KW_INT)
  end

  def parse_kw_float
    expect(:KW_FLOAT)
  end

  def parse_string
    expect(:LIT_STR)
  end
end
