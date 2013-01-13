# encoding: utf-8

module Bunch
  class Catalog
    def initialize
      @types = []
    end

    def register(klass)
      @types << klass
    end

    def node_for_path(path)
      @types.each do |type|
        return type.new(path) if type.matches?(path)
      end
      nil
    end
  end
end
