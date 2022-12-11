# typed: strict
require "./util.rb"
require "set"

class Solution < BaseSolution
  sig { params(item: String).returns(Integer) }
  def priority(item)
    if "a" <= item and item <= "z"
      1 + item.ord - "a".ord
    else
      27 + item.ord - "A".ord
    end
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part1(input)
    input
      .map do |rucksack|
        first, second = rucksack[...rucksack.length / 2], rucksack[rucksack.length / 2..]
        fs, ss = Set.new(T.must(first).split("")), Set.new(T.must(second).split(""))
        item = (fs & ss).first

        priority(item)
      end
      .sum
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part2(input)
    input
      .each_slice(3)
      .to_a
      .map do |slice|
        slice.map { Set.new(_1.split("")) }.reduce(:&)
      end
      .map { priority(_1.first) }
      .sum
  end
end

if __FILE__ == $0
  Solution.run
end
