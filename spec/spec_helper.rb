# encoding: utf-8

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start
end

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
