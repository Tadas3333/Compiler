
class AstPrinter
  def initialize
    @indent = 0
  end

  def print(field_name, value)
    if value.is_a?(Node)
      print_node(field_name, value)
    elsif value.is_a?(Array)
      print_array(field_name, value)
    elsif value.is_a?(Token)
      print_value(field_name, value.value)
    elsif value.is_a?(Symbol)
      print_value(field_name, value)
    elsif value.is_a?(String)
      print_value(field_name, value)
    else
      raise "#{value.class.name} class is not supported in print method"
    end
  end

  def print_array(field_name, array)
    if array.empty?
      print_value(field_name, '[]')
      return
    end

    array.each_with_index do |value, index|
      print('%s[%i]' % [field_name, index], value)
    end
  end

  def print_line(text)
    STDOUT.print '   ' * @indent
    STDOUT.puts text
  end

  def print_node(field_name, node)
    case node.class.name
    when 'ConstIntExpression', 'ConstFloatExpression', 'ConstStringExpression',
         'VarExpression'
      print_line('%s: %s: %s' % [field_name, node.class, node.tkn.value])
    when 'ArithmeticExpression', 'UnaryExpression'
      print_line('%s: %s(%s):' % [field_name, node.class, node.operator])
    else
      print_line('%s: %s:' % [field_name, node.class])
    end

    @indent += 1
    node.print(self)
    @indent -= 1
  end

  def print_value(field_name, value)
    print_line('%s: %s' % [field_name, value])
  end

  def print_const_value(field_name, const_name, value)
    print_line('%s: %s: %s' % [field_name, const_name, value])
  end
end
