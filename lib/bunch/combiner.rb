# encoding: utf-8

module Bunch
  class Combiner
    attr_reader :tree

    def initialize(tree, force_combine = false)
      @tree, @force_combine = tree, force_combine
    end

    def result
      new_tree = FileTree.new

      @tree.map do |filename, node|
        case node
        when File
          new_tree.write(node.filename, node.content)
        when FileTree
          new_tree.write(filename, compile_tree(filename, node))
        end
      end

      new_tree
    end

    private

    def compile_tree(filename, tree)
      if should_combine?(tree)
        generate_file(filename, tree).content
      else
        generate_tree(tree).to_hash
      end
    end

    def generate_tree(tree)
      Combiner.new(tree).result
    end

    def generate_file(filename, tree)
      contents = []

      tree.each do |filename, node|
        next if filename == "_combine"

        case node
        when File
          contents << node.content
        when FileTree
          contents << Combiner.new(node, true).result.content
        end
      end

      File.new(filename, contents.join("\n"))
    end

    def should_combine?(tree)
      tree.exist?("_combine")
    end
  end
end
