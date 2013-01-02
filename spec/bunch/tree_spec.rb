# encoding: utf-8

require "spec_helper"

module Bunch
  describe Tree do
    before do
      @tree = Tree.from_hash \
        "a" => {"b" => "foo", "c" => {"d" => "bar"}}, "e" => "baz"
    end
  end
end
