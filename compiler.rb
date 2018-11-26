require_relative 'lexer/lexer'
require_relative 'parser/parser'
require_relative 'parser/ast_printer'
require_relative 'parser/check_scope'
require_relative 'parser/check_types'
require_relative 'parser/check_structure'

if ARGV[0] == nil
  puts "No file specified."
  exit
end

lx = Lexer.new(ARGV[0], false)
tokens = lx.get_tokens

ps = Parser.new(tokens)
root = ps.parse_program

#tp = AstPrinter.new
#tp.print('root', root)

$error_found = false

root.check_scope
root.check_types
root.check_structure

if $error_found == true
  exit
end
