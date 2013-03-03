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
        file.path.must_equal "a/c/d.js"
        file.content.must_equal "bar"
        file.mime_type.must_equal "application/javascript"
      end
    end
  end
end
