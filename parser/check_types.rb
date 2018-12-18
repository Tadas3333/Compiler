require_relative 'ast_statements'
require_relative 'ast_expressions'
require_relative 'parser'
require_relative '../standart_library'
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
        return var.type
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
        return func.ret_type
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
      types_match?(param.type, cl_expr_tkn, cl_expr_tkn)
      indx += 1
    }
  end

  def types_match?(type1, type2, lc_token)
    if type1.class.name != type2.class.name
      if lc_token.is_a?(Token)
        NoExitError.new("#{type1.class.name} and #{type2.class.name} mismatch", Status.new(lc_token.file_name, lc_token.line))
      else
        NoExitError.new("#{type1.class.name} and #{type2.class.name} mismatch", Status.new(lc_token.tkn.file_name, lc_token.tkn.line))
      end
      return false
    end

    true
  end

  def pointers_match?(type1, type2, lc_token)
    if type1.class.name != type2.class.name
        NoExitError.new("pointers mismatch", Status.new(lc_token.file_name, lc_token.line))
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

    df = StandartLibrary.new
    df.functions.each { |key, info_hash|
      r_type = info_hash.fetch('type')

      case r_type
      when 'void'; r_type = TypeVoid.new
      when 'int'; r_type = TypeInt.new
      when 'float'; r_type = TypeFloat.new
      when 'bool'; r_type = TypeBool.new
      when 'string'; r_type = TypeString.new
      when 'pointer'; r_type = TypePointer.new(nil, TypeInt.new)
      else
        raise 'unknown type'
      end

      params = info_hash.fetch('params')
      r_any_pointer = info_hash.fetch('r_any_pointer')

      indx = 0
      params_class = Parameters.new
      params.each { |pr|
        case pr
        when 'void'; pr = TypeVoid.new
        when 'int'; pr = TypeInt.new
        when 'float'; pr = TypeFloat.new
        when 'bool'; pr = TypeBool.new
        when 'string'; pr = TypeString.new
        when 'pointer'; pr = TypePointer.new(nil, TypeInt.new)
        else
          raise 'unknown type'
        end
        params_class.add_parameter(Parameter.new(pr, Token.new(:IDENT, indx, "StandartLibrary", 0), nil))
        indx += 1
      }

      funcdef = FunctionDefinition.new(Token.new(:IDENT, key, "StandartLibrary", 0), params_class, r_type, nil, r_any_pointer)
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
    fna.types_match?(@type, @value.get_expr_type(fna), @name)
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
    var_type = fna.get_var_type(@name)
    variable = fna.get_variable(@name.value)

    if @index_exprs != nil
      @index_exprs.each do |expr|
        if !var_type.is_a?(TypePointer)
          NoExitError.new("variable has too many indexes", Status.new(@name.file_name, @name.line))
          break
        end

        expr.check_types(fna)
        fna.types_match?(TypeInt.new, expr.get_expr_type(fna), @name)
        var_type = var_type.inner
      end
    end

    value_type = @value.get_expr_type(fna)
    org_var_type = var_type.clone
    org_value_type = value_type.clone

    if var_type.is_a?(TypePointer) && value_type.is_a?(TypePointer) && !@value.get_r_any_pointer(fna)
      while var_type.is_a?(TypePointer) && value_type.is_a?(TypePointer) do
        var_type = var_type.inner
        value_type = value_type.inner
      end
    end

    if org_var_type.is_a?(TypePointer) && org_value_type.is_a?(TypePointer)
      if !@value.get_r_any_pointer(fna)
        fna.pointers_match?(var_type, value_type, @name)
      end
    else
      fna.types_match?(var_type, value_type, @name)
    end
  end
end

class DeclarationStatement < Statement
  def check_types(fna)
    fna.add_variable(self)
    return if @value == nil
    @value.check_types(fna)

    value_type = @value.get_expr_type(fna)
    org_var_type = @type.clone
    org_value_type = value_type.clone

    if @type.is_a?(TypePointer) && value_type.is_a?(TypePointer) && !@value.get_r_any_pointer(fna)
      while @type.is_a?(TypePointer) && value_type.is_a?(TypePointer) do
        @type = @type.inner
        value_type = value_type.inner
      end
    end

    if org_var_type.is_a?(TypePointer) && org_value_type.is_a?(TypePointer)
      if !@value.get_r_any_pointer(fna)
        fna.pointers_match?(@type, value_type, @name)
      end
    else
      fna.types_match?(@type, value_type, @name)
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
    fna.types_match?(@expr.get_expr_type(fna), TypeBool.new, @expr.get_expr_type(fna).tkn)
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
    fna.types_match?(@expr.get_expr_type(fna), TypeBool.new, @expr.get_expr_type(fna).tkn)
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
    ret_type = TypeVoid.new(@token)

    if @expr != nil
      @expr.check_types(fna)
      ret_type = @expr.get_expr_type(fna)
    end

    func_type = fna.get_current_function_type
    org_return_type = ret_type.clone
    org_func_type = func_type.clone

    if ret_type.is_a?(TypePointer) && func_type.is_a?(TypePointer)
      while ret_type.is_a?(TypePointer) && func_type.is_a?(TypePointer) do
        ret_type = ret_type.inner
        func_type = func_type.inner
      end
    end

    if org_return_type.is_a?(TypePointer) && org_func_type.is_a?(TypePointer)
      fna.pointers_match?(ret_type, func_type, @token)
    else
      fna.types_match?(ret_type, func_type, @token)
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
    fna.types_match?(@expr_type, @right.get_expr_type(fna), @expr_type)

    user_friendly_operators = []

    if @expr_type.class.name == 'TypeString'
      NoExitError.new("#{user_friendly_operator(@operator)} operation with string", Status.new(@expr_type.tkn.file_name, @expr_type.tkn.line))
    end

    if @expr_type.class.name == 'TypeBool' && @operator != :OP_DAND && @operator != :OP_DOR && @operator != :OP_DE
      NoExitError.new("#{user_friendly_operator(@operator)} operation with bool", Status.new(@expr_type.tkn.file_name, @expr_type.tkn.line))
    end

    if @expr_type.class.name == 'TypeVoid'
      NoExitError.new("#{user_friendly_operator(@operator)} operation with void", Status.new(@expr_type.tkn.file_name, @expr_type.tkn.line))
    end

    if @expr_type.class.name == 'TypePointer'
        NoExitError.new("#{user_friendly_operator(@operator)} operation with a pointer", Status.new(@expr_type.tkn.file_name, @expr_type.tkn.line))
    end
  end

  def get_expr_type(fna)
    if [:OP_DE, :OP_GE, :OP_LE, :OP_NE, :OP_G, :OP_L].include?(@operator)
      return TypeBool.new(@left.get_expr_type(fna))
    end

    @left.get_expr_type(fna)
  end

  def get_r_any_pointer(fna)
    @left.get_r_any_pointer(fna)
  end
end

class UnaryExpression < Expression
  def check_types(fna)
    @factor.check_types(fna)
    expr_type = @factor.get_expr_type(fna)
    case @operator
    when :OP_N
      case expr_type.class.name
      when 'TypeInt';NoExitError.new("#{user_friendly_operator(@operator)} operation with integer", Status.new(expr_type.tkn.file_name, expr_type.tkn.line))
      when 'TypeFloat';NoExitError.new("#{user_friendly_operator(@operator)} operation with float", Status.new(expr_type.tkn.file_name, expr_type.tkn.line))
      when 'TypeVoid';NoExitError.new("#{user_friendly_operator(@operator)} operation with void", Status.new(expr_type.tkn.file_name, expr_type.tkn.line))
      when 'TypeString';NoExitError.new("#{user_friendly_operator(@operator)} operation with string", Status.new(expr_type.tkn.file_name, expr_type.tkn.line))
      when 'TypePointer';NoExitError.new("#{user_friendly_operator(@operator)} operation with a pointer", Status.new(expr_type.tkn.file_name, expr_type.tkn.line))
      else;
      end
    when :OP_MINUS
      case expr_type.class.name
      when 'TypeBool';NoExitError.new("#{user_friendly_operator(@operator)} operation with bool", Status.new(expr_type.tkn.file_name, expr_type.tkn.line))
      when 'TypeVoid';NoExitError.new("#{user_friendly_operator(@operator)} operation with void", Status.new(expr_type.tkn.file_name, expr_type.tkn.line))
      when 'TypeString';NoExitError.new("#{user_friendly_operator(@operator)} operation with string", Status.new(expr_type.tkn.file_name, expr_type.tkn.line))
      when 'TypePointer';NoExitError.new("#{user_friendly_operator(@operator)} operation with a pointer", Status.new(expr_type.tkn.file_name, expr_type.tkn.line))
      else;
      end
    else; raise "unknown operator #{operator}"
    end
  end

  def get_expr_type(fna)
    @factor.get_expr_type(fna)
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

  def get_r_any_pointer(fna)
    fna.get_function_r_any_pointer(@name.value)
  end
end

class ConstIntExpression < Expression
  def check_types(fna)
  end

  def get_expr_type(fna)
    return TypeInt.new(@tkn)
  end

  def get_r_any_pointer(fna)
    false
  end
end

class ConstStringExpression < Expression
  def check_types(fna)
  end

  def get_expr_type(fna)
    return TypeString.new(@tkn)
  end

  def get_r_any_pointer(fna)
    false
  end
end

class ConstFloatExpression < Expression
  def check_types(fna)
  end

  def get_expr_type(fna)
    return TypeFloat.new(@tkn)
  end

  def get_r_any_pointer(fna)
    false
  end
end

class ConstBoolExpression < Expression
  def check_types(fna)
  end

  def get_expr_type(fna)
    return TypeBool.new(@tkn)
  end

  def get_r_any_pointer(fna)
    false
  end
end

class PointerExpression < Expression
  def check_types(fna)
    @index_exprs.each do |expr|
      expr.check_types(fna)
      fna.types_match?(TypeInt.new, expr.get_expr_type(fna), @name)
    end

    variable = fna.get_variable(@name.value)
  end

  def get_expr_type(fna)
    var_type = fna.get_var_type(@name)

    count = 0
    loop do
      if count >= @index_exprs.size
        break
      end

      if !var_type.is_a?(TypePointer)
        NoExitError.new("variable has too many indexes", Status.new(@name.file_name, @name.line))
        break
      end

      var_type = var_type.inner
      count += 1
    end

    return var_type
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

  def get_r_any_pointer(fna)
    false
  end
end
