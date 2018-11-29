
class Instructions
  def initialize
  end

  def get_instruction(name)
    case name
    when :EXIT; return Instruction.new(0x0, 0)
    else; raise "#{name} instruction not implemented"
    end
  end
end

class Instruction
  attr_reader :opcode
  attr_reader :ops

  def initialize(opcode, ops)
    @opcode = opcode
    @ops = ops
  end
end
