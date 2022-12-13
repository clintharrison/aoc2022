# typed: strict
require_relative "./util.rb"

class Solution < BaseSolution
  Grid = T.type_alias { T::Array[T::Array[Integer]] }

  sig { void }
  def initialize
    @grid = T.let([], Grid)
  end

  sig { params(row: Integer, col: Integer).returns(T::Array[Integer]) }
  def left_of(row, col)
    T.must(@grid.fetch(row)[...col])
  end

  sig { params(row: Integer, col: Integer).returns(T::Array[Integer]) }
  def right_of(row, col)
    T.must(@grid.fetch(row)[col + 1..])
  end

  sig { params(row: Integer, col: Integer).returns(T::Array[Integer]) }
  def top_of(row, col)
    T.must(@grid[...row]).map { T.must(_1[col]) }
  end

  sig { params(row: Integer, col: Integer).returns(T::Array[Integer]) }
  def bottom_of(row, col)
    T.must(@grid[row + 1..]).map { T.must(_1[col]) }
  end

  sig { params(row: Integer, col: Integer).returns(T::Boolean) }
  def visible?(row, col)
    return true if row == 0
    return true if row == T.must(@grid[0]).length - 1
    return true if col == 0
    return true if col == T.must(@grid[0]).length - 1

    height = T.must(T.must(@grid[row])[col])
    return true if left_of(row, col).all? { _1 < height }
    return true if right_of(row, col).all? { _1 < height }
    return true if top_of(row, col).all? { _1 < height }
    return true if bottom_of(row, col).all? { _1 < height }

    return false
  end

  sig { params(trees: T::Array[Integer], height: Integer).returns(Integer) }
  def array_score(trees, height)
    score = 0
    trees.each do |tree|
      if tree < height
        score += 1
      else
        score += 1
        break
      end
    end

    score
  end

  sig { params(row: Integer, col: Integer).returns(Integer) }
  def scenic_score(row, col)
    height = T.must(T.must(@grid[row])[col])

    # go from current position *up*, so order is wrong
    left_score = array_score(left_of(row, col).reverse, height)
    right_score = array_score(right_of(row, col), height)
    up_score = array_score(top_of(row, col).reverse, height)
    down_score = array_score(bottom_of(row, col), height)

    [left_score, right_score, down_score, up_score].reduce(1, &:*)
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part1(input)
    @grid = input.map { _1.split("").map(&:to_i) }

    @scenic_scores = T.let(
      Array.new(@grid.length) { Array.new(T.must(@grid[0]&.length)) },
      T.nilable(Grid)
    )

    visible_count = 0
    @grid.each_index do |row|
      @grid[row]&.each_index do |col|
        if visible?(row, col)
          # print("1")
          visible_count += 1
        else
          # print("0")
        end

        r = T.must(@scenic_scores).fetch(row)
        r[col] = scenic_score(row, col)
      end
    end

    puts("Visible count: #{visible_count}")
    visible_count
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part2(input)
    @scenic_scores&.map(&:max)&.max
  end
end

if __FILE__ == $0
  Solution.run
end
