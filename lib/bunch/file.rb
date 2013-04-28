# encoding: utf-8

module Bunch
  class File
    attr_reader :path, :content, :filename, :extension

    def initialize(path, content)
      @path      = path
      @content   = content
      @filename  = ::File.basename(@path)
      @extension = ::File.extname(@filename)
    end

    def accept(visitor)
      visitor.visit_file(self)
    end
  end
end
