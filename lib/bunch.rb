require 'fileutils'
require 'optparse'
require 'pathname'
require 'yaml'

require 'mime/types'

begin
  require 'v8'
rescue LoadError
  $stderr.puts "WARNING: 'gem install therubyracer' for much faster CoffeeScript compilation."
end

require 'bunch/version'
require 'bunch/rack'
require 'bunch/middleware'
require 'bunch/cache'

require 'bunch/abstract_node'
require 'bunch/directory_node'
require 'bunch/file_node'
require 'bunch/coffee_node'
require 'bunch/sass_node'
require 'bunch/null_node'
require 'bunch/ejs_node'
require 'bunch/jade_node'

module Bunch
  class CompileError < StandardError
    def initialize(exception, filename)
      @exception = exception
      @filename = filename
    end

    def message
      "#{@filename}: #{@exception.message}"
    end
  end
end

class << Bunch
  IGNORED_PATTERNS = []

  def load_ignores(path='.')
    fn = File.join(path, '.bunchignore')
    if File.exist?(fn)
      IGNORED_PATTERNS.concat File.readlines(fn).map { |f| Regexp.new(f.chomp) }
      IGNORED_PATTERNS.uniq!
    end
  end

  def content_for(path, options = {})
    tree_for(normalized_path(path), options).content
  end

  def tree_for(path, options)
    node = case
      when IGNORED_PATTERNS.any? { |p| File.basename(path) =~ p }
        Bunch::NullNode.new(path)
      when File.directory?(path)
        Bunch::DirectoryNode.new(path)
      when path =~ /\.coffee$/
        Bunch::CoffeeNode.new(path)
      when path =~ /\.s(a|c)ss$/
        Bunch::SassNode.new(path)
      when path =~ /\.ejs$/
        Bunch::EJSNode.new(path)
      when path =~ /\.jade/
        Bunch::JadeNode.new(path)
      else
        Bunch::FileNode.new(path)
      end
    node.options = options
    node
  end

  protected
    def normalized_path(path)
      case
      when File.exist?(path)
        path
      when File.exist?(chopped_path = path.sub(%r(\.[^.]*$), ''))
        chopped_path
      when File.basename(path).start_with?('all.') && File.exist?(dir_path = File.dirname(path))
        dir_path
      when (path_w_different_extension = Dir["#{chopped_path}.*"].first)
        path_w_different_extension
      else
        raise Errno::ENOENT, path.to_s
      end
    end
end

Bunch.load_ignores
