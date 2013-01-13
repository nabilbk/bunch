# encoding: utf-8

require "spec_helper"

module Bunch
  describe Nodes::Directory do
    subject { Nodes::Directory }
    it_behaves_like :node

    describe ".matches?" do
      let(:tree) { FileTree.from_hash("a" => {"b" => "c"}, "d" => "e") }

      it "matches a directory" do
        subject.matches?(tree, "a").must_equal true
      end

      it "does not match a non-directory" do
        subject.matches?(tree, "d").must_equal false
      end

      it "does not match a non-existent file" do
        subject.matches?(tree, "f").must_equal false
      end
    end
  end
end
