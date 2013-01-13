# encoding: utf-8

module Bunch
  module Nodes
    class Directory
      def self.matches?(file_tree, path)
        file_tree.directory?(path)
      end

      def initialize(file_tree, path)
      end
    end
  end

  catalog.register(Nodes::Directory)
end
