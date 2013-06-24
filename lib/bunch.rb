# encoding: utf-8

require "bunch/version"
require "bunch/cli"
require "bunch/combiner"
require "bunch/compiler"
require "bunch/content_hash"
require "bunch/css_minifier"
require "bunch/file"
require "bunch/file_tree"
require "bunch/filter"
require "bunch/ignorer"
require "bunch/js_minifier"
require "bunch/middleware"
require "bunch/server"
require "bunch/simple_cache"
require "bunch/pipeline"

Dir.glob(File.expand_path("../bunch/compilers/*.rb", __FILE__)) do |compiler|
  require compiler
end
