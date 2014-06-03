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
          when has_body? && !has_valid_content_type?
            raise InvalidContentType
          when has_body? && !has_valid_json?
            raise InvalidJson
          when has_body? && has_schema? && !has_valid_parameter?
            raise InvalidParameter, "Invalid request.\n#{schema_validation_error_message}"
          end
        end

        private

        def has_valid_json?
          parameters
          true
        rescue MultiJson::ParseError
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
          content_type.nil? || Rack::Mime.match?(link.enc_type, content_type)
        end

        # @return [true, false] True if link is defined for the current action
        def has_link_for_current_action?
          !!link
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
          JsonSchema::SchemaError.aggregate(schema_validation_errors).join("\n")
        end

        # @return [JsonSchema::Schema::Link, nil] Link for the current action
        def link
          if instance_variable_defined?(:@link)
            @link
          else
            @link = @schema.link_for(method: method, path: path)
          end
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

        # @return [String] Request content type
        # @example
        #   path #=> "application/json"
        def content_type
          request.content_type
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
        # @raise [MultiJson::ParseError]
        def parameters
          @parameters ||= begin
            if has_body?
              MultiJson.decode(body)
            else
              {}
            end
          end
        end
      end

      # Base error class for Rack::Spec::RequestValidation
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
