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
      @input.accept(self)
      @output
    end

    def enter_tree(tree)
      if tree.name
        @path << tree.name
      end
      if tree.name && tree.exist?("_combine")
        @combining = true
        @content = []
        @extension = nil
      end
    end

    def leave_tree(tree)
      if tree.name
        @path.pop
      end
      if tree.name && tree.exist?("_combine")
        write_file tree.path, @content.join("\n"), @extension
        @combining = false
        @content = nil
      end
    end

    def visit_file(file)
      return if file.path == "_combine"

      if @combining
        @content << file.content
        @extension ||= file.extension
        raise "Incompatible MIME types!" if @extension != file.extension
      else
        write_file file.path, file.content
      end
    end

    private

    def write_file(immediate_path, content, extension = nil)
      path = (@path + [immediate_path]).join("/")
      path += ".#{extension}" if extension
      @output.write path, content
    end
  end
end
