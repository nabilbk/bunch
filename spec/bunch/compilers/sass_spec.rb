# encoding: utf-8

require "spec_helper"

module Bunch
  module Compilers
    describe Sass do
      it "compiles a .scss file to CSS" do
        file = File.new("a/my_file.scss", "div { span { width: 20px; } }")
        compiler = Sass.new(file)
        compiler.path.must_equal "a/my_file.css"
        compiler.content.must_equal "div span {\n  width: 20px; }\n"
      end

      it "compiles a .sass file to CSS" do
        file = File.new("a/my_file.sass", "div\n  span\n    width: 20px\n")
        compiler = Sass.new(file)
        compiler.path.must_equal "a/my_file.css"
        compiler.content.must_equal "div span {\n  width: 20px; }\n"
      end

      it "raises if the gem isn't available" do
        Sass.any_instance.stubs(:require).raises(LoadError)
        exception = assert_raises(RuntimeError) do
          Sass.new(nil)
        end
        exception.message.must_include "gem install"
      end
    end
  end
end
