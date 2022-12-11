# typed: strict
require "./util.rb"

class Solution < BaseSolution
  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part1(input)
    chunks = input.chunk { |s| s.empty? ? nil : true }.map { _2.map(&:to_i) }
    chunks.map(&:sum).max
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part2(input)
    chunks = input.chunk { |s| s.empty? ? nil : true }.map { _2.map(&:to_i) }
    chunks.map(&:sum).sort.last(3).sum
  end
end

if __FILE__ == $0
  Solution.run
end
