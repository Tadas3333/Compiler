
class VirtualMachine
  def initialize
    @code_base = 2000
    @memory = Array.new(8000, 0)
    @ip = @code_base
    @sp = 4000
    @fp = 0
  end

  def run(code)
    @memory[@ip, code.size] = code
    loop do
    #  puts "DEBUG: @ip=#{@ip}, @memory[@ip]=#{@memory[@ip]}/hex=#{@memory[@ip].to_s(16)}, @sp=#{@sp}, @memory[@sp]=#{@memory[@sp]}, @fp=#{@fp}, @memory[@fp]=#{@memory[@fp]}..."
      opcode = @memory[@ip]
      case opcode
      when 99; b = pop; a = pop; push(a+b);
      when 100; b = pop; a = pop; push(a*b);
      when 200; b = pop; a = pop; push(a-b);
      when 300; b = pop; a = pop; push(a/b);
      when 400; push(!pop);
      when 500; push(-pop);
      when 600; adress = load_operand; push(@memory[@fp+adress]);
      when 700; adress = load_operand; value = pop;  @memory[@fp+adress] = value;
      when 800; pop;
      when 900; value = load_operand; push(value);
      when 1000; call_function;
      when 1100; adress = load_operand; @ip = @code_base+adress-1;
      when 1200
        adress = load_operand
        value = pop
        if value == 0
          @ip = @code_base+adress-1
        end
      when 1300; return_back
      when 1400; value = pop; return_back(value)
      when 1500; b = pop; a = pop; push((a == b) ? 1 : 0);
      when 1600; b = pop; a = pop; push((a >= b) ? 1 : 0);
      when 1700; b = pop; a = pop; push((a <= b) ? 1 : 0);
      when 1800; b = pop; a = pop; push((a != b) ? 1 : 0);
      when 1900; b = pop; a = pop; push((a >= b) ? 1 : 0);
      when 2000; b = pop; a = pop; push((a < b) ? 1 : 0);
      when 2100; b = pop; a = pop; push((a && b) ? 1 : 0);
      when 2200; b = pop; a = pop; push((a || b) ? 1 : 0);
      when 2300; oper = load_operand; puts ":PRINT(stack at -#{oper}): #{@memory[@sp-oper]}";
      when 2400; value = load_operand; puts ":PRINT_VAL: #{value}";
      when 2500; break;
      else; raise "unknown instruction #{opcode}"
      end

      @ip += 1
    end
  end

  def load_operand
    @ip += 1
    return @memory[@ip]
  end

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
      @memory[@fp-3] = value
    end

    @ip = @memory[@fp-1]
    old_fp = @memory[@fp-2]

    # Pop all variables till return_value+1
    while @sp > (@fp-2) do
      pop
    end

    @fp = old_fp
  end

  def push(value)
    @memory[@sp] = value
    @sp += 1
  end

  def pop
    @sp -= 1
    value = @memory[@sp]
    return value
  end
end
