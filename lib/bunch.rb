# encoding: utf-8

require "bunch/version"
require "bunch/cli"
require "bunch/combiner"
require "bunch/compiler"
require "bunch/file"
require "bunch/file_tree"
require "bunch/filter"
require "bunch/css_minifier"
require "bunch/js_minifier"
require "bunch/pipeline"

Dir.glob(File.expand_path("../bunch/compilers/*.rb", __FILE__)) do |compiler|
  require compiler
end
