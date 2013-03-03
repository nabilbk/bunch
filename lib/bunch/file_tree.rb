# encoding: utf-8

module Bunch
  class FileTree
    include Enumerable # iterate through top level

    def self.from_hash(hash)
      new(hash)
    end

    def initialize(hash = {})
      @hash = hash
    end

    def directory?(path)
      look_up_path(path).is_a?(Hash)
    end

    def has_file?(filename)
      !!look_up_path(filename)
    end

    def get(path)
      case (content = look_up_path(path))
      when Hash
        FileTree.from_hash(content)
      when String
        File.new(path, content)
      end
    end

    def each
      @hash.keys.each do |filename|
        yield [filename, get(filename)]
      end
    end

    def to_hash
      @hash
    end

    def ==(other)
      to_hash == other.to_hash
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
