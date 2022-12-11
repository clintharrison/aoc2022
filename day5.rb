# typed: strict
require "./util.rb"
require "set"

class Solution < BaseSolution
  sig { params(lines: T::Array[String]).returns(T::Array[T::Array[String]]) }
  def parse_crates(lines)
    # drop the numbers at the bottom
    lines = lines[...-1]
    # Given this input
    # ["    [D]    ",
    #  "[N] [C]    ",
    #  "[Z] [M] [P]"]
    # Split into separate crates, then transpose to get each stack, and reverse so the top is the last element
    crates = T.must(lines).map { _1.split("").each_slice(4).to_a.map(&:join).map(&:strip) }.transpose.map(&:reverse)
    # Get rid of the empty ones, and then just keep the letter
    stacks = crates.map { _1.reject(&:empty?) }.map { |stack| stack.map { T.must(_1[1]) } }
    stacks
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part1(input)
    separator_line = T.must(input.find_index(""))
    crates = T.must(input[...separator_line])
    moves = T.must(input[separator_line + 1..])

    stacks = parse_crates(crates)
    moves.each do |move_line|
      require "pry"

      amount, src, dst = T.must(move_line.match(/move (\d+) from (\d+) to (\d+)/)).captures

      amount.to_i.times do
        src_idx = src.to_i - 1
        dst_idx = dst.to_i - 1

        T.must(stacks[dst_idx]).push(T.must(T.must(stacks[src_idx]).pop))
      end
    end

    stacks.map { _1.last }.join
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part2(input)
    separator_line = T.must(input.find_index(""))
    crates = T.must(input[...separator_line])
    moves = T.must(input[separator_line + 1..])

    stacks = parse_crates(crates)
    moves.each do |move_line|
      require "pry"

      amount, src, dst = T.must(move_line.match(/move (\d+) from (\d+) to (\d+)/)).captures

      src_idx = src.to_i - 1
      dst_idx = dst.to_i - 1
      src_stack = T.must(stacks[src_idx])
      dst_stack = T.must(stacks[dst_idx])

      T.unsafe(dst_stack).append(*src_stack.pop(amount.to_i))
    end

    stacks.map { _1.last }.join
  end
end

if __FILE__ == $0
  Solution.run
end
