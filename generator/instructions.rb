
class Instructions
  def initialize
  end

  def get_instruction(name)
    case name
    when :ADD_I; return Instruction.new(name, 99, 0)
    when :MUL_I; return Instruction.new(name, 100, 0)
    when :SUB_I; return Instruction.new(name, 200, 0)
    when :DIV_I; return Instruction.new(name, 300, 0)
    when :MOD_I; return Instruction.new(name, 2700, 0)
    when :NOT_I; return Instruction.new(name, 400, 0)
    when :NEG_I; return Instruction.new(name, 500, 0)
    when :PEEK; return Instruction.new(name, 600, 1)
    when :POKE; return Instruction.new(name, 700, 1)
    when :POP; return Instruction.new(name, 800, 0)
    when :PUSH_I; return Instruction.new(name, 900, 1)
    when :CALL; return Instruction.new(name, 1000, 1)
    when :BR; return Instruction.new(name, 1100, 1)
    when :BZ; return Instruction.new(name, 1200, 1)
    when :RET; return Instruction.new(name, 1300, 0)
    when :RET_V; return Instruction.new(name, 1400, 0)
    when :COM_E; return Instruction.new(name, 1500, 0)
    when :COM_GE; return Instruction.new(name, 1600, 0)
    when :COM_LE; return Instruction.new(name, 1700, 0)
    when :COM_NE; return Instruction.new(name, 1800, 0)
    when :COM_G; return Instruction.new(name, 1900, 0)
    when :COM_L; return Instruction.new(name, 2000, 0)
    when :AND; return Instruction.new(name, 2100, 0)
    when :OR; return Instruction.new(name, 2200, 0)
    when :PRINT; return Instruction.new(name, 2300, 0)
    when :GINP; return Instruction.new(name, 2400, 0)
    when :ITS; return Instruction.new(name, 2500, 0)
    when :STI; return Instruction.new(name, 2800, 0)
    when :EXIT; return Instruction.new(name, 2600, 0)
    else; raise "#{name} instruction not implemented"
    end
  end
end

class Instruction
  attr_reader :name
  attr_reader :opcode
  attr_reader :ops

  def initialize(name, opcode, ops)
    @name = name
    @opcode = opcode
    @ops = ops
  end
end
