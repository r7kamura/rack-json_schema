module Rack
  module Spec
    class RequestValidation
      # Behaves as a rack-middleware
      # @param app [Object] Rack application
      # @param schema [Hash] Schema object written in JSON schema format
      # @raise [JsonSchema::SchemaError]
      def initialize(app, schema: nil)
        @app = app
        @schema = Schema.new(schema)
      end

      # Behaves as a rack-middleware
      # @param env [Hash] Rack env
      def call(env)
        Validator.call(env: env, schema: @schema)
        @app.call(env)
      end

      class Validator
        # Utility wrapper method
        def self.call(**args)
          new(**args).call
        end

        # @param env [Hash] Rack env
        # @param schema [JsonSchema::Schema] Schema object
        def initialize(env: nil, schema: nil)
          @env = env
          @schema = schema
        end

        # Raises an error if any error detected
        # @raise [Rack::Spec::RequestValidation::Error]
        def call
          case
          when !has_link_for_current_action?
            raise LinkNotFound
          end
        end

        private

        # @return [true, false] True if link is defined for the current action(= method + path)
        def has_link_for_current_action?
          @schema.has_link_for?(method: method, path: path)
        end

        # Treats env as a utility object to easily extract method and path
        # @return [Rack::Request]
        def request
          @request ||= Rack::Request.new(@env)
        end

        # @return [String] HTTP request method
        # @example
        #   method #=> "GET"
        def method
          request.request_method
        end

        # @return [String] Request path
        # @example
        #   path #=> "/recipes"
        def path
          request.path_info
        end
      end

      # Base error class for Rack::Spec::RequestValidation
      class Error < StandardError
      end

      # Error class raised to requests to undefined routes
      class LinkNotFound < Error
      end
    end
  end
end
