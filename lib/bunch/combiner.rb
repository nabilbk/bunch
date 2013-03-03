# encoding: utf-8

module Bunch
  class Combiner
    attr_reader :tree

    def initialize(tree, force_combine = false)
      @tree, @force_combine = tree, force_combine
    end

    def result
      @tree
    end

    private

    def should_combine?
      @tree.has_file?("_combine")
    end
  end
end
