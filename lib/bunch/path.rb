# encoding: utf-8

# A Path encapsulates both a tree and a location within that tree.

module Bunch
  class Path
    # @example Path.new(FileTree.from_hash("a" => "b"), "a")
    def initialize(tree, path)
      @tree = tree
      @path = path
    end

    def directory?
      @tree.directory?(@path)
    end
  end
end
