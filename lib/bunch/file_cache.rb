# encoding: UTF-8

require "digest/md5"
require "fileutils"
require "yaml"

module Bunch
  class FileCache
    Result = Struct.new(:result)

    def initialize(processor_class, input_dir, *args)
      @processor_class, @args = processor_class, args
      @cache_name = "#{processor_class}-#{input_dir}"
    end

    def new(tree)
      cache     = load_cache
      partition = Partition.new(tree, cache)

      partition.process!

      processor = @processor_class.new(partition.pending, *@args)
      result    = TreeMerge.new(partition.cached, processor.result).result

      save_cache tree, result
      Result.new(result)
    end

    private

    def load_cache
      FileUtils.mkdir_p cache_directory
      Cache.read_from_file cache_path
    end

    def save_cache(input, output)
      FileUtils.mkdir_p cache_directory
      Cache.from_trees(input, output).write_to_file cache_path
    end

    # TODO: Make configurable
    def cache_directory
      ".bunch-cache"
    end

    def cache_filename
      @cache_name.gsub(/[:\/]/, "-")
    end

    def cache_path
      ::File.join(cache_directory, cache_filename)
    end

    class Partition
      attr_reader :pending, :cached

      def initialize(input, cache)
        @input = input
        @cache = cache
      end

      def process!
        @path    = []
        @pending = FileTree.new
        @cached  = FileTree.new
        @input.accept(self)
        self
      end

      def enter_tree(tree)
        @path << tree.name if tree.name
      end

      def leave_tree(tree)
        @path.pop if tree.name
      end

      def visit_file(file)
        file_path = [*@path, file.path].join("/")
        cached_content = @cache.read(file_path, file.content)
        if cached_content
          @cached.write file_path, cached_content
        else
          @pending.write file_path, file.content
        end
      end
    end

    class Cache
      def self.from_trees(input, output)
        new(HashHasher.new(input).result, output)
      end

      def self.read_from_file(path)
        version, hashes, output = YAML.load_file(path)
        if version == VERSION
          new(hashes, FileTree.from_hash(output))
        else
          empty
        end
      rescue Errno::ENOENT
        empty
      end

      def self.empty
        new({}, FileTree.new)
      end

      def self.digest(contents)
        Digest::MD5.hexdigest(contents)
      end

      def initialize(hashes, output)
        @hashes, @output = hashes, output
      end

      def read(path, input_contents)
        if Cache.digest(input_contents) == @hashes[path]
          @output.get(path).content
        end
      end

      def write_to_file(path)
        yaml = YAML.dump([Bunch::VERSION, @hashes, @output.to_hash])
        ::File.open(path, "w") { |f| f.write yaml }
      end

      class HashHasher
        def initialize(tree)
          @input  = tree
        end

        def result
          @path = []
          @hashes = {}
          @input.accept(self)
          @hashes
        end

        def enter_tree(tree)
          @path << tree.name if tree.name
        end

        def leave_tree(tree)
          @path.pop if tree.name
        end

        def visit_file(file)
          file_path = [*@path, file.path].join("/")
          @hashes[file_path] = Digest::MD5.hexdigest(file.content)
        end
      end
    end
  end
end
