# encoding: UTF-8

module Bunch
  module Compilers
    class Jade
      def initialize(file, _, path)
        require "ruby-jade"
        @file, @path = file, path
      rescue LoadError => e
        raise "'gem install ruby-jade' to compile .jade files."
      end

      def path
        "#{template_name}.js"
      end

      def content
        @content ||= <<-JAVASCRIPT
          (function() {
            this.JST || (this.JST = {});
            this.JST['#{template_name}'] = #{::Jade.compile(@file.content)};
          })();
        JAVASCRIPT
      end

      private

      def template_name
        @file.path.chomp(".jade").chomp(".jst")
      end
    end
  end
  Compiler.register ".jst.jade", Compilers::CoffeeScript
  Compiler.register ".jade", Compilers::CoffeeScript
end
