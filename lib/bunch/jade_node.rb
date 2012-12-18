module Bunch
  class JadeNode < FileNode
    def initialize(fn)
      JadeNode.require_jade
      @filename = fn
    end

    def content
      @content ||= fetch(@filename) {
        <<-JAVASCRIPT
          (function() {
            this.JST || (this.JST = {});
            this.JST['#{template_name}'] = #{Jade.compile(File.read(@filename))};
          })();
        JAVASCRIPT
      }
    rescue => e
      raise CompileError.new(e, @filename)
    end

    def name
      File.basename(@filename, '.jade')
    end

    def template_name
      name = @filename.sub(/\.jst\.jade/, '')

      if @options[:root]
        name.sub(/^#{Regexp.escape(@options[:root].to_s)}\//, '')
      else
        name
      end
    end

    def target_extension
      '.js'
    end
  end

  class << JadeNode
    def require_jade
      unless @required
        require 'ruby-jade'
        @required = true
      end
    rescue LoadError
      raise "'gem install ruby-jade' to compile .jade files."
    end
  end
end
