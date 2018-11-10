require_relative 'ast_statements'

class LogicalExpression < Node
  def initialize(operator, left, right)
    @operator = operator
    @left = left
    @right = right
  end

  def print(p)
    p.print 'operator', @operator
    p.print 'left', @left
    p.print 'right', @right
  end
end

class RelationalExpression < Node
  def initialize(operator, left, right)
    @operator = operator
    @left = left
    @right = right
  end

  def print(p)
    p.print 'operator', @operator
    p.print 'left', @left
    p.print 'right', @right
  end
end

class ArithmeticExpression < Node
  attr_reader :operator

  def initialize(operator, left, right)
    @operator = operator
    @left = left
    @right = right
  end

  def print(p)
    p.print 'left', @left
    p.print 'right', @right
  end
end

class UnaryExpression < Node
  attr_reader :operator
  attr_accessor :factor

  def initialize(operator, factor)
    @operator = operator
    @factor = factor
  end

  def print(p)
    p.print 'factor', @factor
  end
end

class BraceExpression < Node
  def initialize(expr)
    @expr = expr
  end

  def print(p)
    p.print 'expr', @expr
  end
end

class VarExpression < Node
  def initialize(token)
    @tkn = token
  end

  def print(p)
    p.print 'var', @tkn
  end
end

class CallExpression < Node
  def initialize(name, arguments)
    @name = name
    @arguments = arguments
  end

  def print(p)
    p.print 'name', @name
    p.print 'args', @arguments
  end
end

class ConstIntExpression < Node
  attr_reader :tkn

  def initialize(token)
    @tkn = token
  end

  def print(p)
  end
end

class ConstStringExpression < Node
  attr_reader :tkn

  def initialize(token)
    @tkn = token
  end

  def print(p)
  end
end

class ConstFloatExpression < Node
  attr_reader :tkn

  def initialize(token)
    @tkn = token
  end

  def print(p)
  end
end

class VarExpression < Node
  attr_reader :tkn

  def initialize(token)
    @tkn = token
  end

  def print(p)
  end
end
