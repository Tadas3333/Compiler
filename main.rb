require_relative 'lexer/lexer'

lx = Lexer.new('input.txt')
tokens = lx.get_tokens
