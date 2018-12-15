
class TrueClass; def to_i; 1; end; end
class FalseClass; def to_i; 0; end; end

class VirtualMachine
  def initialize
    @code_base = 2000
    @memory = Array.new(8000, 0)
    @ip = @code_base
    @sp = 4000
    @fp = 0
    @pp = 6000
    @rp = 0
  end

  def run(file, strings)
    code = read_code(file)
    @strings = strings
    @memory[@ip, code.size] = code
    loop do
      opcode = @memory[@ip]
      case opcode
      when 0x0; b = pop; a = pop; push(a+b);
      when 0x1; b = pop; a = pop; push(a*b);
      when 0x2; b = pop; a = pop; push(a-b);
      when 0x3; b = pop; a = pop; push(a/b);
      when 0x4; b = pop; a = pop; push(a%b);
      when 0x5; push(!pop);
      when 0x6; push(-pop);
      when 0x7; adress = load_operand; push(@memory[@fp+adress]);
      when 0x8; adress = load_operand; value = pop;  @memory[@fp+adress] = value;
      when 0x9; pop;
      when 0x10; value = load_operand; push(value);
      when 0x11; value = load_operand; push_f(value);
      when 0x12; call_function;
      when 0x13; adress = load_operand; @ip = @code_base+adress-1;
      when 0x14
        adress = load_operand
        value = pop
        if value == 0
          @ip = @code_base+adress-1
        end
      when 0x15; return_back
      when 0x16; value = pop; return_back(value)
      when 0x17; b = pop; a = pop; push((a == b).to_i);
      when 0x18; b = pop; a = pop; push((a >= b).to_i);
      when 0x19; b = pop; a = pop; push((a <= b).to_i);
      when 0x20; b = pop; a = pop; push((a != b).to_i);
      when 0x21; b = pop; a = pop; push((a > b).to_i);
      when 0x22; b = pop; a = pop; push((a < b).to_i);
      when 0x23; b = pop; a = pop; push((a && b).to_i);
      when 0x24; b = pop; a = pop; push((a || b).to_i);
      when 0x25
         value = pop;

         unless value.is_a?(String)
           value = @strings.at(value)
         end

         print "#{value}"

      when 0x26; input = STDIN.gets; push(input)
      when 0x27; value = pop; push(value.to_s)
      when 0x28; value = pop; push(value.to_i)
      when 0x29; value = pop; push(value.to_s);
      when 0x30; break;
      when 0x31; peek_p;
      when 0x32; poke_p;
      when 0x33; size = pop; push(allocate_memory(size));
      else; raise "unknown instruction #{opcode}"
      end

      @ip += 1
    end
  end

  def read_code(file)
    read_info = IO.binread(file)
    len = read_info.unpack("s")[0]
    code = read_info.unpack("s" * len)
    code.shift
    return code
  end

  def load_operand
    @ip += 1
    return @memory[@ip]
  end

  #

  #return_value old_@fp return_adress fp->val1 val2 val3 sp->___
  def call_function
    arguments_count = load_operand
    jump_adress = pop
    @memory[@sp-arguments_count-1] = @ip # Save return adress
    @memory[@sp-arguments_count-2] = @fp # Save @fp
    @fp = @sp-arguments_count # Points at first variable in stack
    @ip = @code_base+jump_adress-1
  end

  def return_back(value = nil)
    if value != nil
      if value.is_a?(Float)
        value = [value].pack("f").unpack("i")[0]
      end

      @memory[@fp-3] = value
    end

    @ip = @memory[@fp-1]
    old_fp = @memory[@fp-2]

    # Pop all variables till return_value+1
    # Frees up memory used in a function
    while @sp > (@fp-2) do
      pop
    end

    @sp = @fp-2
    @fp = old_fp
  end

  def allocate_memory(size)
    if size < 0
      raise 'negative allocation size'
    end

    pointer_adress = @pp.clone

    indx = 0
    while indx < size do
      push_p(-1)
      indx += 1
    end

    return pointer_adress
  end

  def peek_p
    adress = load_operand
    pointer = @memory[@fp+adress]
    indexes = pop;
    first = true

    while indexes > 0 do
      indx = pop

      if first
        pointer = pointer+indx
        first = false
      else
        pointer = @memory[pointer] + indx
      end

      indexes -= 1
    end

    push(@memory[pointer])
  end

  def poke_p
    adress = load_operand
    pointer = @memory[@fp+adress]
    indexes = pop;
    first = true

    while indexes > 0 do
      indx = pop

      if first
        pointer = pointer+indx
        first = false
      else
        pointer = @memory[pointer] + indx
      end

      indexes -= 1
    end

    value = pop
    @memory[pointer] = value
  end

  def push(value)
    @memory[@sp] = value
    @sp += 1

    if @sp >= @pp
      raise 'stack overflow'
    end
  end

  def push_p(value)
    @memory[@pp] = value
    @pp += 1

    if @pp >= @memory.size
      raise 'memory overflow'
    end
  end

  def push_f(value)
    @memory[@sp] = [value].pack("i").unpack("f")[0]
    @sp += 1
  end

  def pop
    @sp -= 1
    value = @memory[@sp]
    return value
  end

  def show_memory(from, to)
    indx = from
    print '['
    while indx <= to do
      print "#{@memory[indx]}, "
      indx += 1
    end
    puts "]"
  end
end
