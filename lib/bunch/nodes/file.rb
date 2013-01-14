# encoding: utf-8

module Bunch
  module Nodes
    class File
      def self.matches?(path)
        true
      end

      def initialize(path)
      end
    end
  end

  catalog.register_last Nodes::File
end
