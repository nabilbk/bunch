# encoding: UTF-8

module Bunch
  module Compilers
    class Sass
      def initialize(file, tree, path)
        require "sass"
        @file, @tree, @abs_path = file, tree, path
      rescue LoadError => e
        raise "'gem install sass' to compile .sass and .scss files."
      end

      def path
        @file.path.sub(/\.s[ca]ss$/, "") + ".css"
      end

      def content
        new_engine(@file.content, @abs_path).render
      end

      def new_engine(content, path)
        syntax = path.end_with?("scss") ? :scss : :sass
        ::Sass::Engine.new(
          content, syntax: syntax, filename: path, importer: self)
      end

      ## Sass importer interface ##

      def find_relative(path, base, options)
        abs = ::File.expand_path("../#{path}", "/#{base}")[1..-1]
        find(abs, options)
      end

      def find(path, options)
        path = path.chomp(".scss").chomp(".sass")
        path_with_underscore = path.sub(/(.*)\//, '\1/_')
        file = @tree.get_fuzzy(path) || @tree.get_fuzzy(path_with_underscore)
        if file
          new_engine(file.content, file.path)
        else
          raise "Couldn't find '#{path}' to import! (#{options[:original_filename]}:#{options[:_line]})"
        end
      end

      def mtime(path, options)
      end

      def key(path, options)
        ["Bunch:#{::File.dirname(path)}", ::File.basename(path)]
      end
    end
  end
  Compiler.register ".sass", Compilers::Sass
  Compiler.register ".scss", Compilers::Sass
end
