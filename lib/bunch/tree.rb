# encoding: utf-8

module Bunch
  class Tree
    def self.from_hash(hash)
      new(hash)
    end

    def initialize(hash)
      @hash = hash
    end

    def get_file(filename)
      if @hash.has_key?(filename)
        OpenStruct.new \
          content:   @hash[filename],
          mime_type: MIME::Types.type_for(filename).first.to_s
      end
    end
  end
end
