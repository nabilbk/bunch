# encoding: UTF-8

require "spec_helper"

module Bunch
  describe TreeMerge do
    let(:empty)  { FileTree.from_hash({}) }
    let(:tree_1) { FileTree.from_hash("a" => {"b" => "1", "c" => "2"}) }
    let(:tree_2) { FileTree.from_hash("a" => {"d" => "3"}, "e" => "4") }
    let(:tree_3) { FileTree.from_hash("a" => {"b" => "9"}) }

    it "no-ops if one tree is empty" do
      TreeMerge.new(empty, tree_1).result.must_equal tree_1
      TreeMerge.new(tree_1, empty).result.must_equal tree_1
    end

    it "merges two trees with partially-overlapping structures" do
      output = FileTree.from_hash(
        "a" => {"b" => "1", "c" => "2", "d" => "3"}, "e" => "4"
      )
      TreeMerge.new(tree_1, tree_2).result.must_equal output
    end

    it "prioritizes the left tree over the right one" do
      output = FileTree.from_hash("a" => {"b" => "9", "c" => "2"})
      TreeMerge.new(tree_1, tree_3).result.must_equal tree_1
      TreeMerge.new(tree_3, tree_1).result.must_equal output
    end
  end
end
