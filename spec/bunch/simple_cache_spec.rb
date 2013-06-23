# encoding: utf-8

require "spec_helper"

module Bunch
  describe SimpleCache do
    let(:input_tree) do
      FileTree.from_hash("a" => "aa", "b" => { "c" => "cc", "d" => "dd" })
    end

    let(:input_tree_2) do
      FileTree.from_hash("a" => "aa", "b" => { "c" => "ce", "d" => "dd" })
    end

    let(:input_tree_3) do
      FileTree.from_hash("a" => "aa", "b" => { "d" => "dd", "c" => "cc" })
    end

    it "delegates to the underlying processor" do
      processor = stub(result: FileTree.from_hash("fff" => "ggg"))
      cache = SimpleCache.new(stub(new: processor))
      cache.new(input_tree).result.to_hash.must_equal "fff" => "ggg"
    end

    it "caches the results" do
      processor = stub
      processor.stubs(:result).
        returns(FileTree.from_hash("fff" => "ggg")).then.
        returns(FileTree.from_hash("hhh" => "jjj"))
      cache  = SimpleCache.new(stub(new: processor))
      cache.new(input_tree).result.to_hash.must_equal "fff" => "ggg"
      cache.new(input_tree).result.to_hash.must_equal "fff" => "ggg"
    end

    it "expires the results if the input tree changes" do
      processor = stub
      processor.stubs(:result).
        returns(FileTree.from_hash("fff" => "ggg")).then.
        returns(FileTree.from_hash("hhh" => "jjj"))
      cache  = SimpleCache.new(stub(new: processor))
      cache.new(input_tree).result.to_hash.must_equal "fff" => "ggg"
      cache.new(input_tree_2).result.to_hash.must_equal "hhh" => "jjj"
    end

    it "isn't order-dependent" do
      processor = stub
      processor.stubs(:result).
        returns(FileTree.from_hash("fff" => "ggg")).then.
        returns(FileTree.from_hash("hhh" => "jjj"))
      cache  = SimpleCache.new(stub(new: processor))
      cache.new(input_tree).result.to_hash.must_equal "fff" => "ggg"
      cache.new(input_tree_3).result.to_hash.must_equal "fff" => "ggg"
    end
  end
end
