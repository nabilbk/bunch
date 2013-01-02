# encoding: utf-8

require "spec_helper"

module Bunch
  describe Combiner do
    describe "given a tree with one JavaScript file" do
      before do
        @filename = "a.js"
        @content  = "hello;"
        @combiner = Combiner.new Tree.from_hash(@filename => @content)
      end

      describe "#combined_file" do
        it "returns nil if the file doesn't exist" do
          @combiner.combined_file("b.js").must_equal nil
        end

        it "returns an individual JavaScript file unaltered" do
          contents, mime_type = @combiner.combined_file("a.js")

          contents.must_equal  "hello;"
          mime_type.must_equal "application/javascript"
        end
      end

      describe "#combined_tree" do
        it "returns the tree unaltered" do
          @combiner.combined_tree.must_equal @combiner.tree
        end
      end
    end
  end
end
