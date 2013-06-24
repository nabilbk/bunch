# encoding: UTF-8

require "spec_helper"
require "rack"

module Bunch
  describe Middleware do
    let(:app) { stub(:app) }
    let(:root) { ::File.expand_path("../../example_tree", __FILE__) }
    let(:middleware) { Middleware.new(app, "/javascripts" => root) }

    it "serves matching requests" do
      env = Rack::MockRequest.env_for("/javascripts/directory")

      status, headers, body = middleware.call(env)

      status.must_equal 200
      headers["Content-Type"].must_equal "text/plain"
      body.must_equal ["2\n\n1\n"]
    end

    it "cascades if there's no appropriate mapping" do
      env = Rack::MockRequest.env_for("/alskjdlakj")
      app.expects(:call).with(env).returns "OK"

      middleware.call(env).must_equal "OK"
    end

    it "doesn't cascade if the Bunch server 404s" do
      root = ::File.expand_path("../../example_tree", __FILE__)
      env  = Rack::MockRequest.env_for("/javascripts/directories")
      middleware = Middleware.new(nil, "/javascripts" => root)

      status, headers, body = middleware.call(env)

      status.must_equal 404
    end
  end
end
