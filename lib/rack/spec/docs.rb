module Rack
  module Spec
    class Docs
      DEFAULT_PATH = "/docs"

      # Behaves as a rack-middleware
      # @param app [Object] Rack application
      # @param path [String, nil] URL path to return document (default: /docs)
      # @param schema [Hash] Schema object written in JSON schema format
      def initialize(app, path: nil, schema: nil)
        @app = app
        @path = path
        @document = Jdoc::Generator.call(schema)
      end

      # Returns rendered document for document request
      # @param env [Hash] Rack env
      def call(env)
        if env["REQUEST_METHOD"] == "GET" && env["PATH_INFO"] == path
          [
            200,
            { "Content-Type" => "text/plain; charset=utf-8" },
            [@document],
          ]
        else
          @app.call(env)
        end
      end

      private

      # @return [String] Path to return document
      def path
        @path || DEFAULT_PATH
      end
    end
  end
end
