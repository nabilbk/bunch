# encoding: UTF-8

module Bunch
  class TreeMerge
    def initialize(left, right)
      @left, @right = left, right
    end

    def result
      @path = []
      @output = @right.dup
      @left.accept(self)
      @output
    end

    def enter_tree(tree)
      @path << tree.name if tree.name
    end

    def leave_tree(tree)
      @path.pop if tree.name
    end

    def visit_file(file)
      file_path = [*@path, file.path].join("/")
      @output.write file_path, file.content
    end
  end
end
