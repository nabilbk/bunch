# encoding: utf-8

module Bunch
  class Catalog
    def initialize
      @types = []
    end

    def register(klass)
      @types << klass
    end

    def node_for_path(tree, path)
      @types.each do |type|
        return type.new(tree, path) if type.matches?(tree, path)
      end
      nil
    end
  end
end
