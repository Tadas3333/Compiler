require 'io/console'
require 'timeout'
require 'colorize'

class TrueClass; def to_i; 1; end; end
class FalseClass; def to_i; 0; end; end

class VirtualMachine
  def initialize
    @code_base = 2000
    @memory = Array.new(20000, 0)
    @ip = @code_base
    @sp = 8000
    @fp = 0
    @pp = 14000
    @rp = 0
  end

  def run(file, strings)
    code = read_code(file)
    @strings = strings
    @memory[@ip, code.size] = code

    loop do
      opcode = @memory[@ip]
      case opcode
      when 100; b = pop; a = pop; push(a+b);
      when 200; b = pop; a = pop; push(a*b);
      when 300; b = pop; a = pop; push(a-b);
      when 400; b = pop; a = pop; push(a/b);
      when 500; b = pop; a = pop; push(a%b);
      when 600; push(!pop);
      when 700; push(-pop);
      when 800; adress = load_operand; push(@memory[@fp+adress]);
      when 900; adress = load_operand; value = pop;  @memory[@fp+adress] = value;
      when 1000; pop;
      when 1100; value = load_operand; push(value);
      when 1200; value = load_operand; push_f(value);
      when 1300; call_function;
      when 1400; adress = load_operand; @ip = @code_base+adress-1;
      when 1500
        adress = load_operand
        value = pop
        if value == 0
          @ip = @code_base+adress-1
        end
      when 1600; return_back
      when 1700; value = pop; return_back(value)
      when 1800; b = pop; a = pop; push((a == b).to_i);
      when 1900; b = pop; a = pop; push((a >= b).to_i);
      when 2000; b = pop; a = pop; push((a <= b).to_i);
      when 2100; b = pop; a = pop; push((a != b).to_i);
      when 2200; b = pop; a = pop; push((a > b).to_i);
      when 2300; b = pop; a = pop; push((a < b).to_i);
      when 2400; b = pop; a = pop; push((to_bool(a) && to_bool(b)).to_i);
      when 2500; b = pop; a = pop; push((to_bool(a) || to_bool(b)).to_i);
      when 2600
         value = pop;

         unless value.is_a?(String)
           value = @strings.at(value)
         end

         print "#{value}"

      when 2700; input = STDIN.gets; push(input)
      when 2800; value = pop; push(value.to_s)
      when 2900; value = pop; push(value.to_i)
      when 3000; value = pop; push(value.to_s);
      when 3100; break;
      when 3200; peek_p;
      when 3300; poke_p;
      when 3400; size = pop; push(allocate_memory(size));
      when 3500; indx = load_operand; sleep((@memory[@fp+indx].to_f)/1000);
      when 3600; puts "\e[H\e[2J";
      when 3700
        begin
          status = Timeout::timeout(0.05) {
            c = STDIN.getch
            if c == 'a'
              push(1)
            else
              push(0)
            end
          }
        rescue Timeout::Error
          push(0)
        end
      when 3800
        begin
          status = Timeout::timeout(0.05) {
            c = STDIN.getch
            if c == 'd'
              push(1)
            else
              push(0)
            end
          }
        rescue Timeout::Error
          push(0)
        end
      when 3900
        value = pop
        case value
        when 1; print "\e[37m"
        when 2; print "\e[31m"
        when 3; print "\e[34m"
        when 4; print "\e[32m"
        else; print "\e[0m"
        end
      when 4000
        begin
          status = Timeout::timeout(0.05) {
            c = STDIN.getch
            if c == 'r'
              push(1)
            else
              push(0)
            end
          }
        rescue Timeout::Error
          push(0)
        end
      when 4100
        value = pop
        push(value.chr)
      when 4200
         value = pop;

         unless value.is_a?(String)
           value = @strings.at(value)
         end

         print "#{value}".colorize(:background => :red)
       when 4300
          value = pop;

          unless value.is_a?(String)
            value = @strings.at(value)
          end

          print "#{value}".colorize(:background => :blue)
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
      push_p(0)
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
    if pointer < 0
      raise "negative pointer #{pointer}"
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

    if pointer < 0
      raise "negative pointer #{pointer}"
    end

    value = pop
    @memory[pointer] = value
  end

  def push(value)
    @memory[@sp] = value
    @sp += 1

    if @sp >= 14000
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

  def to_bool(val)
    if val >= 1
      return true
    end

    false
  end
end
