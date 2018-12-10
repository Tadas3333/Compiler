require_relative 'generator/generator'

class StandartLibrary
  attr_reader :functions

  def initialize
    @functions = {}

    add_definition(:VOID, 'print', [:LIT_STR])
    add_definition(:LIT_STR, 'get_input', [])
    add_definition(:LIT_STR, 'int_to_string', [:LIT_INT])
    add_definition(:LIT_INT, 'string_to_int', [:LIT_STR])
  end

  def add_definition(return_type, name, params)
    @functions[name] = {'type' => return_type, 'params' => params}
  end

  def generate(gen)
    generate_print(gen)
    generate_get_input(gen)
    generate_int_to_string(gen)
    generate_string_to_int(gen)
  end

  def generate_print(gen)
    gen.label_function('print')
    gen.set_current_function('print')
    gen.add_variable(:LIT_STR, '0')

    gen.write(:PEEK, 0)
    gen.write(:PRINT)
    gen.write(:RET)
  end

  def generate_get_input(gen)
    gen.label_function('get_input')
    gen.set_current_function('get_input')

    gen.write(:GINP)
    gen.write(:RET_V)
  end

  def generate_int_to_string(gen)
    gen.label_function('int_to_string')
    gen.set_current_function('int_to_string')
    gen.add_variable(:LIT_INT, '0')

    gen.write(:PEEK, 0)
    gen.write(:ITS)
    gen.write(:RET_V)
  end

  def generate_string_to_int(gen)
    gen.label_function('string_to_int')
    gen.set_current_function('string_to_int')
    gen.add_variable(:LIT_STR, '0')

    gen.write(:PEEK, 0)
    gen.write(:STI)
    gen.write(:RET_V)
  end
end
