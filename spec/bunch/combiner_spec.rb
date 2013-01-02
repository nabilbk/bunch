# encoding: utf-8

require "spec_helper"

module Bunch
  describe Combiner do
    class << self
      def it_returns_nil_for(path)
        it "returns nil if the file doesn't exist" do
          @combiner.combined_file(path).must_equal nil
        end
      end

      def it_returns_the_tree_unaltered
        it "returns the tree unaltered" do
          @combiner.combined_tree.must_equal @combiner.tree
        end
      end
    end

    describe "given a tree with one JavaScript file" do
      before do
        @combiner = Combiner.new Tree.from_hash("a.js" => "hello;")
      end

      describe "#combined_file" do
        it_returns_nil_for "b.js"

        it "returns an individual JavaScript file unaltered" do
          contents, mime_type = @combiner.combined_file("a.js")

          contents.must_equal  "hello;"
          mime_type.must_equal "application/javascript"
        end
      end

      describe "#combined_tree" do
        it_returns_the_tree_unaltered
      end
    end

    describe "given a tree with two JavaScript files in a directory" do
      before do
        @tree     = {"a" => {"b.js" => "hello;", "c.js" => "goodbye;"}}
        @combiner = Combiner.new Tree.from_hash(@tree)
      end

      describe "#combined_file" do
        it_returns_nil_for "a.js"

        it "returns an individual JavaScript file unaltered" do
          contents, mime_type = @combiner.combined_file("a/c.js")

          contents.must_equal  "goodbye;"
          mime_type.must_equal "application/javascript"
        end
      end

      describe "#combined_tree" do
        it_returns_the_tree_unaltered
      end
    end
  end
end
