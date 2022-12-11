# typed: strict
require "./util.rb"
require "set"

class Solution < BaseSolution
  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part1(input)
    input
      .map do |line|
        line.split(",").map { |pair| pair.split("-") }.flatten.map(&:to_i)
      end
      .select do |a, b, c, d|
        a, b, c, d = T.must(a), T.must(b), T.must(c), T.must(d)
        (c >= a && d <= b) || (a >= c && b <= d)
      end
      .length
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part2(input)
    input
      .map do |line|
        line.split(",").map { |pair| pair.split("-") }.flatten.map(&:to_i)
      end
      .select do |a, b, c, d|
        a, b, c, d = T.must(a), T.must(b), T.must(c), T.must(d)
        (c >= a && c <= b) || (a >= c && a <= d)
      end
      .length
  end
end

if __FILE__ == $0
  Solution.run
end
