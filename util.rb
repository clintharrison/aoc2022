# typed: strict
require "sorbet-runtime"

extend(T::Sig)

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
