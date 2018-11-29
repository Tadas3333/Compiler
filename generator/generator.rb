require_relative '../parser/ast_statements'
require_relative '../parser/ast_expressions'
require_relative 'instructions'

class Generator
  def initialize(output_file)
    @output_file = output_file
    @code = []
  end

  def dump
    puts @code.inspect
  end

  def write(instruction, *ops)
    inst = Instructions.new.get_instruction(instruction)

    if inst.ops != ops.size
      raise "#{instruction} invalid operands count"
    end

    @code.push(inst.opcode)

    ops.each { |op|

    }
  end
end

class Node
  def generate(gen)
    raise 'generate not implemented for class %s' % [self.class]
  end
end

class Program < Node
  def generate(gen)
    @functions.each { |func|
      if func.name.value == "main"
        func.generate(gen)
        break
      end
    }

    gen.write(:EXIT)

    @functions.each { |func|
      if func.name.value != "main"
        func.generate(gen)
      end
    }

    gen.dump
  end
end

class FunctionDefinition < Definition
  def generate(gen)
    @params.generate(gen)
    @body.generate(gen)
    gen.write(:RET)
  end
end

class Parameters < Node
  def generate(gen)
    @params.each { |param|
      param.generate(gen)
    }
  end
end

class Parameter < Node
  def generate(gen)
  end
end

class StatementsRegion < Statement
  def generate(gen)
    @statements.each { |stmt|
      stmt.generate(gen)
    }
  end
end

class AssignmentStatement < Statement
  def generate(gen)
    # Get variable adress and assign value
  end
end

class DeclarationStatement < Statement
  def generate(gen)
    # Create variable
  end
end

class IfStatement < Statement
  def generate(gen)
    @branches.each { |branch|
      branch.generate(gen)
    }

    @else_statement.generate(gen) if @else_statement != nil
  end
end

class Branch < Node
  def generate(gen)
  end
end

class ElseStatement < Statement
  def generate(gen)
    @statements.generate(gen)
  end
end

class WhileStatement < Statement
  def generate(gen)
    @statements.generate(gen)
  end
end

class BreakStatement < Statement
  def generate(gen)
  end
end

class ContinueStatement < Statement
  def generate(gen)
  end
end

class ReturnStatement < Statement
  def generate(gen)
  end
end

class BinaryExpression < Expression
  def generate(gen)
  end
end

class UnaryExpression < Expression
  def generate(gen)
  end
end

class CallExpression < Expression
  def generate(gen)
  end
end

class ConstIntExpression < Expression
  def generate(gen)
  end
end

class ConstStringExpression < Expression
  def generate(gen)
  end
end

class ConstFloatExpression < Expression
  def generate(gen)
  end
end

class ConstBoolExpression < Expression
  def generate(gen)
  end
end

class VarExpression < Expression
  def generate(gen)
  end
end
