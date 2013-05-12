# encoding: utf-8

require "spec_helper"

module Bunch
  module Compilers
    describe CoffeeScript do
      it "compiles a CoffeeScript file to JS" do
        file = File.new("a/my_file.coffee", "@a = 10")
        compiler = CoffeeScript.new(file)
        compiler.path.must_equal "a/my_file.js"
        compiler.content.must_equal "\nthis.a = 10;\n"
      end
    end
  end
end
