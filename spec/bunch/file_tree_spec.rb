# encoding: utf-8

require "spec_helper"

module Bunch
  describe FileTree do
    before do
      @tree = FileTree.from_hash \
        "a" => {"b" => "foo", "c" => {"d" => "bar"}}, "e" => "baz"
    end

    describe "#get_file" do
      it "returns an object representing a filename" do
        @tree.get_file("e").content.must_equal "baz"
      end

      it "returns an object representing a nested path" do
        @tree.get_file("a/b").content.must_equal "foo"
      end

      it "returns an object representing a more nested path" do
        @tree.get_file("a/c/d").content.must_equal "bar"
      end
    end
  end
end
