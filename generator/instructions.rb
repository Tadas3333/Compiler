
class Instructions
  def initialize
  end

  def get_instruction(name)
    case name
    when :ADD_I; return Instruction.new(name, 0x0, 0)
    when :MUL_I; return Instruction.new(name, 0x1, 0)
    when :SUB_I; return Instruction.new(name, 0x2, 0)
    when :DIV_I; return Instruction.new(name, 0x3, 0)
    when :NOT_I; return Instruction.new(name, 0x4, 0)
    when :NEG_I; return Instruction.new(name, 0x5, 0)
    when :PEEK; return Instruction.new(name, 0x6, 1)
    when :POKE; return Instruction.new(name, 0x7, 1)
    when :POP; return Instruction.new(name, 0x8, 0)
    when :PUSH_I; return Instruction.new(name, 0x9, 1)
    when :CALL; return Instruction.new(name, 0x10, 1)
    when :BR; return Instruction.new(name, 0x11, 1)
    when :BZ; return Instruction.new(name, 0x12, 1)
    when :RET; return Instruction.new(name, 0x13, 0)
    when :RET_V; return Instruction.new(name, 0x14, 0)
    when :COM_E; return Instruction.new(name, 0x15, 0)
    when :COM_GE; return Instruction.new(name, 0x16, 0)
    when :COM_LE; return Instruction.new(name, 0x17, 0)
    when :COM_NE; return Instruction.new(name, 0x18, 0)
    when :COM_G; return Instruction.new(name, 0x19, 0)
    when :COM_L; return Instruction.new(name, 0x20, 0)
    when :AND; return Instruction.new(name, 0x21, 0)
    when :OR; return Instruction.new(name, 0x22, 0)
    when :EXIT; return Instruction.new(name, 0x23, 0)
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
