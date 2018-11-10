
class Node
  def print(p)
    raise 'not implemented for clas %s' % [self.class]
  end
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


class FunctionDefinition < Node
  def initialize(name, params, ret_type, body)
    @name = name
    @params = params
    @ret_type = ret_type
    @body = body
  end

  def print(p)
    p.print 'name', @name
    p.print 'params', @params
    p.print 'ret_type', @ret_type
    p.print 'body', @body
  end
end

class Parameters < Node
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
  def initialize(type, name)
    @type = type
    @name = name
  end

  def print(p)
    p.print 'name', @name
    p.print 'type', @type
  end
end

class StatementsRegion < Node
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

class AssignmentStatement < Node
  def initialize(name, value)
    @name = name
    @value = value
  end

  def print(p)
    p.print 'name', @name
    p.print 'value', @value
  end
end

class DeclarationStatement < Node
  def initialize(type, name, value)
    @type = type
    @name = name
    @value = value
  end

  def print(p)
    p.print('type', @type)
    p.print('name', @name)
    p.print('value', @value) if @value != nil
  end
end

class IfStatement < Node
  def initialize(expr, statements, elseif_statement, else_statement)
    @expr = expr
    @statements = statements
    @elseif_statement = elseif_statement
    @else_statement = else_statement
  end

  def print(p)
    p.print('expr', @expr)
    p.print('statements', @statements)
    p.print('elseif', @elseif_statement) if @elseif_statement != nil
    p.print('else', @else_statement)  if @else_statement != nil
  end
end

class ElseIfStatement < Node
  def initialize(expr, statements, elseif_statement, else_statement)
    @expr = expr
    @statements = statements
    @elseif_statement = elseif_statement
    @else_statement = else_statement
  end

  def print(p)
    p.print('expr', @expr)
    p.print('statements', @statements)
    p.print('elseif', @elseif_statement) if @elseif_statement != nil
    p.print('else', @else_statement)  if @else_statement != nil
  end
end

class ElseStatement < Node
  def initialize(statements)
    @statements = statements
  end

  def print(p)
    p.print 'statements', @statements
  end
end

class WhileStatement < Node
  def initialize(expr, statements)
    @expr = expr
    @statements = statements
  end

  def print(p)
    p.print 'expr', @expr
    p.print 'statements', @statements
  end
end

class BreakStatement < Node
  def initialize
  end

  def print(p)
  end
end

class ContinueStatement < Node
  def initialize
  end

  def print(p)
  end
end

class ReturnStatement < Node
  def initialize(expr)
    @expr = expr
  end

  def print(p)
    p.print('expr', @expr) if @expr != nil
  end
end
