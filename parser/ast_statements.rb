
class Node
  def print(p)
    raise 'not implemented for class %s' % [self.class]
  end
end

class Statement < Node
end

class Definition < Node
end

class Program < Node
  def initialize
    @functions = []
  end

  def add_function(function)
    @functions.push(function)
  end

  def print(p)
    p.print_array('functions', @functions)
  end
end

class FunctionDefinition < Definition
  attr_reader :name
  attr_reader :ret_type
  attr_reader :pointer_depth
  attr_reader :params
  attr_reader :variables
  attr_reader :r_any_pointer

  def initialize(name, params, ret_type, pointer_depth, body, r_any_pointer = false)
    @name = name
    @params = params
    @ret_type = ret_type
    @pointer_depth = pointer_depth
    @body = body
    @variables = []
    @r_any_pointer = r_any_pointer
  end

  def print(p)
    p.print 'name', @name
    p.print 'params', @params
    p.print 'ret_type', @ret_type
    p.print 'pointer_depth', @pointer_dept
    p.print 'body', @body
  end
end

class Parameters < Node
  attr_reader :params

  def initialize
    @params = []
  end

  def add_parameter(param)
    @params.push(param)
  end

  def print(p)
    p.print 'params', @params
  end
end

class Parameter < Node
  attr_reader :type
  attr_reader :name
  attr_reader :pointer_depth

  def initialize(type, name, value, pointer_depth)
    @type = type
    @name = name
    @value = value
    @pointer_depth = pointer_depth
  end

  def print(p)
    p.print('name', @name)
    p.print('type', @type)
    p.print('value', @value) if @value != nil
    p.print('pointer_depth', @pointer_depth)
  end
end

class StatementsRegion < Statement
  attr_reader :statements

  def initialize
    @statements = []
  end

  def add_statement(statement)
    @statements.push(statement)
  end

  def print(p)
    p.print 'statements', @statements
  end
end

class AssignmentStatement < Statement
  def initialize(name, index_exprs, value)
    @name = name
    @index_exprs = index_exprs
    @value = value
  end

  def print(p)
    p.print 'name', @name
    p.print('pointer_indexes', @index_exprs) if @index_exprs != nil
    p.print 'value', @value
  end
end

class DeclarationStatement < Statement
  attr_reader :type
  attr_reader :name
  attr_reader :pointer_depth

  def initialize(type, name, value, pointer_depth)
    @type = type
    @name = name
    @value = value
    @pointer_depth = pointer_depth
  end

  def print(p)
    p.print('type', @type)
    p.print('pointer_depth', @pointer_depth)
    p.print('name', @name)
    p.print('value', @value) if @value != nil
  end
end

class IfStatement < Statement
  def initialize(branches, else_statement)
    @branches = branches
    @else_statement = else_statement
  end

  def print(p)
    p.print('branch', @branches)
    p.print('else', @else_statement)  if @else_statement != nil
  end
end

class Branch < Node
  def initialize(expr, statements)
    @expr = expr
    @statements = statements
  end

  def print(p)
    p.print 'expr', @expr
    p.print 'statements', @statements
  end
end

class ElseStatement < Statement
  def initialize(statements)
    @statements = statements
  end

  def print(p)
    p.print 'statements', @statements
  end
end

class WhileStatement < Statement
  def initialize(expr, statements)
    @expr = expr
    @statements = statements
  end

  def print(p)
    p.print 'expr', @expr
    p.print 'statements', @statements
  end
end

class BreakStatement < Statement
  attr_reader :token

  def initialize(token)
    @token = token
  end

  def print(p)
  end
end

class ContinueStatement < Statement
  attr_reader :token

  def initialize(token)
    @token = token
  end

  def print(p)
  end
end

class ReturnStatement < Statement
  attr_reader :token

  def initialize(token, expr)
    @token = token
    @expr = expr
  end

  def print(p)
    p.print('expr', @expr) if @expr != nil
  end
end
