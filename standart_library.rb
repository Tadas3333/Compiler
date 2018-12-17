require_relative 'generator/generator'

class StandartLibrary
  attr_reader :functions

  def initialize
    @functions = {}

    add_definition(:VOID, 0, 'print', [:LIT_STR])
    add_definition(:LIT_STR, 0, 'get_input', [])
    add_definition(:LIT_STR, 0, 'int_to_string', [:LIT_INT])
    add_definition(:LIT_INT, 0, 'string_to_int', [:LIT_STR])
    add_definition(:LIT_STR, 0, 'float_to_string', [:LIT_FLOAT])
    add_definition(:INT_POINTER, 1, 'allocate', [:LIT_INT], true)
    add_definition(:VOID, 0, 'sleep', [:LIT_INT])
    add_definition(:VOID, 0, 'clear', [])
    add_definition(:BOOL, 0, 'left_key', [])
    add_definition(:BOOL, 0, 'right_key', [])
    add_definition(:VOID, 0, 'set_color', [:LIT_INT])
  end

  def add_definition(return_type, r_pointer_depth, name, params, r_any_pointer = false)
    @functions[name] = {'type' => return_type, 'r_pointer_depth' => r_pointer_depth, 'params' => params, 'r_any_pointer' => r_any_pointer}
  end

  def generate(gen)
    generate_print(gen)
    generate_get_input(gen)
    generate_int_to_string(gen)
    generate_string_to_int(gen)
    generate_float_to_string(gen)
    generate_allocate(gen)
    generate_sleep(gen)
    generate_clear(gen)
    generate_left_key(gen)
    generate_right_key(gen)
    generate_set_color(gen)
  end

  def generate_print(gen)
    gen.label_function('print')
    gen.set_current_function('print')
    gen.add_variable(:LIT_STR, '0', 0)

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
    gen.add_variable(:LIT_INT, '0', 0)

    gen.write(:PEEK, 0)
    gen.write(:ITS)
    gen.write(:RET_V)
  end

  def generate_string_to_int(gen)
    gen.label_function('string_to_int')
    gen.set_current_function('string_to_int')
    gen.add_variable(:LIT_STR, '0', 0)

    gen.write(:PEEK, 0)
    gen.write(:STI)
    gen.write(:RET_V)
  end

  def generate_float_to_string(gen)
    gen.label_function('float_to_string')
    gen.set_current_function('float_to_string')
    gen.add_variable(:LIT_FLOAT, '0', 0)

    gen.write(:PEEK, 0)
    gen.write(:FTS)
    gen.write(:RET_V)
  end

  def generate_allocate(gen)
    gen.label_function('allocate')
    gen.set_current_function('allocate')
    gen.add_variable(:LIT_INT, '0', 0)

    gen.write(:PEEK, 0)
    gen.write(:ALLOC)
    gen.write(:RET_V)
  end

  def generate_sleep(gen)
    gen.label_function('sleep')
    gen.set_current_function('sleep')
    gen.add_variable(:LIT_INT, '0', 0)

    gen.write(:SLEEP, 0)
    gen.write(:RET)
  end

  def generate_clear(gen)
    gen.label_function('clear')
    gen.set_current_function('clear')

    gen.write(:CLEAR)
    gen.write(:RET)
  end

  def generate_left_key(gen)
    gen.label_function('left_key')
    gen.set_current_function('left_key')

    gen.write(:LEFT_KEY)
    gen.write(:RET_V)
  end

  def generate_right_key(gen)
    gen.label_function('right_key')
    gen.set_current_function('right_key')

    gen.write(:RIGHT_KEY)
    gen.write(:RET_V)
  end

  def generate_set_color(gen)
    gen.label_function('set_color')
    gen.set_current_function('set_color')
    gen.add_variable(:LIT_INT, '0', 0)

    gen.write(:SETCOLOR)
    gen.write(:RET)
  end
end
