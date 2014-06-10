module Rack
  module JsonSchema
    class SchemaProvider
      DEFAULT_PATH = "/schema"

      # Behaves as a rack-middleware
      # @param app [Object] Rack application
      # @param path [String, nil] URL path to return JSON Schema (default: /schema)
      # @param schema [Hash] Schema object written in JSON schema format
      # @raise [JsonSchema::SchemaError]
      def initialize(app, path: nil, schema: nil)
        @app = app
        @path = path
        @schema = schema
      end

      # Returns rendered document for document request
      # @return [Array] Rack response
      # @param env [Hash] Rack env
      def call(env)
        if env["REQUEST_METHOD"] == "GET" && env["PATH_INFO"] == path
          [
            200,
            { "Content-Type" => "application/json" },
            [rendered_schema],
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

      # @return [String] Rendered JSON Schema in JSON format
      def rendered_schema
        JSON.pretty_generate(@schema)
      end
    end
  end
end
