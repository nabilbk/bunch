# encoding: utf-8

module Bunch
  class File
    attr_reader :path, :content, :filename, :mime_type

    def initialize(path, content)
      @path      = path
      @content   = content
      @filename  = ::File.basename(@path)
    end

    def mime_type
      @mime_type ||=
        MIME::Types.type_for(path).first ||
        MIME::Types["text/plain"].first
    end

    def extension
      @extension ||= mime_type.extensions[0]
    end

    def accept(visitor)
      visitor.visit_file(self)
    end
  end
end
