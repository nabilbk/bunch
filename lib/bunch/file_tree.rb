# encoding: utf-8

require "fileutils"

module Bunch
  class FileTree
    include Enumerable

    attr_reader :path, :name

    class << self
      def from_hash(hash)
        new nil, hash
      end

      def from_path(path)
        new nil, hash_from_path(path)
      end

      private

      def hash_from_path(path)
        hash = {}
        Dir.foreach(path) do |entry|
          next if entry == "." || entry == ".."
          this_path = "#{path}/#{entry}"
          if ::File.directory? this_path
            hash[entry] = hash_from_path this_path
          else
            hash[entry] = ::File.read this_path
          end
        end
        hash
      end
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

    def write_to_path(path)
      write_hash_to_path path, @hash
    end

    private

    def look_up_path(filename)
      filename.split("/").inject(@hash) do |hash, path_component|
        break if hash.nil? || hash.is_a?(String)
        hash[path_component]
      end
    end

    def write_hash_to_path(path, hash)
      FileUtils.mkdir_p path

      hash.each do |name, content|
        this_path = ::File.join path, name

        if content.is_a? Hash
          write_hash_to_path this_path, content
        else
          ::File.open(this_path, "w") { |f| f.write content }
        end
      end
    end
  end
end
