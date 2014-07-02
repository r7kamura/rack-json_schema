module Rack
  module JsonSchema
    class RequestValidation
      # Behaves as a rack-middleware
      # @param app [Object] Rack application
      # @param schema [Hash] Schema object written in JSON schema format
      # @raise [JsonSchema::SchemaError]
      def initialize(app, schema: nil)
        @app = app
        @schema = Schema.new(schema)
      end

      # @raise [Rack::JsonSchema::RequestValidation::Error] Raises if given request is invalid to JSON Schema
      # @param env [Hash] Rack env
      def call(env)
        Validator.call(env: env, schema: @schema)
        @app.call(env)
      end

      class Validator < BaseRequestHandler
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
        # @raise [Rack::JsonSchema::RequestValidation::Error]
        def call
          case
          when !has_link_for_current_action?
            raise LinkNotFound
          when has_body? && !has_valid_content_type?
            raise InvalidContentType
          when has_body? && !has_valid_json?
            raise InvalidJson
          when has_schema? && !has_valid_parameter?
            raise InvalidParameter, "Invalid request.\n#{schema_validation_error_message}"
          end
        end

        private

        def has_valid_json?
          parameters
          true
        rescue JSON::JSONError
          false
        end

        # @return [true, false] True if request parameters are all valid
        def has_valid_parameter?
          schema_validation_result[0]
        end

        # @return [true, false] True if any schema is defined for the current action
        def has_schema?
          !!link.schema
        end

        # @return [true, false] True if request body is not empty
        def has_body?
          !body.empty?
        end

        # @return [true, false] True if no or matched content type given
        def has_valid_content_type?
          mime_type.nil? || Rack::Mime.match?(link.enc_type, mime_type)
        end

        # @return [Array] A result of schema validation for the current action
        def schema_validation_result
          @schema_validation_result ||= link.schema.validate(parameters)
        end

        # @return [Array] Errors of schema validation
        def schema_validation_errors
          schema_validation_result[1]
        end

        # @return [String] Joined error message to the result of schema validation
        def schema_validation_error_message
          ::JsonSchema::SchemaError.aggregate(schema_validation_errors).join("\n")
        end

        # @return [String, nil] Request MIME Type specified in Content-Type header field
        # @example
        #   mime_type #=> "application/json"
        def mime_type
          request.content_type.split(";").first if request.content_type
        end

        # @return [String] request body
        def body
          if instance_variable_defined?(:@body)
            @body
          else
            @body = request.body.read
            request.body.rewind
            @body
          end
        end

        # @return [Hash] Request parameters decoded from JSON
        # @raise [JSON::JSONError]
        def parameters
          @parameters ||= parameters_from_query.merge(parameters_from_body)
        end

        # @return [Hash] Request parameters decoded from JSON
        # @raise [JSON::JSONError]
        def parameters_from_body
          if has_body?
            JSON.parse(body)
          else
            {}
          end
        end

        # @return [Hash] Request parameters extracted from URI query
        def parameters_from_query
          request.GET
        end
      end

      # Base error class for Rack::JsonSchema::RequestValidation
      class Error < Error
      end

      # Error class for case when no link defined for given request
      class LinkNotFound < Error
        def initialize
          super("Not found")
        end

        def status
          404
        end

        def id
          "link_not_found"
        end
      end

      # Error class for invalid request content type
      class InvalidContentType < Error
        def initialize
          super("Invalid content type")
        end

        def status
          400
        end

        def id
          "invalid_content_type"
        end
      end

      # Error class for invalid JSON
      class InvalidJson < Error
        def initialize
          super("Request body wasn't valid JSON")
        end

        def status
          400
        end

        def id
          "invalid_json"
        end
      end

      # Error class for invalid request parameter
      class InvalidParameter < Error
        def status
          400
        end

        def id
          "invalid_parameter"
        end
      end
    end
  end
end
