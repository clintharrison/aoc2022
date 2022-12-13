# typed: strict
require_relative "./util.rb"

class Knot
  sig { returns(Integer) }
  attr_accessor :x
  sig { returns(Integer) }
  attr_accessor :y

  sig { returns(T.nilable(Knot)) }
  attr_accessor :parent

  sig { returns(String) }
  attr_accessor :name

  sig { params(x: Integer, y: Integer, name: String, parent: T.nilable(Knot)).void }
  def initialize(x, y, name:, parent: nil)
    @x = x
    @y = y
    @name = name
    @parent = parent
  end

  sig { returns(String) }
  def inspect
    "#<Knot x=#{@x} y=#{@y} name=#{@name} parent=#{@parent.to_s}>"
  end

  sig { void }
  def update
    parent = self.parent()
    if parent.nil?
      raise "Cannot call on head knot"
    end
    # tail is directly u/d/l/r from the tail
    dx, dy = parent.x - @x, parent.y - y

    if [-1, 0, 1].include?(dx) && [-1, 0, 1].include?(dy)
      # no need to move tail, it's fine
    elsif dx == 0 && dy == -2
      @y -= 1
    elsif dx == 0 and dy == 2
      @y += 1
    elsif dy == 0 && dx == -2
      @x -= 1
    elsif dy == 0 && dx == 2
      @x += 1
    else
      # Move diagonally
      if dx < 0
        @x -= 1
      elsif dx > 0
        @x += 1
      end

      if dy < 0
        @y -= 1
      elsif dy > 0
        @y += 1
      end
    end
  end
end

class Solution < BaseSolution
  sig { void }
  def initialize
    @knots = T.let([], T::Array[Knot])
    @visited = T.let(Hash.new(false), T::Hash[[Integer, Integer], T::Boolean])
  end

  sig { params(knot_count: Integer).void }
  def reset(knot_count = 2)
    @knots = []
    knot_count.times do |i|
      name = if i == 0
        "H"
      else
        i.to_s
      end

      @knots << Knot.new(0, 0, name: name, parent: @knots[i - 1])
    end

    @visited = Hash.new(false)
  end

  sig { void }
  private def print_board!
    (-15..5).each do |y|
      (-11..14).each do |x|
        knot_here = @knots.find { |k| k.x == x && k.y == y }
        if !knot_here.nil?
          print(knot_here.name)
        else
          print(".")
        end
      end

      print("\n")
    end

    print("\n")
  end

  sig { returns(Knot) }
  private def head_knot
    T.must(@knots.first)
  end

  sig { returns(T::Array[Knot]) }
  private def tail_knots
    T.must(@knots[1..])
  end

  sig { params(knot: Knot).void }
  private def set_visited!(knot)
    @visited[[knot.x, knot.y].freeze] = true
  end

  # this handles a _single_ move
  sig { params(direction: String).void }
  def move(direction)
    head = T.must(@knots.first)
    case direction
    when "U"
      head.y -= 1
    when "D"
      head.y += 1
    when "L"
      head.x -= 1
    when "R"
      head.x += 1
    end

    tail_knots.each do |knot|
      knot.update
    end
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part1(input)
    reset
    set_visited!(head_knot)

    # puts("== Initial State ==")
    # print_board!

    input.each do |line|
      # move head
      direction, distance = line.split(" ")

      direction = T.must(direction)
      distance = distance.to_i

      # puts("== #{direction} #{distance} ==\n")

      distance.times {
        move(direction)
        set_visited!(T.must(@knots.last))
      }
    end

    # Unique positions visited by the tail
    @visited.values.length
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part2(input)
    reset(knot_count = 10)
    set_visited!(head_knot)

    # puts("== Initial State ==")
    # print_board!

    input.each do |line|
      # move head
      direction, distance = line.split(" ")

      direction = T.must(direction)
      distance = distance.to_i

      # puts("== #{direction} #{distance} ==\n")

      distance.times {
        move(direction)
        set_visited!(T.must(@knots.last))
      }
      # print_board!
      # binding.pry
    end

    # Unique positions visited by the tail
    @visited.values.length
  end
end

if __FILE__ == $0
  Solution.run
end
