module Bunch
  class DirectoryNode < AbstractNode
    attr_reader :root

    def initialize(fn)
      @root = Pathname.new(fn)
    end

    def filenames
      Dir[@root.join("*")].select { |f| f !~ /_\.yml$/ }
    end

    def children
      @children ||= begin
        children = filenames.map do |filename|
          Bunch.tree_for(filename, @options)
        end

        ordering_file = @root.join('_.yml')

        if File.exist?(ordering_file)
          ordering = YAML.load_file(ordering_file)
          ordered, unordered = children.partition { |c| ordering.include?(c.name) }
          if ordering.length > ordered.length
            ordering.select { |o| ! children.map(&:name).include?(o) }.each do |f|
              $stderr.puts "WARNING: directory #{ full_name } has no object #{ f }"
            end
          end
          ordered.sort_by { |c| ordering.index(c.name) } + unordered.sort_by(&:name)
        else
          children.sort_by(&:name)
        end
      end
    end

    def target_extension
      @target_extension ||= begin
        exts = children.map(&:target_extension).compact.uniq
        if exts.count == 1
          exts.first
        elsif exts.count > 1
          raise "Directory #{name} contains non-homogeneous nodes: #{exts.inspect}"
        else
          nil
        end
      end
    end

    def content
      @content ||= children.map(&:content).join
    end

    def name
      File.basename(@root)
    end

    def full_name
      @root
    end

    def write_to_file(dir)
      return if filenames.count == 0
      super
    end

    def write_to_dir(dir)
      super

      if @options[:recurse]
        directory_name = File.join(dir, name)
        FileUtils.mkdir(directory_name)
        children.each do |child|
          child.write_to_dir(directory_name)
        end
      end
    end

    def inspect
      "#<DirectoryNode @root=#{@root.inspect} @children=#{children.inspect}>"
    end
  end
end
