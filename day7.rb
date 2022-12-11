# typed: strict
require_relative "./util.rb"

class Solution < BaseSolution
  class File
    sig { params(name: String, size: Integer).void }
    def initialize(name, size)
      @name = name
      @size = size
    end

    sig { returns(String) }
    attr_reader :name

    sig { returns(Integer) }
    attr_reader :size

    sig { params(indent: Integer).void }
    def print(indent = 0)
      puts((" " * indent) + "- #{@name} (file, size=#{@size})")
    end
  end

  class Directory
    sig { params(name: String, parent: T.nilable(Directory)).void }
    def initialize(name, parent)
      @name = name
      @parent = parent
      @content = T.let([], T::Array[T.any(Directory, File)])
    end

    sig { returns(String) }
    attr_reader :name

    sig { returns(T.nilable(Directory)) }
    attr_reader :parent

    sig { returns(T::Array[T.any(Directory, File)]) }
    attr_accessor :content

    sig { returns(Integer) }
    def size
      if @content.empty?
        return 0
      end

      @content.map(&:size).sum
    end

    sig { params(indent: Integer).void }
    def print(indent = 0)
      puts((" " * indent) + "- #{@name} (dir)")
      @content.each { _1.print(indent + 2) }
    end

    sig { returns(String) }
    def full_path
      return @name if @parent.nil?
      # are we in the root dir? otherwise we'll double the / lol
      if @parent.parent.nil?
        "/" + @name
      else
        @parent.full_path + "/" + @name
      end
    end
  end

  sig { params(input: T::Array[String]).returns(Directory) }
  def construct_root(input)
    root = Directory.new("/", nil)
    input = input.drop(1)

    cd = root
    input.each_with_index do |line, line_idx|
      next unless line[0] == "$"

      cmd = T.must(line[2..]&.split(" "))
      args = input[line_idx + 1..]&.take_while { !_1.start_with?("$") }&.compact

      if cmd[0] == "cd"
        if cmd[1] == ".."
          parent = cd.parent
          raise "Cannot cd above /" if parent.nil?
          cd = parent
        else
          dest = cd.content.find { _1.is_a?(Directory) && _1.name == cmd[1] }
          if dest.is_a?(Directory)
            cd = dest
          else
            raise "Cannot cd to a file"
          end
        end
      elsif cmd[0] == "ls"
        content = T.let([], T::Array[T.any(Directory, File)])
        T.must(args).each do |arg|
          dir_or_size, name = arg.split(" ")
          if dir_or_size == "dir"
            new_dir = Directory.new(T.must(name), cd)
            content << new_dir
          else
            new_file = File.new(T.must(name), dir_or_size.to_i)
            content << new_file
          end
        end

        cd.content = content
      end
    end

    root
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part1(input)
    root = construct_root(input)
    root.print

    max_size = 100000
    subdirs = flatten_dirs(root).map
    small_dirs = flatten_dirs(root).filter { |dir| dir.size < max_size }
    dir_sizes = small_dirs.map(&:size)
    puts("Found small_dirs #{small_dirs.map(&:full_path)} with sizes #{dir_sizes}")
    puts
    dir_sizes.sum
  end

  sig { params(directory: Directory).returns(T::Array[Directory]) }
  def flatten_dirs(directory)
    subdirs = T.cast(directory.content.filter { _1.is_a?(Directory) }, T::Array[Directory])

    [directory].concat(subdirs.flat_map { flatten_dirs(_1) })
  end

  sig { override.params(input: T::Array[String]).returns(T.untyped) }
  def part2(input)
    root = construct_root(input)
    root.print

    total_fs_size = 70000000
    total_needed_free_space = 30000000
    root_size = root.size
    min_amount_needed = total_needed_free_space - total_fs_size + root_size

    subdirs = flatten_dirs(root).map
    smallest_effective_dir = subdirs.sort_by(&:size).find { _1.size >= min_amount_needed }

    smallest_effective_dir&.size
  end
end

if __FILE__ == $0
  Solution.run
end
