require_relative 'ast_statements'
require_relative 'ast_expressions'
require_relative '../status'
require_relative '../error'

class Node
  def check_structure
    raise 'check_structure not implemented for class %s' % [self.class]
  end
end

class Program < Node
  def check_structure
    @functions.each {|func|
      !func.check_structure
    }
  end
end

class FunctionDefinition < Definition
  def check_structure
    return_found = false

    @body.statements.each { |statement|
      if statement.is_a?(ReturnStatement)
        return_found = true
      end

      if statement.is_a?(BreakStatement)
        NoExitError.new("break statement is not in a cycle", Status.new(statement.token.file_name, statement.token.line))
      end

      if statement.is_a?(ContinueStatement)
        NoExitError.new("continue statement is not in a cycle", Status.new(statement.token.file_name, statement.token.line))
      end
    }

    if !return_found
      NoExitError.new("no return statement", Status.new(@name.file_name, @name.line))
    end
  end
end
