# encoding: utf-8

module Bunch
  class File
    attr_accessor :path, :content, :filename, :mime_type

    def initialize(path, content)
      @path      = path
      @content   = content
      @filename  = ::File.basename(@path)
      @mime_type = MIME::Types.type_for(path).first
    end
  end
end
