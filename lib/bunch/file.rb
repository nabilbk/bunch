# encoding: utf-8

module Bunch
  File = Struct.new(:content, :mime_type) do
    def to_ary
      [content, mime_type]
    end
  end
end
