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

      it "returns nil if the path extends past a file" do
        @tree.get("a/c/d.js/nonexistent").must_equal nil
      end
    end

    describe "#write" do
      it "creates a file at the top level" do
        @tree.write "f", "hello"
        @tree.get("f").content.must_equal "hello"
      end

      it "creates a file in an existing directory" do
        @tree.write "a/c/f", "hello"
        @tree.get("a/c/f").content.must_equal "hello"
      end

      it "creates nested directories" do
        @tree.write "a/c/a/f", "hello"
        @tree.get("a/c/a/f").content.must_equal "hello"
      end

      it "raises if there's an existing file that conflicts with the path" do
        proc {
          @tree.write "a/c/d.js/f", "hello"
        }.must_raise RuntimeError

        @tree.get("a/c/d.js").content.must_equal "bar"
        @tree.get("a/c/d.js/f").must_equal nil
      end
    end
  end
end
