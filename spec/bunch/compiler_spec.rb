# encoding: utf-8

require "spec_helper"

module Bunch
  describe Compiler do
    it "passes plain files through unchanged" do
      hash = {
        "a" => { "b" => "c", "d" => "e" },
        "f" => "g"
      }
      result = Compiler.new(FileTree.from_hash(hash)).result.to_hash
      result.must_equal hash
    end
  end
end
