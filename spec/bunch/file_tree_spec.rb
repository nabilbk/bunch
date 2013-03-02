# encoding: utf-8

require "spec_helper"

module Bunch
  describe FileTree do
    before do
      @tree = FileTree.from_hash \
        "a" => {"b" => "foo", "c" => {"d.js" => "bar"}}, "e" => "baz"
    end

    describe "#get" do
      it "returns an object representing a filename" do
        @tree.get("e").content.must_equal "baz"
      end

      it "returns an object representing a nested path" do
        @tree.get("a/b").content.must_equal "foo"
      end

      it "returns an object representing a more nested path" do
        file = @tree.get("a/c/d.js")
        file.content.must_equal "bar"
        file.mime_type.must_equal "application/javascript"
      end
    end

    describe "#to_ary" do
      it "allows destructuring to contents + mime_type" do
        content, mime_type = @tree.get("a/c/d.js")
        content.must_equal "bar"
        mime_type.must_equal "application/javascript"
      end
    end
  end
end
