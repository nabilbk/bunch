# encoding: utf-8

require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"

require "mocha/setup"
require "pry"

require "bunch"

module Mocha
  module ParameterMatchers
    def responds_to(*messages)
      RespondsTo.new(messages.flatten)
    end

    class RespondsTo < Base
      def initialize(messages)
        @messages = messages
      end

      def matches?(available_parameters)
        parameter = available_parameters.shift
        @messages.all? { |msg| parameter.respond_to?(msg) }
      end

      def mocha_inspect
        "responds_to(#{@messages.map(&:mocha_inspect).join(", ")})"
      end
    end
  end
end

# Shared examples, inspired by https://gist.github.com/1560208

class MiniTest::Spec
  def self.shared_examples
    @shared_examples ||= {}
  end

  def self.it_behaves_like(desc)
    examples = MiniTest::Spec.shared_examples[desc]
    raise "no :#{desc} role defined!" unless examples
    instance_eval(&examples)
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

# Mocks with enforced interfaces

module Mocha
  class MockRole
    include Mocha::ParameterMatchers

    def initialize(name, &block)
      @name  = name
      @stubs = {}
      instance_eval &block
    end

    def stubs(name, options = {})
      @stubs[name] = options
    end

    def stubs?(name)
      @stubs.has_key? name
    end

    def define_stubs_on(object)
      @stubs.each do |name, options|
        object.stubs(name).with(*options[:params]).returns(options[:returns])
      end
    end

    def check_parameters(name, *args)
      return unless stubs?(name)

      matcher = ParametersMatcher.new(@stubs[name][:params])

      unless matcher.parameters_match?(args.dup)
        raise ExpectationError,
          "Expected (#{args.map(&:mocha_inspect).join(", ")}) " \
          "to match #{matcher.mocha_inspect}"
      end
    end
  end

  class RoleMock
    def initialize(role, mock)
      @role, @mock = role, mock
      @role.define_stubs_on(mock)
    end

    def method_missing(name, *args, &block)
      @role.check_parameters(name, *args)
      @mock.send(name, *args, &block)
    end

    def respond_to_missing?(name, include_private)
      @mock.respond_to?(name, include_private)
    end
  end
end

module Kernel
  def define_mock(name, &block)
    mock_role = Mocha::MockRole.new(name, &block)

    Kernel.module_eval do
      define_method "mock_#{name}" do |*args|
        Mocha::RoleMock.new(mock_role, mock(*args))
      end
      private "mock_#{name}"
    end
  end
  private :define_mock
end

Dir[File.expand_path("../mocks/*.rb", __FILE__)].each do |file|
  require file
end
