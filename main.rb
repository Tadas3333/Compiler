require_relative 'lexer/lexer'
require_relative 'parser/parser'

lx = Lexer.new('input.txt', true)
tokens = lx.get_tokens

ps = Parser.new(tokens)
ps.parse_program
