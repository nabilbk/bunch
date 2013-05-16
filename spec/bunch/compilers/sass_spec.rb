# encoding: utf-8

require "spec_helper"

module Bunch
  module Compilers
    describe Sass do
      it "compiles a .scss file to CSS" do
        tree = FileTree.from_hash(
          "a" => { "my_file.scss" => "div { span { width: 20px; } }" }
        )
        compiler = Sass.new(tree.get("a/my_file.scss"), tree, "a/my_file.scss")
        compiler.path.must_equal "a/my_file.css"
        compiler.content.must_equal "div span {\n  width: 20px; }\n"
      end

      it "compiles a .sass file to CSS" do
        tree = FileTree.from_hash(
          "a" => { "my_file.sass" => "div\n  span\n    width: 20px\n" }
        )
        compiler = Sass.new(tree.get("a/my_file.sass"), tree, "a/my_file.sass")
        compiler.path.must_equal "a/my_file.css"
        compiler.content.must_equal "div span {\n  width: 20px; }\n"
      end

      it "raises if the gem isn't available" do
        Sass.any_instance.stubs(:require).raises(LoadError)
        exception = assert_raises(RuntimeError) do
          Sass.new(nil, nil, nil)
        end
        exception.message.must_include "gem install"
      end

      describe "dealing with @imports" do
        it "imports a file from the same directory" do
          included_file = <<-SCSS
            @mixin foobar {
                width: 20px;
            }
          SCSS

          including_file = <<-SCSS
            @import "included.scss";

            div {
                @include foobar;
            }
          SCSS

          tree = FileTree.from_hash(
            "a" => {
              "including.scss" => including_file,
              "included.scss" => included_file
            }
          )

          compiler = Sass.new(
            tree.get("a/including.scss"), tree, "a/including.scss")
          compiler.path.must_equal "a/including.css"
          compiler.content.must_equal "div {\n  width: 20px; }\n"
        end
      end
    end
  end
end
