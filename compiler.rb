require_relative 'lexer/lexer'
require_relative 'parser/parser'
require_relative 'parser/ast_printer'
require_relative 'parser/check_scope'
require_relative 'parser/check_types'
require_relative 'parser/check_structure'
require_relative 'generator/generator'
require_relative 'virtual_machine'

input_file = ARGV[0]
output_file = ARGV[1]

if input_file == nil
  puts "No input file specified."
  exit
end

if output_file == nil
  puts "No output file specified."
  exit
end

lx = Lexer.new(input_file, false)
tokens = lx.get_tokens

ps = Parser.new(tokens)
root = ps.parse_program

#tp = AstPrinter.new
#tp.print('root', root)

root.check_scope

$error_found = false

root.check_types
root.check_structure(input_file)

if $error_found == true
  exit
end

gen = Generator.new
root.generate(gen)
gen.write_to_file(output_file)
#gen.dump

vm = VirtualMachine.new
vm.run(gen.code)
