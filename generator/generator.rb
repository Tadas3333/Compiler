require_relative '../parser/ast_statements'
require_relative '../parser/ast_expressions'
require_relative 'instructions'
require_relative 'labels'
require_relative 'nodes'

=begin
 TO DO LIST:
  - Call function with less arguments
  - Float, String, Bool types
  - Multiple variable name scopes with variable deletes
  - Function returns
=end

class GenVariable
  attr_reader :type
  attr_reader :name
  attr_reader :adress

  def initialize(type, name, adress)
    @type = type
    @name = name
    @adress = adress
  end
end

class GenFunction
  attr_reader :name
  attr_reader :adress

  def initialize(name, adress)
    @name = name
    @adress = adress
  end
end

class GenWhile
  attr_reader :id
  attr_reader :start_adress

  def initialize(id, start_adress)
    @id = id
    @start_adress = start_adress
  end
end

class Generator
  attr_reader :stack_pointer

  def initialize(output_file)
    @output_file = output_file

    @instructions = []
    @code = []
    @functions = []
    @whiles = []
    @variables = []

    @stack_pointer = -1
    @label_index = 0
    @current_line = 0
  end

  #####################################################
  # Instructions
  def dump
    indx = 0
    code_indx = 0
    @instructions.each do |instr|
      print "#{indx}:#{instr.name} "
      code_indx += 1

      i = 0
      until i == instr.ops do
        print "#{@code[code_indx]} "
        code_indx += 1
        i += 1
      end

      puts ""

      indx += 1
    end

    puts @code.inspect
  end

  def write(instruction, *ops)
    inst = Instructions.new.get_instruction(instruction)

    if inst.ops != ops.size
      raise "#{instruction} invalid operands count"
    end

    @code.push(inst.opcode)

    ops.each { |op|
      @code.push(op)
    }

    @instructions << inst
    @current_line += 1
    @stack_pointer += inst.stack_change
  end

  def add_variable(type, name, stack_pos = @stack_pointer)
    @variables << GenVariable.new(type, name, stack_pos)
  end

  def get_variable_adress(name)
    @variables.each do |var|
      if var.name == name
        return var.adress
      end
    end
    raise "#{name} variable doesn't exist"
  end
end
