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

    describe "when a file type has a registered compiler" do
      before do
        compiler = Class.new do
          def initialize(file)
          end

          def path
            "b.js"
          end

          def content
            "!!!"
          end
        end

        Compiler.register ".foobar", compiler
      end

      after do
        Compiler.compilers.delete ".foobar"
      end

      it "uses the compiler to transform a file of that type" do
        input = {
          "a" => { "b.foobar" => "c", "d.js" => "e" },
          "f" => "g"
        }
        output = {
          "a" => { "b.js" => "!!!", "d.js" => "e" },
          "f" => "g"
        }
        result = Compiler.new(FileTree.from_hash(input)).result.to_hash
        result.must_equal output
      end
    end
  end
end
