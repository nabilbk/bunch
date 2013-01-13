# encoding: utf-8

require "spec_helper"

module Bunch
  describe Path do
    describe "#directory?" do
      let(:tree) { FileTree.from_hash("a" => {"b" => "c"}, "d" => "e") }

      it "returns true if the path is a directory" do
        Path.new(tree, "a").directory?.must_equal true
      end

      it "returns false if it's a non-directory" do
        Path.new(tree, "d").directory?.must_equal false
      end

      it "returns false if it doesn't exist" do
        Path.new(tree, "f").directory?.must_equal false
      end
    end
  end
end
