# encoding: utf-8

require "spec_helper"

module Bunch
  describe Filter do
    let(:input_tree) do
      FileTree.from_hash("a" => "aa", "b" => { "c" => "cc", "d" => "dd" })
    end

    it "filters everything" do
      result = Filter.new(input_tree, ["asdkj"]).result
      result.to_hash.must_equal({})
    end

    it "filters a top-level file" do
      result = Filter.new(input_tree, ["a"]).result
      result.to_hash.must_equal("a" => "aa")
    end

    it "filters a directory" do
      result = Filter.new(input_tree, ["b"]).result
      result.to_hash.must_equal("b" => { "c" => "cc", "d" => "dd" })
    end

    it "filters a path" do
      result = Filter.new(input_tree, ["b/c"]).result
      result.to_hash.must_equal("b" => { "c" => "cc" })
    end

    it "filters two things" do
      result = Filter.new(input_tree, ["a", "b/c"]).result
      result.to_hash.must_equal("a" => "aa", "b" => { "c" => "cc" })
    end
  end
end
