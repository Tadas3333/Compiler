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
  def check_structure(file_name)
    main_found = false
    last_func_token = nil

    @functions.each {|func|
      if func.name.value == "main"
        main_found = true

        if func.ret_type != :LIT_INT
          NoExitError.new("'main' function return type is not an integer", Status.new(func.name.file_name, func.name.line))
        end

        if func.params.params.size != 0
          NoExitError.new("'main' function with parameters", Status.new(func.name.file_name, func.name.line))
        end
      end

      func.check_structure
      last_func_token = func.name
    }

    if !main_found
      if @functions.size == 0
        NoExitError.new("'main' function is not defined", Status.new(file_name, 0))
      else
        NoExitError.new("'main' function is not defined", Status.new(last_func_token.file_name, last_func_token.line))
      end
    end
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

    if !return_found && @ret_type != :VOID
      NoExitError.new("no return statement", Status.new(@name.file_name, @name.line))
    end
  end
end
