# encoding: UTF-8

require "digest/md5"

module Bunch
  class ContentHash
    def initialize(file_or_tree)
      @input = file_or_tree
    end

    def result
      @path = []
      @hash = 0
      @input.accept(self)
      @hash
    end

    def enter_tree(tree)
      @path << tree.name if tree.name
    end

    def leave_tree(tree)
      @path.pop if tree.name
    end

    def visit_file(file)
      file_path = [*@path, file.path].join("/")
      @hash ^= truncated_md5("#{file_path}:#{file.content}")
    end

    private

    def truncated_md5(string)
      Digest::MD5.digest(string)[0..4].unpack("L")[0]
    end
  end
end
