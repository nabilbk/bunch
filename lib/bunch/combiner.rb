# encoding: utf-8

module Bunch
  class Combiner
    attr_reader :tree

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
      end

      if tree.name && tree.exist?("_combine")
        push_context Context.new(tree.get("_combine").content)
      end
    end

    def leave_tree(tree)
      if tree.name
        @path.pop
      end

      if tree.name && tree.exist?("_combine")
        this_context = pop_context

        if combining?
          context.add tree.path, this_context.content, this_context.extension
        else
          write_file tree.path, this_context.content, this_context.extension
        end
      end
    end

    def visit_file(file)
      return if file.path == "_combine"

      if combining?
        context.add file.path, file.content, file.extension
      else
        write_file file.path, file.content
      end
    end

    private

    def write_file(immediate_path, content, extension = "")
      path = (@path + [immediate_path]).join("/") + extension
      @output.write path, content
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

    class Context
      attr_accessor :ordering, :extension

      def initialize(ordering_file_contents)
        @content = {}
        @ordering = ordering_file_contents.split("\n").compact
        @extension = nil
      end

      def add(path, content, extension)
        @content[path] = content
        @extension ||= extension

        if @extension != extension
          raise "Incompatible MIME types! (FIXME: better error)"
        end
      end

      def content
        ordered, unordered = \
          @content.partition { |fn, _| @ordering.include?(fn) }
        ordered.sort_by!   { |fn, _| @ordering.index(fn) }
        unordered.sort_by! { |fn, _| fn }
        (ordered.map(&:last) + unordered.map(&:last)).join("\n")
      end
    end
  end
end
