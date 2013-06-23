# encoding: UTF-8

module Bunch
  class JsMinifier
    def initialize(tree)
      require "uglifier"
      @input  = tree
      @output = FileTree.new
      @uglifier = Uglifier.new
    rescue LoadError => e
      raise "'gem install uglifier' to minify JavaScript files."
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
      content = if file.extension == ".js"
                  @uglifier.compile(file.content)
                else
                  file.content
                end
      @output.write file_path, content
    end
  end
end
