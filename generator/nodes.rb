
class Node
  def generate(gen)
    raise 'generate not implemented for class %s' % [self.class]
  end
end

class Program < Node
  def generate(gen)
    # Call main function and exit the program
    CallExpression.new(Token.new(0, 'main', 0, 0), []).generate(gen)
    gen.write(:EXIT)
    gen.generate_standart_libray

    @functions.each { |func|
      func.generate(gen)
    }

    gen.replace_missing_call_labels
  end
end

class FunctionDefinition < Definition
  def generate(gen)
    gen.label_function(@name.value)
    gen.set_current_function(@name.value)
    @params.generate(gen)
    @body.generate(gen)

    # Add returns in case function ended and no return was called
    if @ret_type == :VOID
      gen.write(:RET)
    elsif @ret_type == :STRING
      gen.write(:PUSH_I, "")
      gen.write(:RET_V)
    elsif @ret_type == :LIT_FLOAT
      gen.write(:PUSH_F, gen.float_to_bin(0.0))
      gen.write(:RET_V)
    else
      gen.write(:PUSH_I, 0)
      gen.write(:RET_V)
    end
  end
end

class Parameters < Node
  def generate(gen)
    @params.each do |param|
      param.generate(gen)
    end
  end
end

class Parameter < Node
  def generate(gen)
    gen.add_variable(@type, @name.value, 0)
  end
end

class StatementsRegion < Statement
  def generate(gen)
    @statements.each { |stmt|
      stmt.generate(gen)
    }
  end
end

class AssignmentStatement < Statement
  def generate(gen)
    @value.generate(gen)
    adr = gen.get_variable_adress(@name.value)

    if @index_exprs != nil
      @index_exprs.reverse.each do |expr|
        expr.generate(gen)
      end
      gen.write(:PUSH_I, @index_exprs.size)
      gen.write(:POKE_P, adr)
    else
      gen.write(:POKE, adr)
    end
  end
end

class DeclarationStatement < Statement
  def generate(gen)
    gen.write(:PUSH_I, 0)
    gen.add_variable(@type, @name.value, @pointer_depth)

    if @value != nil
      @value.generate(gen)
      adr = gen.get_variable_adress(@name.value)
      gen.write(:POKE, adr)
    end
  end
end

class IfStatement < Statement
  def generate(gen)
    missing_labels = []

    @branches.each { |branch|
      missing_labels << branch.generate(gen)
    }

    if @else_statement != nil
      @else_statement.generate(gen)
    end

    end_of_statement_label = gen.place_label

    missing_labels.each { |label|
      gen.replace_missing_label(label, end_of_statement_label)
    }
  end
end

class Branch < Node
  def generate(gen)
    @expr.generate(gen)
    expr_missing_label = gen.place_missing_label
    gen.write(:BZ, expr_missing_label)

    @statements.generate(gen)
    end_of_statement_label = gen.place_missing_label
    gen.write(:BR, end_of_statement_label)

    expr_zero_label = gen.place_label
    gen.replace_missing_label(expr_missing_label, expr_zero_label)

    return end_of_statement_label
  end
end

class ElseStatement < Statement
  def generate(gen)
    @statements.generate(gen)
  end
end

class WhileStatement < Statement
  def generate(gen)
    expr_start_label = gen.place_while_start_label
    @expr.generate(gen)
    expr_missing_label = gen.place_missing_label
    gen.write(:BZ, expr_missing_label)

    @statements.generate(gen)
    gen.write(:BR, expr_start_label)

    end_of_statement_label = gen.place_label
    gen.replace_missing_label(expr_missing_label, end_of_statement_label)
    gen.replace_missing_while_end_labels(end_of_statement_label)
  end
end

class BreakStatement < Statement
  def generate(gen)
    gen.write(:BR, gen.place_missing_while_end_label)
  end
end

class ContinueStatement < Statement
  def generate(gen)
    gen.write(:BR, gen.get_while_start_label)
  end
end

class ReturnStatement < Statement
  def generate(gen)
    if @expr != nil
      @expr.generate(gen)
      return gen.write(:RET_V)
    end

    gen.write(:RET)
  end
end

class BinaryExpression < Expression
  def generate(gen)
    @left.generate(gen)
    @right.generate(gen)

    case @operator
    when :OP_PLUS; gen.write(:ADD_I)
    when :OP_MINUS; gen.write(:SUB_I)
    when :OP_DIVIDE; gen.write(:DIV_I)
    when :OP_MULTIPLY; gen.write(:MUL_I)
    when :OP_MOD; gen.write(:MOD_I)
    when :OP_DE; gen.write(:COM_E)
    when :OP_GE; gen.write(:COM_GE)
    when :OP_LE; gen.write(:COM_LE)
    when :OP_NE; gen.write(:COM_NE)
    when :OP_G; gen.write(:COM_G)
    when :OP_L; gen.write(:COM_L)
    when :OP_DAND; gen.write(:AND)
    when :OP_DOR; gen.write(:OR)
    else; raise("unknown operator #{@operator}")
    end
  end
end

class UnaryExpression < Expression
  def generate(gen)
    @factor.generate(gen)

    case @operator
    when :OP_N; gen.write(:NOT_I)
    when :OP_MINUS; gen.write(:NEG_I)
    else; raise("unknown operator #{@operator}")
    end
  end
end

class CallExpression < Expression
  def generate(gen)
    gen.write(:PUSH_I, 0) # Will hold return_value
    gen.write(:PUSH_I, 0) # Will hold @fp
    gen.write(:PUSH_I, 0) # Will hold return_adress

    @arguments.each{ |arg|
      arg.generate(gen)
    }

    missing_label = gen.place_missing_call_label(@name.value)
    gen.write(:PUSH_I, missing_label) # Pushes jump adress

    gen.write(:CALL, @arguments.size)
  end
end

class ConstIntExpression < Expression
  def generate(gen)
    gen.write(:PUSH_I, @tkn.value)
  end
end

class ConstStringExpression < Expression
  def generate(gen)
    indx = gen.save_string(@tkn.value)
    gen.write(:PUSH_I, indx)
  end
end

class ConstFloatExpression < Expression
  def generate(gen)
    gen.write(:PUSH_F, gen.float_to_bin(@tkn.value))
  end
end

class ConstBoolExpression < Expression
  def generate(gen)
    case @tkn.value
    when 'true'; gen.write(:PUSH_I, 1)
    when 'false'; gen.write(:PUSH_I, 0)
    else; raise "unknown bool value #{@tkn.value}"
    end
  end
end

class PointerExpression < Expression
  def generate(gen)
    @index_exprs.reverse.each do |expr|
      expr.generate(gen)
    end

    gen.write(:PUSH_I, @index_exprs.size)
    gen.write(:PEEK_P, gen.get_variable_adress(@name.value))
  end
end

class VarExpression < Expression
  def generate(gen)
    gen.write(:PEEK, gen.get_variable_adress(@tkn.value))
  end
end
