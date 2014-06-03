module Rack
  module Spec
    class RequestValidation
      # Behaves as a rack-middleware
      # @param app [Object] Rack application
      # @param schema [Hash] Schema object written in JSON schema format
      # @raise JsonSchema::SchemaError
      def initialize(app, schema: nil)
        @app = app
        @schema = JsonSchema.parse!(schema).tap(&:expand_references!)
      end

      # Behaves as a rack-middleware
      # @param env [Hash] Rack env
      def call(env)
        @app.call(env)
      end
    end
  end
end
