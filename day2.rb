# typed: strict
require_relative "./util.rb"

class Solution < BaseSolution
  class Outcome < T::Enum
    enums do
      Loss = new
      Draw = new
      Win = new
    end

    sig { params(s: String).returns(Solution::Outcome) }
    def self.from_part2(s)
      case s
      when "X"
        Loss
      when "Y"
        Draw
      when "Z"
        Win
      else
        raise "Unexpected value '#{s}' for Outcome"
      end
    end

    sig { params(shape: Shape).returns(Integer) }
    def score(shape)
      outcome_score = case self
      when Loss
        0
      when Draw
        3
      when Win
        6
      else
        T.absurd(self)
      end

      shape_score = case shape
      when Rock
        1
      when Paper
        2
      when Scissors
        3
      else
        T.absurd(shape)
      end

      outcome_score + shape_score
    end
  end

  class Player < T::Enum
    enums do
      Me = new
      Opponent = new
    end
  end

  class Shape
    extend T::Helpers
    abstract!
    sealed!

    @@shapes = T.let(
      nil,
      T.untyped
    )

    sig { params(player: Player).void }
    def initialize(player)
      @player = T.let(player, Player)
    end

    sig { abstract.returns(String) }
    def serialize
    end

    sig { abstract.params(other: Shape).returns(Outcome) }
    def outcome?(other)
    end

    sig { returns(String) }
    def to_s
      "<#{self.class} (#{@player.serialize})>"
    end

    sig { returns(String) }
    def inspect
      to_s
    end

    sig { returns(T::Array[Shape]) }
    def self.all_shapes
      @@shapes ||= [
        Rock.new(Player::Me),
        Rock.new(Player::Opponent),
        Paper.new(Player::Me),
        Paper.new(Player::Opponent),
        Scissors.new(Player::Me),
        Scissors.new(Player::Opponent)
      ]
      @@shapes
    end

    sig { params(letter: String).returns(T.nilable(Shape)) }
    def self.deserialize(letter)
      all_shapes.each do |shape|
        if shape.serialize == letter
          return shape
        end
      end

      nil
    end
  end

  class Rock < Shape
    sig { override.returns(String) }
    def serialize
      if @player == Player::Me
        "X"
      else
        "A"
      end
    end

    sig { override.params(other: Shape).returns(Outcome) }
    def outcome?(other)
      case other
      when Rock
        Outcome::Draw
      when Paper
        Outcome::Loss
      when Scissors
        Outcome::Win
      else
        T.absurd(other)
      end
    end
  end

  class Paper < Shape
    sig { override.returns(String) }
    def serialize
      if @player == Player::Me
        "Y"
      else
        "B"
      end
    end

    sig { override.params(other: Shape).returns(Outcome) }
    def outcome?(other)
      case other
      when Rock
        Outcome::Win
      when Paper
        Outcome::Draw
      when Scissors
        Outcome::Loss
      else
        T.absurd(other)
      end
    end
  end

  class Scissors < Shape
    sig { override.returns(String) }
    def serialize
      if @player == Player::Me
        "Z"
      else
        "C"
      end
    end

    sig { override.params(other: Shape).returns(Outcome) }
    def outcome?(other)
      case other
      when Rock
        Outcome::Loss
      when Paper
        Outcome::Win
      when Scissors
        Outcome::Draw
      else
        T.absurd(other)
      end
    end
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part1(input)
    input
      .map do
        _1.split.map { |l| Shape.deserialize(l) }
      end
      .map do |op_shape, my_shape|
        my_shape = T.must(my_shape)
        op_shape = T.must(op_shape)

        outcome = my_shape.outcome?(op_shape)
        outcome.score(my_shape)
      end
      .sum
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part2(input)
    input
      .map do
        op, outcome = _1.split
        [Shape.deserialize(T.must(op)), Outcome.from_part2(T.must(outcome))]
      end
      .map do |op_shape, expected_outcome|
        op_shape = T.must(op_shape)
        my_shape = [Rock.new(Player::Me), Paper.new(Player::Me), Scissors.new(Player::Me)].find do |me|
          me.outcome?(op_shape) == expected_outcome
        end

        my_shape = T.must(my_shape)

        my_shape.outcome?(op_shape).score(my_shape)
      end
      .sum
  end
end

if __FILE__ == $0
  Solution.run
end
