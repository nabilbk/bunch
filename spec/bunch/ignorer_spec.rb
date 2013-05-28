# encoding: utf-8

require "spec_helper"

module Bunch
  describe Ignorer do
    let(:input_tree) do
      FileTree.from_hash(
        "a" => {"b" => "bb", "c" => "cc", ".DS_Store" => "asfd" }
      )
    end

    it "ignores .DS_Store files" do
      result = Ignorer.new(input_tree).result
      result.to_hash.must_equal("a" => { "b" => "bb", "c" => "cc" })
    end

    it "ignores other patterns" do
      pattern = /b/
      Ignorer::PATTERNS << pattern
      result = Ignorer.new(input_tree).result
      result.to_hash.must_equal("a" => { "c" => "cc" })
      Ignorer::PATTERNS.delete pattern
    end
  end
end
