# encoding: utf-8

module Bunch
  class FileTree
    include Enumerable

    attr_reader :path, :name

    def self.from_hash(hash)
      new(nil, hash)
    end

    def initialize(path = nil, hash = {})
      @path = path
      @hash = hash
      @name = ::File.basename(@path) if @path
    end

    def directory?(path)
      look_up_path(path).is_a?(Hash)
    end

    def exist?(filename)
      !!look_up_path(filename)
    end

    def get(path)
      case (content = look_up_path(path))
      when Hash
        FileTree.new(path, content)
      when String
        File.new(path, content)
      end
    end

    def write(path, contents)
      dirname, _, filename = path.rpartition("/")

      if dirname == ""
        @hash[filename] = contents
      else
        unless exist?(dirname)
          write(dirname, {})
        end

        unless directory?(dirname)
          raise "#{dirname.inspect} is a file, not a directory!"
        end

        get(dirname).write(filename, contents)
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

    def accept(visitor)
      unless visitor.enter_tree(self) == false
        each { |_, node| break if node.accept(visitor) == false }
      end
      visitor.leave_tree(self)
    end

    private

    def look_up_path(filename)
      filename.split("/").inject(@hash) do |hash, path_component|
        break if hash.nil? || hash.is_a?(String)
        hash[path_component]
      end
    end
  end
end
