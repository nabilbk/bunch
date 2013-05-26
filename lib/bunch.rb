# encoding: utf-8

require "bunch/version"
require "bunch/combiner"
require "bunch/compiler"
require "bunch/file"
require "bunch/file_tree"
require "bunch/filter"
require "bunch/js_minifier"

Dir.glob(File.expand_path("../bunch/compilers/*.rb", __FILE__)) do |compiler|
  require compiler
end
