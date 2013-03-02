# encoding: utf-8

module Bunch
  class Combiner
    attr_reader :tree

    def initialize(tree, force_combine = false)
      @tree, @force_combine = tree, force_combine
    end

    def result
      if should_combine?
        to_file
      else
        to_combined_tree
      end
    end

    private

    def should_combine?
      @tree.has_file?("_combine")
    end

    def to_file
      contents = []

      @tree.each do |name, object|
        next if name == "_combine"

        if object.is_a?(Bunch::File)
          contents << object.content
        else
          contents << Combiner.new(object, true).result.content
        end
      end

      Bunch::File.new(contents.compact.join("\n"), "text/plain")
    end

    def to_combined_tree
      FileTree.from_arrays(@tree.map do |name, object|
        if object.is_a?(Bunch::File)
          [name, object.content]
        else
          result = Combiner.new(object).result
          if result.is_a?(Bunch::File)
            [name, result.content]
          else
            [name, result.to_hash]
          end
        end
      end)
    end
  end
end
