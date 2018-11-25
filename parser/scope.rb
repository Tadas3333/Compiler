require_relative 'ast_statements'
require_relative 'ast_expressions'
require_relative '../status'
require_relative '../error'

class Scope
  def initialize(parent = nil)
    @variables = []
    @parent = parent
  end

  def add(name)
    if declared?(name)
      return Error.new("dublicate variable #{name.value}", Status.new(name.file_name, name.line))
    end

    @variables.push(name.value)
  end

  def declared?(name)
    return true if @variables.include?(name.value)
    return @parent.declared?(name) unless @parent.equal?(nil)
    false
  end

  def undeclared_var(name)
    Error.new("undeclared variable #{name.value}", Status.new(name.file_name, name.line))
  end
end


class Node
  def check(name)
    raise 'check not implemented for class %s' % [self.class]
  end
end

class Program < Node
  def check
    scope = Scope.new(nil)

    @functions.each {|func|
      scope.add(func.name)
      func.check(scope)
    }
  end
end

class FunctionDefinition < Definition
  def check(parent)
    scope = Scope.new(parent)
    @params.check(scope)
    @body.check(scope)
  end
end

class Parameters < Node
  def check(parent)
    @params.each{ |param|
      param.check(parent)
    }
  end
end

class Parameter < Node
  def check(parent)
    parent.add(@name)
  end
end

class StatementsRegion < Statement
  def check(parent)
    scope = Scope.new(parent)

    @statements.each{ |statement|
      statement.check(scope)
    }
  end
end

class AssignmentStatement < Statement
  def check(parent)
    parent.undeclared_var(@name) unless parent.declared?(@name)
    @value.check(parent)
  end
end

class DeclarationStatement < Statement
  def check(parent)
    parent.add(@name)
    @value.check(parent)
  end
end

class IfStatement < Statement
  def check(parent)
    @branches.each{ |branch|
      branch.check(parent)
    }

    @else_statement.check(parent) if @else_statement != nil
  end
end

class Branch < Node
  def check(parent)
    @expr.check(parent)
    @statements.check(parent)
  end
end

class ElseStatement < Statement
  def check(parent)
    @statements.check(parent)
  end
end

class WhileStatement < Statement
  def check(parent)
    @expr.check(parent)
    @statements.check(parent)
  end
end

class BreakStatement < Statement
  def check(parent)
  end
end

class ContinueStatement < Statement
  def check(parent)
  end
end

class ReturnStatement < Statement
  def check(parent)
    @expr.check(parent) if @expr != nil
  end
end

class BinaryExpression < Expression
  def check(parent)
    @left.check(parent)
    @right.check(parent)
  end
end

class UnaryExpression < Expression
  def check(parent)
    @factor.check(parent)
  end
end

class CallExpression < Expression
  def check(parent)
    parent.undeclared_var(@name) unless parent.declared?(@name)

    @arguments.each{ |arg|
      arg.check(parent)
    }
  end
end

class ConstIntExpression < Expression
  def check(parent)
  end
end

class ConstStringExpression < Expression
  def check(parent)
  end
end

class ConstFloatExpression < Expression
  def check(parent)
  end
end

class VarExpression < Expression
  def check(parent)
    parent.undeclared_var(@tkn) unless parent.declared?(@tkn)
  end
end
