# encoding: utf-8

module Bunch
  class Combiner
    attr_reader :tree

    def initialize(tree)
      @tree = tree
    end

    def result
      new_tree = FileTree.new

      @tree.map do |filename, node|
        case node
        when File
          new_tree.write(node.filename, node.content)
        when FileTree
          compiled_tree = compile_tree(filename, node)

          case compiled_tree
          when File
            new_tree.write(compiled_tree.filename, compiled_tree.content)
          when FileTree
            new_tree.write(filename, compiled_tree.to_hash)
          end
        end
      end

      new_tree
    end

    private

    def compile_tree(filename, tree)
      if should_combine?(tree)
        generate_file(filename, tree)
      else
        generate_tree(tree)
      end
    end

    def generate_tree(tree)
      Combiner.new(tree).result
    end

    def generate_file(filename, tree)
      contents  = []
      mime_type = nil

      tree.each do |filename, node|
        next if filename == "_combine"

        if node.is_a?(FileTree)
          node = Combiner.new(node, true).result
        end

        mime_type ||= node.mime_type
        raise "Conflicting types" unless mime_type == node.mime_type

        contents << node.content
      end

      name = "#{filename}.#{mime_type.extensions.first}"

      File.new(name, contents.join("\n"))
    end

    def should_combine?(tree)
      tree.exist?("_combine")
    end
  end
end
