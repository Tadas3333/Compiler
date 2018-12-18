require_relative 'generator/generator'

class StandartLibrary
  attr_reader :functions

  def initialize
    @functions = {}

    add_definition('void', 'print', ['string'])
    add_definition('string', 'get_input', [])
    add_definition('string', 'int_to_string', ['int'])
    add_definition('int', 'string_to_int', ['string'])
    add_definition('string', 'float_to_string', ['float'])
    add_definition('pointer', 'allocate', ['int'], true)
    add_definition('void', 'sleep', ['int'])
    add_definition('void', 'clear', [])
    add_definition('bool', 'left_key', [])
    add_definition('bool', 'right_key', [])
    add_definition('void', 'set_color', ['int'])
    add_definition('bool', 'r_key', [])
    add_definition('string', 'ascii_to_char', ['int'])
    add_definition('void', 'rblc', ['string'])
    add_definition('void', 'bblc', ['string'])
  end

  def add_definition(return_type, name, params, r_any_pointer = false)
    @functions[name] = {'type' => return_type, 'params' => params, 'r_any_pointer' => r_any_pointer}
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
    generate_r_key(gen)
    generate_ascii_to_char(gen)
    generate_rblc(gen)
    generate_bblc(gen)
  end

  def generate_print(gen)
    gen.label_function('print')
    gen.set_current_function('print')
    gen.add_variable(TypeString.new, '0', 0)

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
    gen.add_variable(TypeInt.new, '0', 0)

    gen.write(:PEEK, 0)
    gen.write(:ITS)
    gen.write(:RET_V)
  end

  def generate_string_to_int(gen)
    gen.label_function('string_to_int')
    gen.set_current_function('string_to_int')
    gen.add_variable(TypeString.new, '0', 0)

    gen.write(:PEEK, 0)
    gen.write(:STI)
    gen.write(:RET_V)
  end

  def generate_float_to_string(gen)
    gen.label_function('float_to_string')
    gen.set_current_function('float_to_string')
    gen.add_variable(TypeFloat.new, '0', 0)

    gen.write(:PEEK, 0)
    gen.write(:FTS)
    gen.write(:RET_V)
  end

  def generate_allocate(gen)
    gen.label_function('allocate')
    gen.set_current_function('allocate')
    gen.add_variable(TypeInt.new, '0', 0)

    gen.write(:PEEK, 0)
    gen.write(:ALLOC)
    gen.write(:RET_V)
  end

  def generate_sleep(gen)
    gen.label_function('sleep')
    gen.set_current_function('sleep')
    gen.add_variable(TypeInt.new, '0', 0)

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
    gen.add_variable(TypeInt.new, '0', 0)

    gen.write(:SETCOLOR)
    gen.write(:RET)
  end

  def generate_r_key(gen)
    gen.label_function('r_key')
    gen.set_current_function('r_key')

    gen.write(:R_KEY)
    gen.write(:RET_V)
  end

  def generate_ascii_to_char(gen)
    gen.label_function('ascii_to_char')
    gen.set_current_function('ascii_to_char')
    gen.add_variable(TypeInt.new, '0', 0)

    gen.write(:PEEK, 0)
    gen.write(:ATC)
    gen.write(:RET_V)
  end

  def generate_rblc(gen)
    gen.label_function('rblc')
    gen.set_current_function('rblc')
    gen.add_variable(TypeString.new, '0', 0)

    gen.write(:PEEK, 0)
    gen.write(:RBLC)
    gen.write(:RET)
  end

  def generate_bblc(gen)
    gen.label_function('bblc')
    gen.set_current_function('bblc')
    gen.add_variable(TypeString.new, '0', 0)

    gen.write(:PEEK, 0)
    gen.write(:BBLC)
    gen.write(:RET)
  end
end
