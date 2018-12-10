require_relative '../parser/ast_statements'
require_relative '../parser/ast_expressions'
require_relative '../standart_library'
require_relative 'instructions'
require_relative 'labels'
require_relative 'nodes'

class GenVariable
  attr_reader :type
  attr_reader :name

  def initialize(type, name)
    @type = type
    @name = name
  end
end

class GenFunction
  attr_reader :name
  attr_reader :adress
  attr_reader :variables

  def initialize(name, adress)
    @name = name
    @adress = adress
    @variables = []
  end

  def add_variable(type, name)
    @variables << GenVariable.new(type, name)
  end

  def get_variable_adress(name)
    indx = 0
    @variables.each do |var|
      if var.name == name
        return indx
      end
      indx += 1
    end

    raise "#{name} variable doesn't exist"
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
  attr_reader :code

  def initialize
    @instructions = []
    @code = []
    @functions = []
    @whiles = []

    @current_function = 0
    @label_index = 0
    @code_index = 0
  end

  #####################################################
  # Instructions
  def dump
    code_indx = 0
    @instructions.each do |instr|
      print "#{code_indx}:#{instr.name} "

      i = 0
      until i == instr.ops do
        code_indx += 1
        print "#{@code[code_indx]} "
        i += 1
      end

      puts ""
      code_indx += 1
    end

    puts @code.inspect
  end

  def write(instruction, *ops)
    inst = Instructions.new.get_instruction(instruction)

    if inst.ops != ops.size
      raise "#{instruction} invalid operands count"
    end

    @code.push(inst.opcode)
    @code_index += 1

    ops.each { |op|
      @code.push(op)
      @code_index += 1
    }

    @instructions << inst
  end

  def write_to_file(file_name)

  end

  def add_variable(type, name)
    @functions.at(@current_function).add_variable(type, name)
  end

  def get_variable_adress(name)
    @functions.at(@current_function).get_variable_adress(name)
  end

  def set_current_function(name)
    indx = 0
    @functions.each do |func|
      if func.name == name
        return @current_function = indx
      end
      indx += 1
    end

    raise "#{name} function doesn't exist"
  end

  def generate_standart_libray
    StandartLibrary.new.generate(self)
  end
end
