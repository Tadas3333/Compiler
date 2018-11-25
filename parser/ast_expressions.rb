require_relative 'ast_statements'

class Expression < Node
end

class BinaryExpression < Expression
  attr_reader :operator

  def initialize(operator, left, right)
    @operator = operator
    @left = left
    @right = right
  end

  def print(p)
    p.print 'op', @operator
    p.print 'left', @left
    p.print 'right', @right
  end
end

class UnaryExpression < Expression
  attr_reader :operator
  attr_accessor :factor

  def initialize(operator, factor)
    @operator = operator
    @factor = factor
  end

  def print(p)
    p.print 'op', @operator
    p.print 'factor', @factor
  end
end

class CallExpression < Expression
  def initialize(name, arguments)
    @name = name
    @arguments = arguments
  end

  def print(p)
    p.print 'name', @name
    p.print 'args', @arguments
  end
end

class ConstIntExpression < Expression
  attr_reader :tkn

  def initialize(token)
    @tkn = token
  end

  def print(p)
  end
end

class ConstStringExpression < Expression
  attr_reader :tkn

  def initialize(token)
    @tkn = token
  end

  def print(p)
  end
end

class ConstFloatExpression < Expression
  attr_reader :tkn

  def initialize(token)
    @tkn = token
  end

  def print(p)
  end
end

class VarExpression < Expression
  attr_reader :tkn

  def initialize(token)
    @tkn = token
  end

  def print(p)
  end
end
