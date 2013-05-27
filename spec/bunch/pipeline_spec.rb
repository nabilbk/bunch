# encoding: utf-8

require "spec_helper"

module Bunch
  describe Pipeline do
    it "applies an empty pipeline to a tree" do
      pipeline = Pipeline.new([])
      hash     = { "a" => { "b" => "c", "d" => "e" }, "f" => "g" }
      in_tree  = FileTree.from_hash(hash)
      out_tree = pipeline.process(in_tree)
      out_tree.to_hash.must_equal hash
    end

    it "compiles, combines, and minifies CoffeeScript files" do
      pipeline = Pipeline.new [Compiler, Combiner, JsMinifier]
      in_tree  = FileTree.from_hash(
        "a" => {
          "_combine" => "c\nb\n",
          "b.coffee" => "local = 'world'\n@B = hello: local",
          "c.coffee" => "@C = goodnight: 'moon'"
        }
      )
      # obviously this is really brittle, but it's just for acceptance anyway
      pipeline.process(in_tree).to_hash.must_equal(
        "a.js" => "!function(){this.C={goodnight:\"moon\"}}.call(this)," \
                  "function(){var o;o=\"world\",this.B={hello:o}}.call(this);"
      )
    end
  end
end
