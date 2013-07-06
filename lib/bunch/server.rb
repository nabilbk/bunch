# encoding: UTF-8

require "mime/types"

module Bunch
  class Server
    def initialize(options = {})
      @root = options.fetch(:root, "no-root")
      @reader = options.fetch(:reader) do
        proc { FileTree.from_path(@root) }
      end
      @pipeline = options.fetch(:pipeline) do
        Pipeline.for_environment options.fetch(:env, "development"), @root
      end
      @headers = options.fetch(:headers) do
        {
          "Cache-Control" => "private, max-age=0, must-revalidate",
          "Pragma" => "no-cache",
          "Expires" => "Thu, 01 Dec 1994 16:00:00 GMT"
        }
      end
    end

    def call(env)
      path = env["PATH_INFO"].sub(/^\//, '')
      type = mime_type_for_path(path)
      tree = @pipeline.process(@reader.call)
      file = tree.get(path)

      if file.is_a?(File)
        [200, headers_for_type(type), [file.content]]
      else
        [404, headers_for_type("text/plain"), ["Not Found"]]
      end
    rescue => e
      [500, headers_for_type("text/plain"), [error_message(e)]]
    end

    private

    def mime_type_for_path(path)
      MIME::Types.type_for(path).first || "text/plain"
    end

    def headers_for_type(mime_type)
      @headers.merge("Content-Type" => mime_type.to_s)
    end

    def error_message(e)
      "#{e.class}: #{e.message}\n  #{e.backtrace.join("\n  ")}"
    end
  end
end
