# encoding: utf-8

require "spec_helper"

module Bunch
  module Compilers
    describe Ejs do
      it "compiles an EJS file to JS" do
        tree = FileTree.from_hash(
          "a" => { "my_file.jst.ejs" => "<% hello %>" }
        )
        compiler = Ejs.new(
          tree.get("a/my_file.jst.ejs"), tree, "a/my_file.jst.ejs")
        output = compiler.content

        compiler.path.must_equal "a/my_file.js"
        output.must_include "JST['a/my_file'] = function"
      end

      it "raises if the gem isn't available" do
        Ejs.any_instance.stubs(:require).raises(LoadError)
        exception = assert_raises(RuntimeError) { Ejs.new(nil, nil, nil) }
        exception.message.must_include "gem install"
      end
    end
  end
end
