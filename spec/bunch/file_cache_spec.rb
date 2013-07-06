# encoding: utf-8

require "spec_helper"
require "fileutils"
require "tempfile"

module Bunch
  describe FileCache do
    let(:input_1) { FileTree.from_hash("a" => "1", "b" => "2") }
    let(:input_2) { FileTree.from_hash("a" => "1", "b" => "3") }
    let(:result_1) { FileTree.from_hash("a" => "!", "b" => "@") }
    let(:result_2) { FileTree.from_hash("a" => "!", "b" => "#") }
    let(:result_3) { FileTree.from_hash("a" => "%", "b" => "#") }
    let(:processor_1) { stub new: stub(result: result_1), to_s: "processor" }
    let(:processor_2) { stub new: stub(result: result_2), to_s: "processor" }
    let(:processor_3) { stub new: stub(result: result_3), to_s: "processor" }
    let(:processor_4) { stub new: stub(result: result_3), to_s: "grocessor" }

    def new_cache(processor, path = "a_path")
      FileCache.new(processor, path)
    end

    before do
      FileUtils.rm_rf ".bunch-cache"
    end

    it "delegates to the underlying processor on a cold cache" do
      new_cache(processor_1).new(input_1).result.must_equal result_1
    end

    it "returns the same results for the same input" do
      new_cache(processor_1).new(input_1).result.must_equal result_1
      new_cache(processor_2).new(input_1).result.must_equal result_1
    end

    it "returns different results for a different input" do
      new_cache(processor_1).new(input_1).result.must_equal result_1
      new_cache(processor_2).new(input_2).result.must_equal result_2
    end

    it "only updates paths that have changed" do
      new_cache(processor_1).new(input_1).result.must_equal result_1
      new_cache(processor_3).new(input_2).result.must_equal result_2
    end

    it "maintains distinct caches for different processors" do
      new_cache(processor_1).new(input_1).result.must_equal result_1
      new_cache(processor_4).new(input_1).result.must_equal result_3
    end

    it "maintains distinct caches for different input paths" do
      new_cache(processor_1).new(input_1).result.must_equal result_1
      new_cache(processor_2).new(input_1).result.must_equal result_1
      new_cache(processor_2, "abc").new(input_1).result.must_equal result_2
    end

    it "considers the cache expired if Bunch's version changes" do
      new_cache(processor_1).new(input_1).result.must_equal result_1
      begin
        FileCache::VERSION = "alsdkjalskdj"
        new_cache(processor_2).new(input_1).result.must_equal result_2
      ensure
        FileCache.send :remove_const, :VERSION
      end
    end
  end

  class FileCache
    describe Partition do
      let(:empty)  { FileTree.from_hash({}) }
      let(:tree_1) { FileTree.from_hash("a" => {"b" => "1", "c" => "2"}) }

      it "returns input tree for pending if cache is empty" do
        cache = stub
        cache.stubs(:read).returns(nil)
        partition = Partition.new(tree_1, cache)
        partition.process!
        partition.cached.must_equal empty
        partition.pending.must_equal tree_1
      end

      it "divides input tree into pending and cached" do
        cache = stub
        cache.stubs(:read).with("a/b", "1").returns("cache")
        cache.stubs(:read).with("a/c", "2").returns(nil)
        partition = Partition.new(tree_1, cache)
        partition.process!
        partition.cached.must_equal FileTree.from_hash("a" => {"b" => "cache"})
        partition.pending.must_equal FileTree.from_hash("a" => {"c" => "2"})
      end
    end

    describe Cache do
      def create_cache
        Cache.from_trees(
          FileTree.from_hash("a" => "1", "b" => { "c" => "2" }),
          FileTree.from_hash("a" => "!", "b" => { "c" => "@" }))
      end

      def assert_cache_is_correct(cache)
        cache.read("a",     "1").must_equal "!"
        cache.read("a",     "2").must_equal nil
        cache.read("b/c",   "2").must_equal "@"
        cache.read("b/c/d", "2").must_equal nil
        cache.read("b/d",   "2").must_equal nil
      end

      it "records a mapping between two trees" do
        cache = create_cache
        assert_cache_is_correct cache
      end

      it "saves to and loads from a file" do
        original_cache = create_cache
        loaded_cache = nil

        Tempfile.open(["cache", ".yml"]) do |tempfile|
          tempfile.close
          original_cache.write_to_file(tempfile.path)
          loaded_cache = Cache.read_from_file(tempfile.path)
        end
        assert_cache_is_correct loaded_cache
      end

      it "returns a null cache if the file can't be opened" do
        Cache.read_from_file("asldkasd").must_be_instance_of Cache
      end

      describe "#read" do
        before do
          @cache = Cache.new(
            { "a" => Digest::MD5.hexdigest("1") },
            FileTree.from_hash("a" => "!@#")
          )
        end

        it "returns the result if the hash matches" do
          @cache.read("a", "1").must_equal "!@#"
        end

        it "returns nil if the hash doesn't match" do
          @cache.read("a", "2").must_equal nil
        end

        it "returns nil if the file isn't present" do
          @cache.read("b", "1").must_equal nil
        end
      end
    end
  end
end
