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

    it "runs the given environment's pipeline on the given path" do
      Dir.mktmpdir do |tmpdir|
        out = StringIO.new
        CLI.new(["-e development", "spec/example_tree", tmpdir], out).run!
        out.string.must_equal ""

        FileTree.from_path(tmpdir).to_hash.must_equal(
          "directory" => "2\n\n1\n",
          "file3" => "3\n"
        )
      end
    end
  end
end
