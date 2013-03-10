# encoding: utf-8

module Bunch
  class Combiner
    attr_reader :tree

    def initialize(tree)
      @tree = tree
    end

    def result
      @tree
    end
  end
end
