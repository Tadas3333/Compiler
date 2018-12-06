require_relative 'ast_statements'
require_relative 'ast_expressions'
require_relative '../status'
require_relative '../error'

class Variable
  attr_reader :type
  attr_reader :name

  def initialize(type, name)
    @type = type
    @name = name
  end
end

class TypesCheck
  attr_reader :error
  attr_accessor :current_func

  def initialize
    @funcs = []
    @current_func = 0
  end

  def add_function(node)
    @funcs.push(node)
  end

  def add_variable(node)
    @funcs.at(@current_func).variables.push(Variable.new(node.type, node.name))
  end

  def get_var_type(token)
    @funcs.at(@current_func).variables.each { |var|
      if var.name.value == token.value
        return Token.new(var.type, '', token.file_name, token.line)
      end
    }
    raise "variable #{token.value} not found"
  end

  def get_current_function_type
    @funcs.at(@current_func).ret_type
  end

  def get_call_type(node) # Call Expression
    @funcs.each { |func|
      if func.name.value == node.name.value
        return Token.new(func.ret_type, '', node.name.file_name, node.name.line)
      end
    }
    raise "function #{node.name.value} not found"
  end

  def check_call_params(node) # Call Expression
    @funcs.each { |func|
      if func.name.value == node.name.value
        return function_params_match?(func, node)
      end
    }
    raise "function #{node.name.value} not found"
  end

  def function_params_match?(func, call)
    if func.params.params.size != call.arguments.size
      NoExitError.new("#{call.name.value} parameters count does not match", Status.new(call.name.file_name, call.name.line))
      return
    end

    indx = 0
    func.params.params.each { |param|
      cl_expr_tkn = call.arguments.at(indx).get_expr_type(self)
      types_match?(param.type, cl_expr_tkn.name, cl_expr_tkn)
      indx += 1
    }
  end

  def types_match?(type1, type2, lc_token)
    if type1 != type2
      NoExitError.new("#{type1} and #{type2} mismatch", Status.new(lc_token.file_name, lc_token.line))
      return false
    end

    true
  end
end

class Node
  def check_types(name)
    raise 'check_types not implemented for class %s' % [self.class]
  end
end

class Program < Node
  def check_types
    fna = TypesCheck.new

    @functions.each {|func|
      func.check_definition(fna)
      fna.current_func += 1
    }

    fna.current_func = 0

    @functions.each {|func|
      func.check_types(fna)
      fna.current_func += 1
    }

    if fna.error
      exit
    end
  end
end

class FunctionDefinition < Definition
  def check_definition(fna)
    fna.add_function(self)
    @params.check_types(fna)
  end

  def check_types(fna)
    @body.check_types(fna)
  end
end

class Parameters < Node
  def check_types(fna)
    @params.each{ |param|
      param.check_types(fna)
    }
  end
end

class Parameter < Node
  def check_types(fna)
    fna.add_variable(self)
    return if @value == nil
    @value.check_types(fna)
    fna.types_match?(@type, @value.get_expr_type(fna).name, @name)
  end
end

class StatementsRegion < Statement
  def check_types(fna)
    @statements.each{ |statement|
      statement.check_types(fna)
    }
  end
end

class AssignmentStatement < Statement
  def check_types(fna)
    @value.check_types(fna)
    fna.types_match?(fna.get_var_type(@name).name, @value.get_expr_type(fna).name, @name)
  end
end

class DeclarationStatement < Statement
  def check_types(fna)
    fna.add_variable(self)
    return if @value == nil
    @value.check_types(fna)
    fna.types_match?(@type, @value.get_expr_type(fna).name, @name)
  end
end

class IfStatement < Statement
  def check_types(fna)
    @branches.each{ |branch|
      branch.check_types(fna)
    }

    @else_statement.check_types(fna) if @else_statement != nil
  end
end

class Branch < Node
  def check_types(fna)
    @expr.check_types(fna)
    type_tkn = @expr.get_expr_type(fna)
    if type_tkn.name != :TRUE && type_tkn.name != :FALSE
      fna.types_match?(type_tkn.name, :BOOL, type_tkn)
    end
    @statements.check_types(fna)
  end
end

class ElseStatement < Statement
  def check_types(fna)
    @statements.check_types(fna)
  end
end

class WhileStatement < Statement
  def check_types(fna)
    @expr.check_types(fna)
    type_tkn = @expr.get_expr_type(fna)
    if type_tkn.name != :TRUE && type_tkn.name != :FALSE
      fna.types_match?(type_tkn.name, :BOOL, type_tkn)
    end
    @statements.check_types(fna)
  end
