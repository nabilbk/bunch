# encoding: utf-8

module Bunch
  class Combiner
    attr_reader :tree

    def initialize(tree)
      @tree = tree
    end

    def combined_file(filename)
      file = @tree.get_file(filename)

      if file
        [file.content, file.mime_type]
      end
    end

    def combined_tree
      @tree
    end
  end
end
