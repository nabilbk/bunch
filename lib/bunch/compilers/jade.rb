# encoding: UTF-8

require "bunch/compilers/jst"

module Bunch
  module Compilers
    class Jade < Jst
      def initialize(*)
        require "ruby-jade"
        super
      rescue LoadError => e
        raise "'gem install ruby-jade' to compile .jade files."
      end

      private

      def compile(content)
        ::Jade.compile content
      end

      def extension
        ".jade"
      end
    end
  end
  Compiler.register ".jst.jade", Compilers::Jade
  Compiler.register ".jade", Compilers::Jade
end
