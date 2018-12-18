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
  attr_reader :name
  attr_reader :arguments

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

class ConstBoolExpression < Expression
  attr_reader :tkn

  def initialize(token)
    @tkn = token
  end

  def print(p)
  end
end

class PointerExpression < Expression
  def initialize(ident, index_exprs)
    @name = ident
    @index_exprs = index_exprs
  end

  def print(p)
    p.print('indexes', @index_exprs)
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
class Type < Node
end

class TypeInt < Type
  attr_reader :tkn

  def initialize(token = nil)
    if token == nil
      @tkn = Token.new('0', 0, '0', '0')
    else
      @tkn = token
    end
  end

  def print(p)
  end
end

class TypeFloat < Type
  attr_reader :tkn

  def initialize(token = nil)
    if token == nil
      @tkn = Token.new('0', 0, '0', '0')
    else
      @tkn = token
    end
  end

  def print(p)
  end
end

class TypeString < Type
  attr_reader :tkn

  def initialize(token = nil)
    if token == nil
      @tkn = Token.new('0', 0, '0', '0')
    else
      @tkn = token
    end
  end

  def print(p)
  end
end

class TypeVoid < Type
  attr_reader :tkn

  def initialize(token = nil)
    if token == nil
      @tkn = Token.new('0', 0, '0', '0')
    else
      @tkn = token
    end
  end

  def print(p)
  end
end

class TypeBool < Type
  attr_reader :tkn

  def initialize(token = nil)
    if token == nil
      @tkn = Token.new('0', 0, '0', '0')
    else
      @tkn = token
    end
  end

  def print(p)
  end
end

class TypePointer < Type
  attr_reader :inner
  attr_reader :tkn

  def initialize(token = nil, inner)
    if token == nil
      @tkn = Token.new('0', 0, '0', '0')
    else
      @tkn = token
    end

    @inner = inner
  end

  def print(p)
    p.print('inner', @inner)
  end
end
