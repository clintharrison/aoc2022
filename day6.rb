# typed: strict
require_relative "./util.rb"

class Solution < BaseSolution
  sig { params(stream: String, marker_length: Integer).returns(T.nilable(Integer)) }
  def find_marker(stream, marker_length = 4)
    recv = T.let([], T.nilable(T::Array[String]))
    marker_end = stream.split("").find_index do |c|
      if recv&.length == marker_length
        recv = recv&.slice(1, marker_length - 1)
        recv&.push(c)

        if recv&.uniq&.length == marker_length
          true
        else
          false
        end
      else
        recv&.push(c)
        false
      end
    end

    # answer must be _after_ the end of the marker
    T.must(marker_end) + 1
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part1(input)
    input.map do |stream|
      find_marker(stream)
    end
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part2(input)
    input.map do |stream|
      find_marker(stream, 14)
    end
  end
end

if __FILE__ == $0
  Solution.run
end
