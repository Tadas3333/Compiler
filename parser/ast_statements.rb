
class Node
  def print(p)
    raise 'not implemented for clas %s' % [self.class]
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

class StatementsRegion < Statement
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
  def initialize(name, value)
    @name = name
    @value = value
  end

  def print(p)
    p.print 'name', @name
    p.print 'value', @value
  end
end

class DeclarationStatement < Statement
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

class IfStatement < Statement
  def initialize(expr, statements, elseif_statements, else_statement)
    @expr = expr
    @statements = statements
    @elseif_statements = elseif_statements
    @else_statement = else_statement
  end

  def print(p)
    p.print('expr', @expr)
    p.print('statements', @statements)
    p.print('elseif', @elseif_statements) if @elseif_statements != []
    p.print('else', @else_statement)  if @else_statement != nil
  end
end

class ElseIfStatement < Statement
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
  def initialize(token)
    @token = token
  end

  def print(p)
  end
end

class ContinueStatement < Statement
  def initialize(token)
    @token = token
  end

  def print(p)
  end
end

class ReturnStatement < Statement
  def initialize(token, expr)
    @token = token
    @expr = expr
  end

  def print(p)
    p.print('expr', @expr) if @expr != nil
  end
end
