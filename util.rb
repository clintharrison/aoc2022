# typed: strict
require "sorbet-runtime"
require "pry"
require "set"

class ::Object
  extend T::Sig
end

class BaseSolution
  extend T::Helpers
  abstract!

  sig { abstract.params(input: T::Array[String]).returns(T.untyped) }
  def part1(input)
  end

  sig { abstract.params(input: T::Array[String]).returns(T.untyped) }
  def part2(input)
  end

  sig { params(sample: T::Boolean).returns(String) }
  def filename(sample = false)
    filename = "#{day}#{"s" if sample}.txt"
  end

  sig { params(sample: T::Boolean).returns(T::Array[String]) }
  def input(sample = false)
    File.readlines(filename(sample), chomp: true)
  end

  sig { returns(T::Array[String]) }
  def sample_input
    input(true)
  end

  sig { returns(String) }
  def day
    File.basename($0, ".rb")
  end

  sig { void }
  def run
    if !File.exists?(filename(sample = true))
      puts("Expected the sample input #{filename(true)} to exist, exiting...")
      exit(1)
    end

    puts(
      <<~END
          Running for #{day}!
        ### Sample input ###
        Part 1:
        #{part1(sample_input)}
        ----------
        Part 2:
        #{part2(sample_input)}
      END
    )

    if ARGV[0] == "skip"
      puts("skipping real run...")
      return
    end

    if File.exists?(filename)
      puts(
        <<~END

          ### Real input ###
          Part 1:
          #{part1(input)}
          ----------
          Part 2:
          #{part2(input)}
        END
      )
    end
  end

  sig { void }
  def self.run
    self.new.run
  end
end
