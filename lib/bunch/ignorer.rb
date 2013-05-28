# encoding: UTF-8

module Bunch
  class Ignorer
    PATTERNS = [
      /^\.DS_Store$/,
      /^.*~$/,
      /^#.*\#$/ #/(comment fixes broken vim highlighting)
    ]

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
      @path << tree.name if tree.name
    end

    def leave_tree(tree)
      @path.pop if tree.name
    end

    def visit_file(file)
      file_path = [*@path, file.path].join("/")

      unless PATTERNS.any? { |p| p.match(file.path) }
        @output.write file_path, file.content
      end
    end
  end
end
