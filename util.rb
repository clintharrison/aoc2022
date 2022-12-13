# typed: strict
require "sorbet-runtime"
require "pry"
require "pry-byebug"
require "set"
require "json"

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

  sig { params(sample: T::Boolean).void }
  def run(sample:)
    if sample
      if !File.exists?(filename(sample))
        puts("Expected the sample input #{filename(true)} to exist, exiting...")
        exit(1)
      end

      puts(
        <<~END
          ### Sample input ###
          Part 1:
        END
      )
      puts(part1(sample_input))
      puts(
        <<~END
          ----------
          Part 2:
        END
      )
      puts(part2(sample_input))
    else
      if !File.exists?(filename(sample))
        puts("Expected the real input #{filename(true)} to exist, exiting...")
        exit(1)
      end

      puts(
        <<~END
          ### Real input ###
          Part 1:
        END
      )
      puts(part1(input))
      puts(
        <<~END
          ----------
          Part 2:
        END
      )
      puts(part2(input))
    end
  end

  sig { void }
  def self.run
    self.new.run(sample: true)

    if ARGV[0] == "skip"
      puts("skipping real run...")
      return
    end

    self.new.run(sample: false)
  end
end
