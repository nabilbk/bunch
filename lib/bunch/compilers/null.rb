# encoding: UTF-8

module Bunch
  module Compilers
    class Null
      def initialize(file, *)
        @file = file
      end

      def path
        @file.path
      end

      def content
        @file.content
      end
    end
  end
end
