# encoding: utf-8

module Bunch
  module Nodes
    class Directory
      def self.matches?(file_tree, path)
        file_tree.directory?(path)
      end
    end
  end

  catalog.register(Nodes::Directory)
end
