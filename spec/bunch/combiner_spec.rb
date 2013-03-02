# encoding: utf-8

require "spec_helper"

module Bunch
  describe Combiner do
    def self.it_returns_the_tree_unaltered
      it "returns the tree unaltered" do
        @combiner.result.must_equal @combiner.tree
      end
    end

    describe "given a tree with one JavaScript file" do
      before do
        @combiner = Combiner.new FileTree.from_hash("a.js" => "hello;")
      end

      it_returns_the_tree_unaltered
    end

    describe "given a tree with two JavaScript files in a directory" do
      before do
        @tree     = {"a" => {"b.js" => "hello;", "c.js" => "goodbye;"}}
        @combiner = Combiner.new FileTree.from_hash(@tree)
      end

      it_returns_the_tree_unaltered
    end

    describe "given a tree with two JavaScript files and a _combine file" do
      before do
        @tree = {
          "a" => {
            "_combine" => "", "b.js" => "hello;", "c.js" => "goodbye;"
          }
        }
        @combiner = Combiner.new FileTree.from_hash(@tree)
      end

      it "returns a tree with the files concatenated" do
        result = @combiner.result
        hash = result.to_hash

        hash.values.must_equal ["hello;\ngoodbye;"]

        result.get(hash.keys[0]).content.must_equal "hello;\ngoodbye;"
      end

      it "gives the result the correct name, extension, and mime type" #do
      #  result = @combiner.result
      #  result.to_hash.keys.must_equal ["a.js"]
      #  file = result.get("a.js")
      #  file.mime_type.must_equal "application/javascript"
      #end
    end
  end
end
