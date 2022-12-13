# typed: strict
require_relative "./util.rb"

class Op
  extend T::Helpers
  abstract!

  sig { returns(Integer) }
  attr_reader :exec_cycle

  sig { params(exec_cycle: Integer).void }
  def initialize(exec_cycle)
    @exec_cycle = exec_cycle
  end

  sig { abstract.params(x: Integer).returns(Integer) }
  def do(x)
  end
end

class AddX < Op
  sig { params(exec_cycle: Integer, value: Integer).void }
  def initialize(exec_cycle, value)
    @exec_cycle = exec_cycle
    @value = value
  end

  sig { override.params(x: Integer).returns(Integer) }
  def do(x)
    return x + @value
  end
end

class Cpu
  CRT_WIDTH = 40

  sig { returns(Integer) }
  attr_reader :cycle

  sig { returns(T::Hash[Integer, Integer]) }
  attr_reader :signal_strengths

  sig { params(interesting_cycles: T::Array[Integer]).void }
  def initialize(interesting_cycles)
    @cycle = T.let(1, Integer)
    @in_flight = T.let([], T::Array[Op])
    @register_x = T.let(1, Integer)
    @interesting_cycles = T.let(interesting_cycles.sort, T::Array[Integer])
    @signal_strengths = T.let({}, T::Hash[Integer, Integer])
  end

  sig { params(op: Op).void }
  def add_op(op)
    @in_flight << op
  end

  sig { returns(Integer) }
  def signal_strength
    @register_x * @cycle
  end

  sig { void }
  def draw!
    pixel_pos = (@cycle - 1) % CRT_WIDTH
    if [@register_x - 1, @register_x, @register_x + 1].include?(pixel_pos)
      print("#")
    else
      print(".")
    end

    if pixel_pos == CRT_WIDTH - 1
      print("\n")
    end
  end

  sig { void }
  def tick
    # puts("Start of cycle \##{@cycle}: X is #{@registers[:X]}")

    if @interesting_cycles.include?(@cycle)
      @signal_strengths[@cycle] = signal_strength
    end

    draw!

    @in_flight
      .filter do
        _1.exec_cycle == @cycle
      end
      .each do
        @register_x = _1.do(@register_x)
      end

    @cycle += 1
  end

  sig { returns(T::Boolean) }
  def done?
    @in_flight.empty?
  end

  sig { returns(Integer) }
  def X
    @register_x
  end
end

class Solution < BaseSolution
  def initialize
    @cpu = T.let(Cpu.new([20, 60, 100, 140, 180, 220]), Cpu)
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part1(input)
    @cpu = Cpu.new([20, 60, 100, 140, 180, 220])

    input.each do |line|
      instr, val = line.split(" ")
      if instr == "noop"
        # Do nothing but tick forward one cycle
        @cpu.tick
      else
        @cpu.add_op(AddX.new(@cpu.cycle + 1, val.to_i))
        @cpu.tick
        @cpu.tick
      end
    end

    pp(@cpu.signal_strengths)
    @cpu.signal_strengths.values.sum
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part2(input)
    @cpu = Cpu.new([20, 60, 100, 140, 180, 220])
    crt_width = 40
    crt_height = 6

    input.each do |line|
      instr, val = line.split(" ")
      if instr == "noop"
        # Do nothing but tick forward one cycle
        @cpu.tick
      else
        @cpu.add_op(AddX.new(@cpu.cycle + 1, val.to_i))
        @cpu.tick
        @cpu.tick
      end
    end

    nil
  end
end

if __FILE__ == $0
  Solution.run
end
