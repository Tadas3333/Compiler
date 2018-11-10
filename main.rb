require_relative 'lexer/lexer'
require_relative 'parser/parser'
require_relative 'parser/ast_printer'

lx = Lexer.new('input.txt', false)
tokens = lx.get_tokens

ps = Parser.new(tokens)
root = ps.parse_program

tp = AstPrinter.new
tp.print('root', root)
