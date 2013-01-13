# encoding: utf-8

require "mime/types"
require "bunch/version"

module Bunch
  def self.catalog
    @catalog ||= Catalog.new
  end
end

require "bunch/combiner"
require "bunch/file_tree"
require "bunch/catalog"
require "bunch/nodes"
