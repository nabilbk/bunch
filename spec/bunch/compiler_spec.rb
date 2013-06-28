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
          def initialize(*)
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

      it "passes the file, tree, and path into the compiler" do
        input = { "a" => { "b.foobar" => "c" } }

        Compiler.compilers[".foobar"].expects(:new).with do |file, tree, path|
          file.path.must_equal "b.foobar"
          file.content.must_equal "c"
          file.filename.must_equal "b.foobar"
          file.extension.must_equal ".foobar"
          tree.to_hash.must_equal input
          path.must_equal "a/b.foobar"
        end.returns(stub(path: "b.js", content: "!!!"))

        Compiler.new(FileTree.from_hash(input)).result
      end

      it "can register a replacement compiler" do
        o = Object.new
        Compiler.register ".foobar", o
        Compiler.compilers[".foobar"].must_equal o
      end
    end
  end
end
