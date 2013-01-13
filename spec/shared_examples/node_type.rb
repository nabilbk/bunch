# encoding: utf-8

module Bunch
  shared_examples_for :node_type do
    it "supports .new" do
      tree = FileTree.from_hash("a" => "b")
      subject.new(tree, "a/b").wont_be_nil
    end

    it "supports .matches?" do
      tree = FileTree.from_hash("a" => "b")
      [true, false].must_include subject.matches?(tree, "a/b")
    end
  end
end
