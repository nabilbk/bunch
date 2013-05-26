# encoding: utf-8

require "spec_helper"

module Bunch
  describe CssMinifier do
    let(:file_contents) do
      <<-CSS
body :hover {
    border-left: 10px solid rgb(0, 0, 0);
}
      CSS
    end

    let(:minified_contents) do
      "body :hover{border-left:10px solid #000}"
    end

    let(:input_tree) do
      FileTree.from_hash(
        "a" => file_contents, "b" => { "c.css" => file_contents }
      )
    end

    it "minifies .css files, ignoring other files" do
      result = CssMinifier.new(input_tree).result.to_hash
      result["a"].must_equal file_contents
      result["b"]["c.css"].must_equal minified_contents
    end
  end
end
