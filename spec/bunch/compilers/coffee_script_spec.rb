# encoding: utf-8

require "spec_helper"

module Bunch
  module Compilers
    describe CoffeeScript do
      it "compiles a CoffeeScript file to JS" do
        file = File.new("a/my_file.coffee", "@a = 10")
        compiler = CoffeeScript.new(file)
        compiler.path.must_equal "a/my_file.js"
        compiler.content.must_equal \
          "(function() {\n\n  this.a = 10;\n\n}).call(this);\n"
      end

      it "raises if the gem isn't available" do
        CoffeeScript.any_instance.stubs(:require).raises(LoadError)
        exception = assert_raises(RuntimeError) { CoffeeScript.new(nil) }
        exception.message.must_include "gem install"
      end
    end
  end
end
