require_relative 'ast_statements'
require_relative 'ast_expressions'
require_relative '../status'
require_relative '../error'

class StructureStatus
  attr_accessor :parents_stack
  attr_accessor :inside_loop
  attr_accessor :return_found
  attr_accessor :main_found

  def initialize
    @parents_stack = []
    @main_found = false
  end

  def does_statement_exist?(statement)
    @parents_stack.each do |parent|
      if parent == statement
        return true
      end
    end

    false
  end
end

class Node
  def check_structure(ss)
    raise 'check_structure not implemented for class %s' % [self.class]
  end
end

class Program < Node
  def check_structure(file_name)
    ss = StructureStatus.new
    ss.parents_stack << self.class.name
    @functions.each do |func|
      func.check_structure(ss)
    end

    if !ss.main_found
      NoExitError.new("'main' function doesn't exist", Status.new(file_name, 0))
    end
    ss.parents_stack.pop
  end
end

class FunctionDefinition < Definition
  def check_structure(ss)
    ss.parents_stack << self.class.name

    if @name.value == 'main'
      ss.main_found = true

      if @ret_type.class.name != 'TypeInt'
        NoExitError.new("#{@name.value} function return type is not integer", Status.new(@name.file_name, @name.line))
      end
    end

    @body.check_structure(ss)
    ss.parents_stack.pop
  end
end

class StatementsRegion < Statement
  def check_structure(ss)
    ss.parents_stack << self.class.name
    @statements.each do |stmt|
      stmt.check_structure(ss)
    end
    ss.parents_stack.pop
  end
end

class AssignmentStatement < Statement
  def check_structure(ss)
  end
end

class DeclarationStatement < Statement
  def check_structure(ss)
  end
end

class IfStatement < Statement
  def check_structure(ss)
    ss.parents_stack << self.class.name

    @branches.each do |branch|
      branch.check_structure(ss)
    end

    if @else_statement != nil
      @else_statement.check_structure(ss)
    end

    ss.parents_stack.pop
  end
end

class Branch < Node
  def check_structure(ss)
    ss.parents_stack << self.class.name
    @statements.check_structure(ss)
    ss.parents_stack.pop
  end
end

class ElseStatement < Statement
  def check_structure(ss)
    ss.parents_stack << self.class.name
    @statements.check_structure(ss)
    ss.parents_stack.pop
  end
end

class WhileStatement < Statement
  def check_structure(ss)
    ss.parents_stack << self.class.name
    @statements.check_structure(ss)
    ss.parents_stack.pop
  end
end

class BreakStatement < Statement
  def check_structure(ss)
    if !ss.does_statement_exist?("WhileStatement")
      NoExitError.new("break statement is not inside a loop", Status.new(@token.file_name, @token.line))
    end
  end
end

class ContinueStatement < Statement
  def check_structure(ss)
    if !ss.does_statement_exist?("WhileStatement")
      NoExitError.new("continue statement is not inside a loop", Status.new(@token.file_name, @token.line))
    end
  end
end

class ReturnStatement < Statement
  def check_structure(ss)
  end
end

class BinaryExpression < Expression
  def check_structure(ss)
  end
end

class UnaryExpression < Expression
  def check_structure(ss)
  end
end

class CallExpression < Expression
  def check_structure(ss)
  end
end

class ConstIntExpression < Expression
  def check_structure(ss)
  end
end

class ConstStringExpression < Expression
  def check_structure(ss)
  end
end

class ConstFloatExpression < Expression
  def check_structure(ss)
  end
end

class ConstBoolExpression < Expression
  def check_structure(ss)
  end
end

class VarExpression < Expression
  def check_structure(ss)
  end
end
