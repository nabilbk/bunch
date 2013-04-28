# encoding: UTF-8

module Bunch
  class Filter
    def initialize(tree, prefix)
      @input  = tree
      @output = FileTree.new
      @prefix = prefix
    end

    def result
      @path = []
      @input.accept(self)
      @output
    end

    def enter_tree(tree)
      if tree.name
        @path << tree.name
        current_path.start_with?(@prefix) || @prefix.start_with?(current_path)
      end
    end

    def leave_tree(tree)
      if tree.name
        @path.pop
      end
    end

    def visit_file(file)
      file_path = (@path.any?) ? "#{current_path}/#{file.path}" : file.path

      if file_path.start_with?(@prefix)
        @output.write file_path, file.content
      end
    end

    private

    def current_path
      @path.join("/")
    end
  end
end
