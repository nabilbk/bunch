# encoding: utf-8

module Bunch
  class Combiner
    def initialize(tree)
      @input  = tree
      @output = FileTree.new
    end

    def result
      @path = []
      @contexts = []
      @input.accept(self)
      @output
    end

    def enter_tree(tree)
      if tree.name
        @path << tree.name

        combine_file = tree.get("_combine") || tree.get("_.yml")

        if combine_file || combining?
          ordering = combine_file ? extract_ordering(combine_file.content) : ""
          push_context Context.new(@path, ordering)
        end
      end
    end

    def leave_tree(tree)
      if tree.name
        @path.pop
      end

      if combining?
        this_context = pop_context

        if this_context.empty?
          # do nothing
        elsif combining?
          context.add tree.path, this_context.content, this_context.extension
        else
          write_file tree.path, this_context.content, this_context.extension
        end
      end
    end

    def visit_file(file)
      return if file.path == "_combine" || file.path == "_.yml"

      if combining?
        context.add file.path, file.content, file.extension
      else
        write_file file.path, file.content
      end
    end

    private

    def write_file(relative_path, content, extension = "")
      path = absolute_path(relative_path) + extension
      @output.write path, content
    end

    def absolute_path(relative_path)
      [*@path, relative_path].join("/")
    end

    def push_context(hash)
      @contexts.push hash
    end

    def pop_context
      @contexts.pop
    end

    def context
      @contexts.last
    end

    def combining?
      @contexts.any?
    end

    def extract_ordering(file_content)
      as_yaml = YAML.load(file_content)

      if as_yaml.is_a?(Array)
        as_yaml
      else
        file_content.split("\n").map(&:strip)
      end
    end

    class Context
      attr_accessor :ordering, :extension

      def initialize(path, ordering)
        @path = path.join("/")
        @content = {}
        @ordering = ordering
        @extension = nil
        @empty = true
      end

      def add(path, content, extension)
        @content[path.chomp(extension)] = content
        @extension ||= extension
        @empty = false

        if @extension != extension
          message = "Incompatible types ('#{extension}' vs '#{@path}/#{path}')"
          message << "\n  #{@content.keys.join(', ')}"
          raise message
        end
      end

      def content
        ordered, unordered = \
          @content.partition { |fn, _| @ordering.include?(fn) }
        ordered.sort_by!   { |fn, _| @ordering.index(fn) }
        unordered.sort_by! { |fn, _| fn }
        (ordered + unordered).map(&:last).join("\n")
      end

      def empty?
        @empty
      end
    end
  end
end
