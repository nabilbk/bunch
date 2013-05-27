# encoding: utf-8

require "spec_helper"

module Bunch
  describe CLI do
    describe ".run!" do
      it "instantiates CLI with the given args and calls run! on it" do
        args = %w(a b c)
        cli = stub
        cli.expects(:run!)
        CLI.expects(:new).with(args).returns(cli)
        CLI.run!(args)
      end
    end

    it "requires both input and output paths" do
      out = StringIO.new
      CLI.new(%w(in_path), out).run!
      out.string.must_include "Error:"
      out.string.must_include "Usage:"
    end

    it "prints usage" do
      out = StringIO.new
      CLI.new(%w(-h), out).run!
      out.string.wont_include "Error:"
      out.string.must_include "Usage:"
    end
  end
end
