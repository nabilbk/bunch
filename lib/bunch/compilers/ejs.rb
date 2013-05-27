# encoding: UTF-8

require "bunch/compilers/jst"

module Bunch
  module Compilers
    class Ejs < Jst
      def initialize(*)
        super
        require "ejs"
      rescue LoadError => e
        raise "'gem install ejs' to compile .ejs files."
      end

      private

      def compile(content)
        ::EJS.compile content
      end

      def extension
        ".ejs"
      end
    end
  end
  Compiler.register ".jst.ejs", Compilers::Ejs
  Compiler.register ".ejs", Compilers::Ejs
end
