# encoding: utf-8

require "spec_helper"

module Bunch
  describe FileTree do
    before do
      @tree = FileTree.from_hash \
        "a" => {"b" => "foo", "c" => {"d.js" => "bar"}}, "e" => "baz"
    end

    describe "#get" do
      it "returns an object representing a file" do
        file = @tree.get("e")
        file.path.must_equal "e"
        file.content.must_equal "baz"
        file.mime_type.must_equal "text/plain"
      end

      it "returns an object representing a nested path" do
        file = @tree.get("a/b")
        file.path.must_equal "a/b"
        file.content.must_equal "foo"
        file.mime_type.must_equal "text/plain"
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
