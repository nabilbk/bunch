# encoding: UTF-8

require "spec_helper"
require "rack"

module Bunch
  describe Server do
    describe "from the filesystem" do
      let(:root)   { ::File.expand_path("../../example_tree", __FILE__) }
      let(:server) { Server.new(root: root, environment: "development") }

      it "serves a combined file" do
        env = Rack::MockRequest.env_for("/directory")

        status, headers, body = server.call(env)

        status.must_equal 200
        headers["Content-Type"].must_equal "text/plain"
        body.must_equal ["2\n\n1\n"]
      end

      it "serves a non-combined file" do
        env = Rack::MockRequest.env_for("/file3")

        status, headers, body = server.call(env)

        status.must_equal 200
        headers["Content-Type"].must_equal "text/plain"
        body.must_equal ["3\n"]
      end

      it "serves 404 if asked for a nonexistent path" do
        env = Rack::MockRequest.env_for("/nonexistent_file")

        status, headers, body = server.call(env)

        status.must_equal 404
        headers["Content-Type"].must_equal "text/plain"
        body.must_equal ["Not Found"]
      end
    end

    it "shows a backtrace if there's an error" do
      reader = proc { raise "WTF!??" }
      server = Server.new(reader: reader, environment: "development")
      env    = Rack::MockRequest.env_for("/file3")

      status, headers, body = server.call(env)

      status.must_equal 500
      headers["Content-Type"].must_equal "text/plain"
      body[0].must_match(/WTF!\?\?/)
    end

    describe "serving a JavaScript file" do
      let(:tree)   { FileTree.from_hash("foo.js" => "hello;") }
      let(:reader) { proc { tree } }
      let(:server) { Server.new(reader: reader, environment: "development") }
      let(:env)    { Rack::MockRequest.env_for("/foo.js") }

      it "serves the correct MIME type for the requested file" do
        status, headers, body = server.call(env)

        status.must_equal 200
        headers["Content-Type"].must_equal "application/javascript"
        body.must_equal ["hello;"]
      end

      it "includes caching headers by default" do
        status, headers, body = server.call(env)

        %w(Cache-Control Pragma Expires).each do |header_name|
          assert headers.has_key?(header_name), "Missing #{header_name} header"
        end
      end
    end

    it "shows a backtrace if there's an error" do
      reader = proc { raise "WTF!??" }
      server = Server.new(reader: reader, environment: "development")
      env    = Rack::MockRequest.env_for("/file3")

      status, headers, body = server.call(env)

      status.must_equal 500
      headers["Content-Type"].must_equal "text/plain"
      body[0].must_match(/WTF!\?\?/)
    end
  end
end
