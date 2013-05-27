# encoding: UTF-8

module Bunch
  module Compilers
    class Jst
      def initialize(file, _, path)
        @file, @path = file, path
      end

      def path
        "#{template_name}.js"
      end

      def content
        @content ||= <<-JAVASCRIPT
          (function() {
            this.JST || (this.JST = {});
            this.JST['#{template_name}'] = #{compile(@file.content)};
          })();
        JAVASCRIPT
      end

      private

      def compile(content)
        # override in subclasses
      end

      def extension
        # override in subclasses
      end

      def template_name
        @file.path.chomp(extension).chomp(".jst")
      end
    end
  end
end
