# encoding: UTF-8

module Bunch
  class Pipeline
    ENVIRONMENTS = {
      "development" => [Ignorer, Compiler, Combiner],
      "production"  => [Ignorer, Compiler, Combiner, JsMinifier, CssMinifier]
    }

    def self.for_environment(environment)
      classes = ENVIRONMENTS[environment] ||
                  raise("No pipeline defined for #{environment}!")
      new(classes)
    end

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
