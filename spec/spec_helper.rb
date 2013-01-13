# encoding: utf-8

require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"

require "mocha/setup"
require "pry"

require "bunch"

# Shared examples inspired by https://gist.github.com/1560208

class MiniTest::Spec
  def self.shared_examples
    @shared_examples ||= {}
  end

  def self.it_behaves_like(desc)
    instance_eval(&MiniTest::Spec.shared_examples[desc])
  end
end

module Kernel
  def shared_examples_for(desc, &block)
    MiniTest::Spec.shared_examples[desc] = block
  end
  private :shared_examples_for
end

Dir[File.expand_path("../shared_examples/*.rb", __FILE__)].each do |file|
  require file
end
