# typed: strict
require_relative "./util.rb"

class TurnResult < T::Struct
  const :item, Integer
  const :recipient, Integer
end

class Monkey < T::Struct
  const :id, Integer
  prop :items, T::Array[Integer]
  const :operation_str, String
  const :divisible_by, Integer
  const :true_monkey, Integer
  const :false_monkey, Integer

  prop :inspection_count, Integer, default: 0

  sig { params(item: Integer).void }
  def add_item(item)
    @items << item
  end

  sig { params(item: Integer).returns(Integer) }
  private def do_op(item)
    operation_str = @operation_str.sub(/new = /, "")
    left, op, right = operation_str.split(" ")
    left = if left == "old"
      item
    else
      left.to_i
    end

    right = if right == "old"
      item
    else
      right.to_i
    end

    if op == "+"
      left + right
    elsif op == "*"
      left * right
    else
      raise "Unknown operator #{op}"
    end
  end

  sig { params(global_divisor: Integer, worry_divisor: Integer).returns(T::Array[TurnResult]) }
  def run_turn(global_divisor, worry_divisor = 3)
    # puts("\n== Monkey #{@id} ==")
    items = @items
    @items = []
    items.map do |item|
      # puts("Monkey inspects an item with worry level of #{item}")
      @inspection_count += 1

      # After each monkey inspects an item but before it tests your worry level,
      # your relief that the monkey's inspection didn't damage the item causes your
      # worry level to be divided by three and rounded down to the nearest integer.
      new_ = do_op(item) / worry_divisor
      new_ %= global_divisor

      # puts("  Monkey gets bored. Worry level is divided by 3 to #{new_}")
      TurnResult.new(
        item: new_,
        recipient: if new_ % @divisible_by == 0
          # puts("  Worry level is divisible by #{@divisible_by}. Item with level #{new_} thrown to #{@true_monkey}")
          @true_monkey
        else
          # puts("  Worry level is NOT divisible by #{@divisible_by}. Item with level #{new_} thrown to #{@false_monkey}")
          @false_monkey
        end
      )
    end
  end
end

class Solution < BaseSolution
  def initialize
    @monkeys = T.let({}, T::Hash[Integer, Monkey])
  end

  sig { params(raw: T::Array[T::Array[String]]).void }
  def parse_monkeys(raw)
    raw.each do |monkey|
      /Monkey (\d+):/.match(monkey.shift)
      monkey_id = T.must(Regexp.last_match(1)).to_i
      starting_items = T.must(monkey.shift).scan(/\d+/).map { _1.to_s.to_i }
      operation_str = T.must(T.must(monkey.shift).match(/Operation: (.*)/))[1]

      test_ = T.must(T.must(monkey.shift).match(/Test: divisible by (\d+)/))[1]
      true_cond = T.must(T.must(monkey.shift).match(/If true: throw to monkey (\d+)/))[1]
      false_cond = T.must(T.must(monkey.shift).match(/If false: throw to monkey (\d+)/))[1]

      @monkeys[monkey_id] = Monkey.new(
        id: monkey_id,
        items: starting_items,
        operation_str: T.must(operation_str),
        divisible_by: test_.to_i,
        true_monkey: true_cond.to_i,
        false_monkey: false_cond.to_i
      )
    end
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part1(input)
    monkeys = input.join("\n").split("\n\n").map { _1.split("\n") }
    parse_monkeys(monkeys)

    round_count = 20

    global_divisor = T.must(@monkeys.values.map(&:divisible_by).reduce(&:*))

    round_count.times do |round|
      @monkeys.each do |i, monkey|
        results = monkey.run_turn(global_divisor)
        results.each do |result|
          @monkeys.fetch(result.recipient).add_item(result.item)
        end
      end

      @monkeys.map do |i, monkey|
        "Monkey #{monkey.id}: #{monkey.items.join(", ")}"
      end
    end

    @monkeys.each do |i, monkey|
      puts("Monkey #{monkey.id} inspected items #{monkey.inspection_count} times")
    end

    T.must(@monkeys.values.map(&:inspection_count).sort.slice(-2, 2)).reduce(&:*)
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part2(input)
    monkeys = input.join("\n").split("\n\n").map { _1.split("\n") }
    parse_monkeys(monkeys)

    round_count = 10_000
    global_divisor = T.must(@monkeys.values.map(&:divisible_by).reduce(&:*))

    round_count.times do |round|
      @monkeys.each do |i, monkey|
        results = monkey.run_turn(global_divisor, worry_divisor = 1)
        results.each do |result|
          @monkeys.fetch(result.recipient).add_item(result.item)
        end
      end

      if [1, 20, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000].include?(round + 1)
        puts("== After round #{round + 1} ==")
        @monkeys.each do |i, monkey|
          puts("Monkey #{monkey.id} inspected items #{monkey.inspection_count} times")
        end

        puts
      end
    end

    T.must(@monkeys.values.map(&:inspection_count).sort.slice(-2, 2)).reduce(&:*)
  end
end

if __FILE__ == $0
  Solution.run
end