end

class BreakStatement < Statement
  def check_types(fna)
  end
end

class ContinueStatement < Statement
  def check_types(fna)
  end
end

class ReturnStatement < Statement
  def check_types(fna)
    ret_type = :VOID

    if @expr != nil
      ret_type = @expr.get_expr_type(fna).name
    end

    fna.types_match?(ret_type, fna.get_current_function_type, @token)
  end
end

def user_friendly_operator(opr)
  case opr
  when :OP_PLUS; return "+"
  when :OP_MINUS; return "-"
  when :OP_MULTIPLY; return "*"
  when :OP_DIVIDE; return "/"
  when :OP_DAND; return "&&"
  when :OP_DOR; return "||"
  when :OP_N; return "!"
  else; return opr
  end
end

class BinaryExpression < Expression
  def check_types(fna)
    @left.check_types(fna)
    @right.check_types(fna)
    left_tkn = @left.get_expr_type(fna)
    fna.types_match?(left_tkn.name, @right.get_expr_type(fna).name, left_tkn)

    user_friendly_operators = []

    if left_tkn.name == :LIT_STR
      NoExitError.new("#{user_friendly_operator(@operator)} operation with #{left_tkn.name}", Status.new(left_tkn.file_name, left_tkn.line))
    end

    if left_tkn.name == :BOOL && @operator != :OP_DAND && @operator != :OP_DOR
      NoExitError.new("#{user_friendly_operator(@operator)} operation with bool", Status.new(left_tkn.file_name, left_tkn.line))
    end

    if left_tkn.name == :VOID
      NoExitError.new("#{user_friendly_operator(@operator)} operation with void", Status.new(left_tkn.file_name, left_tkn.line))
    end
  end

  def get_expr_type(fna)
    if [:OP_DE, :OP_GE, :OP_LE, :OP_NE, :OP_G, :OP_L].include?(@operator)
      tkn = @left.get_expr_type(fna)
      tkn.name = :BOOL
      return tkn
    end

    @left.get_expr_type(fna)
  end
end

class UnaryExpression < Expression
  def check_types(fna)
    @factor.check_types(fna)

    l_tkn = @factor.get_expr_type(fna)

    case @operator
    when :OP_N
      case l_tkn.name
      when :LIT_INT;NoExitError.new("#{user_friendly_operator(@operator)} operation with integer", Status.new(l_tkn.file_name, l_tkn.line))
      when :LIT_FLOAT;NoExitError.new("#{user_friendly_operator(@operator)} operation with float", Status.new(l_tkn.file_name, l_tkn.line))
      when :VOID;NoExitError.new("#{user_friendly_operator(@operator)} operation with void", Status.new(l_tkn.file_name, l_tkn.line))
      when :LIT_STR;NoExitError.new("#{user_friendly_operator(@operator)} operation with string", Status.new(l_tkn.file_name, l_tkn.line))
      else;
      end
    when :OP_MINUS
      case l_tkn.name
      when :BOOL;NoExitError.new("#{user_friendly_operator(@operator)} operation with bool", Status.new(l_tkn.file_name, l_tkn.line))
      when :VOID;NoExitError.new("#{user_friendly_operator(@operator)} operation with void", Status.new(l_tkn.file_name, l_tkn.line))
      when :LIT_STR;NoExitError.new("#{user_friendly_operator(@operator)} operation with string", Status.new(l_tkn.file_name, l_tkn.line))
      else;
      end
    else; raise "unknown operator #{operator}"
    end
  end

  def get_expr_type(fna)
    @factor.get_expr_type(fna)
  end
end

class CallExpression < Expression
  def check_types(fna)
    @arguments.each { |arg|
      arg.check_types(fna)
    }

    fna.check_call_params(self)
  end

  def get_expr_type(fna)
    return fna.get_call_type(self)
  end
end

class ConstIntExpression < Expression
  def check_types(fna)
  end

  def get_expr_type(fna)
    @tkn
  end
end

class ConstStringExpression < Expression
  def check_types(fna)
  end

  def get_expr_type(fna)
    @tkn
  end
end

class ConstFloatExpression < Expression
  def check_types(fna)
  end

  def get_expr_type(fna)
    @tkn
  end
end

class ConstBoolExpression < Expression
  def check_types(fna)
  end

  def get_expr_type(fna)
    @tkn
  end
end

class VarExpression < Expression
  def check_types(fna)
  end

  def get_expr_type(fna)
    return fna.get_var_type(@tkn)
  end
end
