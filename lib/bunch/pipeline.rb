# encoding: UTF-8

module Bunch
  class Pipeline
    def initialize(processors)
      @processors = processors
    end

    def process(input_tree)
      tree = input_tree
      @processors.each do |processor|
        tree = processor.new(tree).result
      end
      tree
    end
  end
end
