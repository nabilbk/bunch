# encoding: utf-8

require "spec_helper"

module Bunch
  describe Combiner do
    def self.scenario(name, input, output)
      it "combines a tree correctly: #{name}" do
        result_for_hash(input).must_equal output
      end
    end

    def result_for_hash(input)
      Combiner.new(FileTree.from_hash(input)).result.to_hash
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

    scenario "a more complex tree of JavaScript files",
      {"a" => {
         "b" => {
           "_combine" => "", "c.js" => "hello;", "d.js" => "goodbye;"
         },
         "e.js" => "and_another_thing;"
      }},
      {"a" => {
         "b.js" => "hello;\ngoodbye;",
         "e.js" => "and_another_thing;"
      }}

    scenario "_combine forces subtrees to collapse",
      {"a" => {
         "b" => {
           "_combine" => "",
           "c" => {
             "d.js" => "whoops;",
             "e.js" => "it_worked;"
           }
         }
      }},
      {"a" => {"b.js" => "whoops;\nit_worked;"}}

    scenario "obey ordering found in _combine",
      {"a" => {
         "d" => "pants",
         "a" => "spigot",
         "_combine" => "c\nd\n",
         "c" => "deuce",
         "b" => "rands"
      }},
      {"a" => "deuce\npants\nspigot\nrands"}

    scenario "deal with nested combines",
      {"a" => {
         "_combine" => "e\nb\n",
         "b" => {
           "_combine" => "d\nc\n",
           "c.js" => "stuff",
           "d.js" => "other_stuff"
         },
         "e.js" => "still_more_stuff"
      }},
      {"a.js" => "still_more_stuff\nother_stuff\nstuff"}

    scenario "deal with empty directory",
      {"a" => {
         "b" => {
           "_combine" => "",
         },
         "e.js" => "stuff"
      }},
      {"a" => {"e.js" => "stuff"}}

    it "raises when one combine has incompatible files" do
      proc do
        result_for_hash(
          "a" => { "_combine" => "", "a.js" => "", "b.css" => "" }
        )
      end.must_raise RuntimeError
    end
  end
end
