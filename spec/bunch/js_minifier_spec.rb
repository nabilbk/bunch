# encoding: utf-8

require "spec_helper"

module Bunch
  describe JsMinifier do
    let(:file_contents) do
      "(function () {     return 10;  })();"
    end

    let(:minified_contents) do
      "!function(){return 10}();"
    end

    let(:input_tree) do
      FileTree.from_hash(
        "a" => file_contents, "b" => { "c.js" => file_contents }
      )
    end

    it "minifies .js files, ignoring other files" do
      result = JsMinifier.new(input_tree).result.to_hash
      result["a"].must_equal file_contents
      result["b"]["c.js"].must_equal minified_contents
    end
  end
end
