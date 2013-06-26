# encoding: utf-8

require "spec_helper"

module Bunch
  module Compilers
    describe Jade do
      it "compiles a Jade file to JS" do
        tree = FileTree.from_hash(
          "a" => { "my_file.jst.jade" => "h1\n  = hello\n  hr\n" }
        )
        compiler = Jade.new(
          tree.get("a").get("my_file.jst.jade"), tree, "a/my_file.jst.jade")
        output = compiler.content

        compiler.path.must_equal "a/my_file.js"
        output.must_include "JST['a/my_file'] = function"
        output.must_include "<hr/>"
      end

      it "raises if the gem isn't available" do
        Jade.any_instance.stubs(:require).raises(LoadError)
        exception = assert_raises(RuntimeError) { Jade.new(nil, nil, nil) }
        exception.message.must_include "gem install"
      end
    end
  end
end
