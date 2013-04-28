# encoding: utf-8

require "spec_helper"

module Bunch
  describe Combiner do
    def self.scenario(name, input, output)
      it "combines a tree correctly: #{name}" do
        combiner = Combiner.new FileTree.from_hash(input)
        result   = combiner.result.to_hash

        result.must_equal output
      end
    end

    scenario "one JavaScript file",
      {"a.js" => "hello;"},
      {"a.js" => "hello;"}

    scenario "two JavaScript files in a directory",
      {"a" => {"b.js" => "hello;", "c.js" => "goodbye;"}},
      {"a" => {"b.js" => "hello;", "c.js" => "goodbye;"}}

    scenario "two JavaScript files and a _combine file",
      {"a" => {"_combine" => "", "b.js" => "hello;", "c.js" => "goodbye;"}},
      {"a.js" => "hello;\ngoodbye;"}

    scenario "ignoring a _combine file at the top level",
      {"_combine" => "", "a" => {"b.js" => "bar;", "c.js" => "baz;"}},
      {"a" => {"b.js" => "bar;", "c.js" => "baz;"}}

    # scenario "a more complex tree of JavaScript files",
    #   {"a" => {
    #      "b" => {
    #        "_combine" => "", "c.js" => "hello;", "d.js" => "goodbye;"
    #      },
    #      "e.js" => "and_another_thing;"
    #   }},
    #   {"a" => {
    #      "b.js" => "hello;\ngoodbye;",
    #      "e.js" => "and_another_thing;"
    #   }}

    # scenario "_combine forces subtrees to collapse",
    #   {"a" => {
    #      "b" => {
    #        "_combine" => "",
    #        "c" => {
    #          "d.js" => "whoops;",
    #          "e.js" => "it_worked;"
    #        }
    #      }
    #   }},
    #   {"a" => {"b.js" => "whoops;\nit_worked;"}}
  end
end
