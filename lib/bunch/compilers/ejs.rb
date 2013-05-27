# encoding: UTF-8

module Bunch
  module Compilers
    class Ejs
      def initialize(file, _, path)
        require "ejs"
        @file, @path = file, path
      rescue LoadError => e
        raise "'gem install ejs' to compile .ejs files."
      end

      def path
        "#{template_name}.js"
      end

      def content
        @content ||= <<-JAVASCRIPT
          (function() {
            this.JST || (this.JST = {});
            this.JST['#{template_name}'] = #{::EJS.compile(@file.content)};
          })();
        JAVASCRIPT
      end

      private

      def template_name
        @file.path.chomp(".ejs").chomp(".jst")
      end
    end
  end
  Compiler.register ".jst.ejs", Compilers::CoffeeScript
  Compiler.register ".ejs", Compilers::CoffeeScript
end
