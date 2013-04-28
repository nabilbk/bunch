# encoding: utf-8

require "spec_helper"

module Bunch
  describe FileTree do
    before do
      @tree = FileTree.from_hash \
        "a" => {"b.txt" => "foo", "c" => {"d.js" => "bar"}}, "e" => "baz"
    end

    describe "#get" do
      it "returns an object representing a file" do
        file = @tree.get("e")
        file.path.must_equal "e"
        file.content.must_equal "baz"
        file.extension.must_equal ""
      end

      it "returns an object representing a nested path" do
        file = @tree.get("a/b.txt")
        file.path.must_equal "a/b.txt"
        file.content.must_equal "foo"
        file.extension.must_equal ".txt"
      end

      it "returns an object representing a more nested path" do
        file = @tree.get("a/c/d.js")
        file.path.must_equal "a/c/d.js"
        file.content.must_equal "bar"
        file.extension.must_equal ".js"
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
