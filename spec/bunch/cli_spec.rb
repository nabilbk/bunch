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

    it "loads the default config file if possible" do
      ::File.stubs(:exist?).with("config/bunch.rb").returns(true)
      Bunch.expects(:load).with("config/bunch.rb")
      run_example
    end

    it "loads an alternate config file if provided" do
      ::File.expects(:exist?).with("config/bunch.rb").never
      Bunch.expects(:load).with("config/bunch.rb").never
      ::File.stubs(:exist?).with("config/foo.rb").returns(true)
      Bunch.expects(:load).with("config/foo.rb")

      run_example(["-c config/foo.rb"])
    end

    it "errors out if given a non-existent config file" do
      ::File.stubs(:exist?).with("config/foo.rb").returns(false)

      run_example(["-c config/foo.rb"]) do |tmpdir, out|
        out.must_include "Error: cannot load such file"
      end
    end

    it "loads multiple config files" do
      ::File.stubs(:exist?).with("config/foo.rb").returns(true)
      Bunch.expects(:load).with("config/foo.rb")
      ::File.stubs(:exist?).with("config/bar.rb").returns(true)
      Bunch.expects(:load).with("config/bar.rb")

      run_example(%w(-c config/foo.rb --config config/bar.rb)) do |_, out|
        out.must_equal ""
      end
    end

    it "runs the given environment's pipeline on the given path" do
      run_example do |tmpdir, out|
        out.must_equal ""
        FileTree.from_path(tmpdir).to_hash.must_equal(
          "directory" => "2\n\n1\n",
          "file3" => "3\n"
        )
      end
    end

    def run_example(params = nil)
      Dir.mktmpdir do |tmpdir|
        out = StringIO.new
        params ||= ["-e development"]
        params = [*params, "spec/example_tree", tmpdir]
        CLI.new(params, out).run!
        yield(tmpdir, out.string) if block_given?
      end
    end
  end
end
