require_relative 'ast_statements'
require_relative 'ast_expressions'
require_relative '../standart_library'
require_relative '../status'
require_relative '../error'

class Variable
  attr_reader :type
  attr_reader :name
  attr_reader :pointer_depth

  def initialize(type, name, pointer_depth)
    @type = type
    @name = name
    @pointer_depth = pointer_depth
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
    @funcs.at(@current_func).variables.push(Variable.new(node.type, node.name, node.pointer_depth))
  end

  def get_var_type(token)
    @funcs.at(@current_func).variables.each { |var|
      if var.name.value == token.value
        return Token.new(var.type, '', token.file_name, token.line)
      end
    }
    raise "variable #{token.value} not found"
  end

  def get_variable(name)
    @funcs.at(@current_func).variables.each { |var|
      if var.name.value == name
        return var
      end
    }
    raise "variable #{name} not found"
  end

  def get_current_function_type
    @funcs.at(@current_func).ret_type
  end

  def get_current_function_pointer_depth
    @funcs.at(@current_func).pointer_depth
  end

  def get_current_function_r_any_pointer
    @funcs.at(@current_func).r_any_pointer
  end

  def get_function_r_any_pointer(name)
    @funcs.each { |func|
      if func.name.value == name
        return func.r_any_pointer
      end
    }
    raise "function #{name} not found"
  end

  def get_call_type(node) # Call Expression
    @funcs.each { |func|
      if func.name.value == node.name.value
        return Token.new(func.ret_type, '', node.name.file_name, node.name.line)
      end
    }
    raise "function #{node.name.value} not found"
  end

  def get_call_pointer_depth(node) # Call Expression
    @funcs.each { |func|
      if func.name.value == node.name.value
        return func.pointer_depth
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
      if types_match?(param.type, cl_expr_tkn.name, cl_expr_tkn)
        if is_pointer_type?(param.type)
          if func.pointer_depth != call.arguments.at(indx).get_pointer_depth(self)
            NoExitError.new("function #{func.name.value} call argument pointer depth mismatch", Status.new(call.name.file_name, call.name.line))
          end
        end
      end
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

  def is_pointer_type?(type)
    if type == :INT_POINTER || type == :FLOAT_POINTER || type == :BOOL_POINTER || type == :STRING_POINTER
      return true
    end

    false
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

    df = StandartLibrary.new
    df.functions.each { |key, info_hash|
      r_type = info_hash.fetch('type')
      r_pointer_depth = info_hash.fetch('r_pointer_depth')
      params = info_hash.fetch('params')
      r_any_pointer = info_hash.fetch('r_any_pointer')

      indx = 0
      params_class = Parameters.new
      params.each { |pr|
        params_class.add_parameter(Parameter.new(pr, Token.new(:IDENT, indx, "StandartLibrary", 0), nil, 0))
        indx += 1
      }

      funcdef = FunctionDefinition.new(Token.new(:IDENT, key, "StandartLibrary", 0), params_class, r_type, r_pointer_depth, nil, r_any_pointer)
      fna.add_function(funcdef)

      funcdef.params.params.each { |pr|
        fna.add_variable(pr)
      }

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
    @body.check_types(fna) if @body != nil
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
    var_type = fna.get_var_type(@name).name
    variable = fna.get_variable(@name.value)
    pointing_depth = 0

    if @index_exprs != nil
      @index_exprs.each do |expr|
        expr.check_types(fna)
        fna.types_match?(:LIT_INT, expr.get_expr_type(fna).name, @name)
      end

      if @index_exprs.size > variable.pointer_depth
        NoExitError.new("#{variable.name.value} pointer depth is too big", Status.new(@name.file_name, @name.line))
      end

      pointing_depth = variable.pointer_depth-@index_exprs.size

      if pointing_depth == 0
        case var_type
        when :INT_POINTER; var_type = :LIT_INT;
        when :FLOAT_POINTER; var_type = :LIT_FLOAT;
        when :BOOL_POINTER; var_type = :BOOL;
        when :STRING_POINTER; var_type = :LIT_STR;
        else raise 'unknown pointer type'
        end
      end
    elsif fna.is_pointer_type?(var_type)
      pointing_depth = variable.pointer_depth
    end

    if fna.is_pointer_type?(var_type) && @value.get_r_any_pointer(fna)
      return
    end

    if fna.types_match?(var_type, @value.get_expr_type(fna).name, @name)
      value_pointer_depth = @value.get_pointer_depth(fna)
      if pointing_depth != value_pointer_depth
        NoExitError.new("#{variable.name.value} - #{pointing_depth} and #{value_pointer_depth} pointer depths mismatch", Status.new(@name.file_name, @name.line))
      end
    end
  end
end

class DeclarationStatement < Statement
  def check_types(fna)
    fna.add_variable(self)
    return if @value == nil
    @value.check_types(fna)

    if fna.types_match?(@type, @value.get_expr_type(fna).name, @name)
      value_pointer_depth = @value.get_pointer_depth(fna)
      if @pointer_depth != value_pointer_depth
        NoExitError.new("#{@name.value} - #{@pointer_depth} and #{value_pointer_depth} pointer depths mismatch", Status.new(@name.file_name, @name.line))
      end
    end
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
    if fna.is_pointer_type?(fna.get_current_function_type) && fna.get_current_function_r_any_pointer
      return
    end

    ret_type = :VOID

    if @expr != nil
      ret_type = @expr.get_expr_type(fna).name
    end

    if fna.types_match?(ret_type, fna.get_current_function_type, @token)
      if fna.is_pointer_type?(ret_type)
        pr_tkn = @expr.get_expr_type(fna)
        if @expr.get_pointer_depth(fna) != fna.get_current_function_pointer_depth
          NoExitError.new("function return pointer depths do not match", Status.new(pr_tkn.file_name, pr_tkn.line))
        end
      end
    end
  end
end

def user_friendly_operator(opr)
  case opr
  when :OP_PLUS; return "+"
  when :OP_MINUS; return "-"
  when :OP_MULTIPLY; return "*"
  when :OP_DIVIDE; return "/"
  when :OP_MOD; return "%"
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
    @expr_type = @left.get_expr_type(fna)
    fna.types_match?(@expr_type.name, @right.get_expr_type(fna).name, @expr_type)

    user_friendly_operators = []

    if @expr_type.name == :LIT_STR
      NoExitError.new("#{user_friendly_operator(@operator)} operation with #{@expr_type.name}", Status.new(@expr_type.file_name, @expr_type.line))
    end

    if @expr_type.name == :BOOL && @operator != :OP_DAND && @operator != :OP_DOR
      NoExitError.new("#{user_friendly_operator(@operator)} operation with bool", Status.new(@expr_type.file_name, @expr_type.line))
    end

    if @expr_type.name == :VOID
      NoExitError.new("#{user_friendly_operator(@operator)} operation with void", Status.new(@expr_type.file_name, @expr_type.line))
    end

    if @expr_type.name == :INT_POINTER || @expr_type.name == :FLOAT_POINTER || @expr_type.name == :BOOL_POINTER || @expr_type.name == :STRING_POINTER
        NoExitError.new("#{user_friendly_operator(@operator)} operation with a pointer", Status.new(@expr_type.file_name, @expr_type.line))
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

  def get_pointer_depth(fna)
    @left.get_pointer_depth(fna)
  end

  def get_r_any_pointer(fna)
    @left.get_r_any_pointer(fna)
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
      when :INT_POINTER, :FLOAT_POINTER, :BOOL_POINTER, :STRING_POINTER;NoExitError.new("#{user_friendly_operator(@operator)} operation with a pointer", Status.new(l_tkn.file_name, l_tkn.line))
      else;
      end
    when :OP_MINUS
      case l_tkn.name
      when :BOOL;NoExitError.new("#{user_friendly_operator(@operator)} operation with bool", Status.new(l_tkn.file_name, l_tkn.line))
      when :VOID;NoExitError.new("#{user_friendly_operator(@operator)} operation with void", Status.new(l_tkn.file_name, l_tkn.line))
      when :LIT_STR;NoExitError.new("#{user_friendly_operator(@operator)} operation with string", Status.new(l_tkn.file_name, l_tkn.line))
      when :INT_POINTER, :FLOAT_POINTER, :BOOL_POINTER, :STRING_POINTER;NoExitError.new("#{user_friendly_operator(@operator)} operation with a pointer", Status.new(l_tkn.file_name, l_tkn.line))
      else;
      end
    else; raise "unknown operator #{operator}"
    end
  end

  def get_expr_type(fna)
    @factor.get_expr_type(fna)
  end

  def get_pointer_depth(fna)
    @factor.get_pointer_depth(fna)
  end

  def get_r_any_pointer(fna)
    @factor.get_r_any_pointer(fna)
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

  def get_pointer_depth(fna)
    return fna.get_call_pointer_depth(self)
  end

  def get_r_any_pointer(fna)
    fna.get_function_r_any_pointer(@name.value)
  end
end

class ConstIntExpression < Expression
  def check_types(fna)
  end

  def get_expr_type(fna)
    @tkn
  end

  def get_pointer_depth(fna)
    return 0
  end

  def get_r_any_pointer(fna)
    false
  end
end

class ConstStringExpression < Expression
  def check_types(fna)
  end

  def get_expr_type(fna)
    @tkn
  end

  def get_pointer_depth(fna)
    return 0
  end

  def get_r_any_pointer(fna)
    false
  end
end

class ConstFloatExpression < Expression
  def check_types(fna)
  end

  def get_expr_type(fna)
    @tkn
  end

  def get_pointer_depth(fna)
    return 0
  end

  def get_r_any_pointer(fna)
    false
  end
end

class ConstBoolExpression < Expression
  def check_types(fna)
  end

  def get_expr_type(fna)
    @tkn
  end

  def get_pointer_depth(fna)
    return 0
  end

  def get_r_any_pointer(fna)
    false
  end
end

class PointerExpression < Expression
  def check_types(fna)
    @index_exprs.each do |expr|
      expr.check_types(fna)
      fna.types_match?(:LIT_INT, expr.get_expr_type(fna).name, @name)
    end

    variable = fna.get_variable(@name.value)
    if @index_exprs.size > variable.pointer_depth
      NoExitError.new("#{variable.name.value} pointer depth is too big", Status.new(@name.file_name, @name.line))
    end
  end

  def get_expr_type(fna)
    tkn = fna.get_var_type(@name)
    depth = fna.get_variable(@name.value).pointer_depth
    depth -= @index_exprs.size

    if depth == 0
      case tkn.name
      when :INT_POINTER; tkn.name = :LIT_INT; return tkn;
      when :FLOAT_POINTER; tkn.name = :LIT_FLOAT; return tkn;
      when :BOOL_POINTER; tkn.name = :BOOL; return tkn;
      when :STRING_POINTER; tkn.name = :LIT_STR; return tkn;
      else raise 'unknown pointer type'
      end
    else
      return tkn
    end
  end

  def get_pointer_depth(fna)
    depth = fna.get_variable(@name.value).pointer_depth

    if @index_exprs != nil
      depth -= @index_exprs.size
    end

    return depth
  end

  def get_r_any_pointer(fna)
    false
  end
end

class VarExpression < Expression
  def check_types(fna)
  end

  def get_expr_type(fna)
    return fna.get_var_type(@tkn)
  end

  def get_pointer_depth(fna)
    return fna.get_variable(@tkn.value).pointer_depth
  end

  def get_r_any_pointer(fna)
    false
  end
end
