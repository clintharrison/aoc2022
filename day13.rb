# typed: strict
require_relative "./util.rb"

class Solution < BaseSolution
  sig { params(left: T.untyped, right: T.untyped).returns(T.nilable(T::Boolean)) }
  def right_order?(left, right)
    puts("Compare #{left} vs #{right}")
    if left.is_a?(Integer) && right.is_a?(Integer)
      if left < right
        puts("Left is smaller, right order")
        return true
      elsif left > right
        puts("Right is smaller, wrong order")
        return false
      end
    elsif left.is_a?(Integer) && right.is_a?(Array)
      puts("Converting left #{left} to array #{[left]}")
      return right_order?([left], right)
    elsif left.is_a?(Array) && right.is_a?(Integer)
      puts("Converting right #{right} to array #{[right]}")
      return right_order?(left, [right])
    elsif left.is_a?(Array) && right.is_a?(Array)
      if left.empty? && !right.empty?
        return true
      elsif right.empty? && !left.empty?
        return false
      end

      left.length.times do |left_i|
        # Right side ran out of items? Wrong order!
        if right[left_i].nil?
          puts("Right side ran out of items, wrong order")
          return false
        end

        attempt = right_order?(left[left_i], right[left_i])
        if !attempt.nil?
          return attempt
        end

        if left_i == left.length - 1 && left_i < right.length - 1
          puts("Left side ran out of items, right order")
          return true
        end
      end
    end

    nil
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part1(input)
    pairs = input.slice_when { _1.empty? }.to_a.map { _1.reject(&:empty?) }
    parsed_pairs = T.let(pairs.map { |pair| pair.map { JSON.parse(_1) } }, T::Array[[T.untyped, T.untyped]])

    in_order_pairs = []
    parsed_pairs.each_with_index do |pair, idx|
      left, right = pair.fetch(0), pair.fetch(1)

      puts("== Pair #{idx + 1} ==")

      if right_order?(left, right)
        puts("Right order!")
        # pairs are 1-based
        in_order_pairs << idx + 1
      else
        puts("Wrong order!")
      end
    end

    puts
    pp(in_order_pairs)
    puts
    in_order_pairs.sum
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part2(input)
    packets = input.reject(&:empty?).map { JSON.parse(_1) }
    packets.push([[2]])
    packets.push([[6]])

    in_order_packets = packets.sort do |a, b|
      if right_order?(a, b)
        -1
      elsif right_order?(b, a)
        1
      else
        raise
      end
    end

    div_packet_1 = T.must(in_order_packets.find_index([[2]])) + 1
    div_packet_2 = T.must(in_order_packets.find_index([[6]])) + 1

    div_packet_1 * div_packet_2
  end
end

if __FILE__ == $0
  Solution.run
end
