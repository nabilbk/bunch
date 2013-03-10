# encoding: utf-8

module Bunch
  class File
    attr_accessor :path, :content, :filename, :mime_type

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
  end
end
