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
      NoExitError.new("dublicate variable #{name.value}", Status.new(name.file_name, name.line))
      return
    end

    @variables.push(name.value)
  end

  def declared?(name)
    return true if @variables.include?(name.value)
    return @parent.declared?(name) unless @parent.equal?(nil)
    false
  end
end

def undeclared_var(name)
  NoExitError.new("undeclared variable #{name.value}", Status.new(name.file_name, name.line))
end

class Node
  def check_scope(name)
    raise 'check_scope not implemented for class %s' % [self.class]
  end
end

class Program < Node
  def check_scope
    scope = Scope.new(nil)

    @functions.each {|func|
      func.check_scope(scope)
    }
  end
end

class FunctionDefinition < Definition
  def check_scope(parent)
    parent.add(@name)
    scope = Scope.new(parent)
    @params.check_scope(scope)
    @body.check_scope(scope)
  end
end

class Parameters < Node
  def check_scope(parent)
    @params.each{ |param|
      param.check_scope(parent)
    }
  end
end

class Parameter < Node
  def check_scope(parent)
    parent.add(@name)
  end
end

class StatementsRegion < Statement
  def check_scope(parent)
    scope = Scope.new(parent)

    @statements.each{ |statement|
      statement.check_scope(scope)
    }
  end
end

class AssignmentStatement < Statement
  def check_scope(parent)
    undeclared_var(@name) unless parent.declared?(@name)
    @value.check_scope(parent)
  end
end

class DeclarationStatement < Statement
  def check_scope(parent)
    parent.add(@name)
    @value.check_scope(parent)
  end
end

class IfStatement < Statement
  def check_scope(parent)
    @branches.each{ |branch|
      branch.check_scope(parent)
    }

    @else_statement.check_scope(parent) if @else_statement != nil
  end
end

class Branch < Node
  def check_scope(parent)
    @expr.check_scope(parent)
    @statements.check_scope(parent)
  end
end

class ElseStatement < Statement
  def check_scope(parent)
    @statements.check_scope(parent)
  end
end

class WhileStatement < Statement
  def check_scope(parent)
    @expr.check_scope(parent)
    @statements.check_scope(parent)
  end
end

class BreakStatement < Statement
  def check_scope(parent)
  end
end

class ContinueStatement < Statement
  def check_scope(parent)
  end
end

class ReturnStatement < Statement
  def check_scope(parent)
    @expr.check_scope(parent) if @expr != nil
  end
end

class BinaryExpression < Expression
  def check_scope(parent)
    @left.check_scope(parent)
    @right.check_scope(parent)
  end
end

class UnaryExpression < Expression
  def check_scope(parent)
    @factor.check_scope(parent)
  end
end

class CallExpression < Expression
  def check_scope(parent)
    undeclared_var(@name) unless parent.declared?(@name)

    @arguments.each{ |arg|
      arg.check_scope(parent)
    }
  end
end

class ConstIntExpression < Expression
  def check_scope(parent)
  end
end

class ConstStringExpression < Expression
  def check_scope(parent)
  end
end

class ConstFloatExpression < Expression
  def check_scope(parent)
  end
end

class VarExpression < Expression
  def check_scope(parent)
    undeclared_var(@tkn) unless parent.declared?(@tkn)
  end
end
