# encoding: UTF-8

module Bunch
  module Compilers
    class Sass
      def initialize(file)
        require "sass"
        @file = file
      rescue LoadError => e
        raise "'gem install sass' to compile .sass and .scss files."
      end

      def path
        @file.path.sub(/\.s[ca]ss$/, "") + ".css"
      end

      def content
        syntax = @file.path.end_with?("scss") ? :scss : :sass
        ::Sass::Engine.new(@file.content, syntax: syntax).render
      end
    end
  end
  Compiler.register ".sass", Compilers::Sass
  Compiler.register ".scss", Compilers::Sass
end
