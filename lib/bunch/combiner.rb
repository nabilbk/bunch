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
      if tree.exist?("_combine")
        @combining = true
        @content = []
        @extension = nil
      end
    end

    def leave_tree(tree)
      if tree.name
        @path.pop
      end
      if tree.exist?("_combine")
        output_path = tree.path
        output_path += ".#{@extension}" if @extension
        @output.write output_path, @content.join("\n")
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
        output_path = (@path + [file.path]).join("/")
        @output.write output_path, file.content
      end
    end
  end
end
