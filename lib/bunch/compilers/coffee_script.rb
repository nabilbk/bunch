# encoding: UTF-8

module Bunch
  module Compilers
    class CoffeeScript
      def initialize(file, *)
        require "coffee-script"
        @file = file
      rescue LoadError => e
        raise "'gem install coffee-script' to compile .coffee files."
      end

      def path
        @file.path.chomp(".coffee") + ".js"
      end

      def content
        ::CoffeeScript.compile(@file.content, bare: true)
      end
    end
  end
  Compiler.register ".coffee", Compilers::CoffeeScript
end
