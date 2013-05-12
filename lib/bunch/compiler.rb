# encoding: UTF-8

module Bunch
  class Compiler
    def self.compiler_for(file)
      klass = compilers.fetch file.extension, Compilers::Null
      klass.new(file)
    end

    def self.register(extension, klass)
      if (existing = compilers[extension])
        raise "Already registered #{existing} for #{extension.inspect}!"
      end
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
