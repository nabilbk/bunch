# encoding: utf-8

module Bunch
  class FileTree
    def self.from_hash(hash)
      new(hash)
    end

    def initialize(hash = {})
      @hash = hash
    end

    def get_file(filename)
      if (content = look_up_path(filename))
        OpenStruct.new \
          content:   content,
          mime_type: MIME::Types.type_for(filename).first.to_s
      end
    end

    def directory?(path)
      look_up_path(path).is_a?(Hash)
    end

    def to_hash
      @hash
    end

    private

    def look_up_path(filename)
      filename.split("/").inject(@hash) do |hash, path_component|
        if hash.nil? || hash.is_a?(String)
          return hash
        else
          hash[path_component]
        end
      end
    end
  end
end
