# encoding: UTF-8

require "rack"

module Bunch
  class Middleware
    def initialize(app, paths_and_options)
      @app = app
      @url_map = Rack::Deflater.new(build_url_map(paths_and_options))
    end

    def call(env)
      response = @url_map.call(env)

      if response[1]["X-Cascade"] == "pass"
        @app.call(env)
      else
        response
      end
    end

    private

    def build_url_map(paths_and_options)
      paths, options_arr = paths_and_options.partition { |k, _| String === k }
      options = { environment: "development" }.merge(Hash[options_arr])
      mapping = Hash[paths.map do |url, directory|
        [url, Server.new(options.merge(root: directory))]
      end]
      Rack::URLMap.new(mapping)
    end
  end
end
