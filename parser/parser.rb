
require_relative '../token'
require_relative '../status'
require_relative '../error'
require_relative 'parser_statements'
require_relative 'parser_expressions'
require_relative 'ast_statements'
require_relative 'ast_expressions'

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
    node = Program.new

    while @cur_token.name != :EOF
      node.add_function(parse_function_statement)
    end

    node
  end

  def expect(name)
    if @cur_token.name != name
      token_error("Expected #{name}, found #{@cur_token.name}")
      return
    end

    token_to_r = @cur_token
    next_token
    return token_to_r
  end

  def peek
    @index += 1
    tkn = @tokens[@index]
    @index -= 1
    tkn.name
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
            | "bool"
            | "void"
=end
  def parse_type
    case @cur_token.name
    when :KW_INT
      next_token
      return :LIT_INT
    when :KW_STRING
      next_token
      return :LIT_STR
    when :KW_FLOAT
      next_token
      return :LIT_FLOAT
    when :KW_VOID
      next_token
      return :VOID
    when :KW_TYPE_BOOL
      next_token
      return :BOOL
    else; token_error("Unexpected type! Found #{@cur_token.name}")
    end
  end
end
