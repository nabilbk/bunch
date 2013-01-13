# encoding: utf-8

module Bunch
  module Nodes
    class Directory
      def self.matches?(path)
        path.directory?
      end

      def initialize(path)
      end
    end
  end

  catalog.register(Nodes::Directory)
end
