# encoding: UTF-8

module Bunch
  class Compiler
    def self.register(extension, klass)
      compilers[extension] = klass
    end

    def self.compilers
      @compilers ||= {}
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
      compiler = compiler_for file
      write_file compiler.path, compiler.content
    end

    private

    def compiler_for(file)
      klass = self.class.compilers.fetch file.extension, Compilers::Null
      klass.new file, @input, absolute_path(file.path)
    end

    def write_file(relative_path, content)
      @output.write absolute_path(relative_path), content
    end

    def absolute_path(relative_path)
      (@path + [relative_path]).join("/")
    end
  end
end
