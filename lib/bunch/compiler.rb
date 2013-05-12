# encoding: UTF-8

module Bunch
  class Compiler
    def self.compiler_for(file)
      Compilers::Null.new(file)
    end

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
      compiler = self.class.compiler_for file
      write_file compiler.path, compiler.content
    end

    private

    def write_file(immediate_path, content, extension = "")
      path = (@path + [immediate_path]).join("/") + extension
      @output.write path, content
    end
  end
end
