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
        syntax = @file.path.end_with?("scss") ? :scss : :sass
        engine = ::Sass::Engine.new(
          @file.content,
          syntax: syntax,
          filename: @abs_path,
          importer: Importer.new(@tree)
        )
        engine.render
      end

      class Importer
        def initialize(tree)
          @tree = tree
        end

        def find_relative(path, base, options)
          abs = ::File.expand_path("../#{path}", "/#{base}")[1..-1]
          find(abs, options)
        end

        def find(path, options)
          syntax = path.end_with?("scss") ? :scss : :sass
          ::Sass::Engine.new(
            @tree.get(path).content,
            syntax: syntax,
            filename: path,
            importer: self
          )
        end

        def mtime(path, options)
        end

        def key(path, options)
          ["Bunch:#{::File.dirname(path)}", ::File.basename(path)]
        end

        def to_s
          "(Bunch file tree)"
        end
      end
    end
  end
  Compiler.register ".sass", Compilers::Sass
  Compiler.register ".scss", Compilers::Sass
end
