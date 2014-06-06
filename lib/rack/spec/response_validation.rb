module Rack
  module Spec
    class ResponseValidation
      # Behaves as a rack-middleware
      # @param app [Object] Rack application
      # @param schema [Hash] Schema object written in JSON schema format
      # @raise [JsonSchema::SchemaError]
      def initialize(app, schema: nil)
        @app = app
        @schema = Schema.new(schema)
      end

      # @raise [Rack::Spec::ResponseValidation::Error]
      # @param env [Hash] Rack env
      def call(env)
        @app.call(env).tap do |response|
          Validator.call(env: env, response: response, schema: @schema)
        end
      end

      class Validator < BaseValidator
        # @param env [Hash] Rack env
        # @param response [Array] Rack response
        # @param schema [JsonSchema::Schema] Schema object
        def initialize(env: nil, response: nil, schema: nil)
          @env = env
          @response = response
          @schema = schema
        end

        # Raises an error if any error detected
        # @raise [Rack::Spec::ResponseValidation::InvalidResponse]
        def call
          case
          when !has_json_content_type?
            raise InvalidResponseContentType
          when !valid?
            raise InvalidResponseType, validator.errors
          end
        end

        # @return [true, false] True if response Content-Type is for JSON
        def has_json_content_type?
          %r<\Aapplication/.*json> === headers["Content-Type"]
        end

        # @return [true, false] True if given data is valid to the JSON schema
        def valid?
          !has_link_for_current_action? || validator.validate(example_item)
        end

        # @return [Hash] Choose an item from response data, to be validated
        def example_item
          if has_list_data?
            data.first
          else
            data
          end
        end

        # @return [true, false] True if response is intended to be list data
        def has_list_data?
          link.rel == "instances" && !link.target_schema
        end

        # @return [Array, Hash] Response body data, decoded from JSON
        def data
          MultiJson.decode(body)
        end

        # @return [JsonSchema::Validator]
        # @note The result is memoized for returning errors in invalid case
        def validator
          @validator ||= JsonSchema::Validator.new(schema_for_current_link)
        end

        # @return [JsonSchema::Schema] Schema for current link, specified by targetSchema or parent schema
        def schema_for_current_link
          link.target_schema || link.parent
        end

        # @return [Hash] Response headers
        def headers
          @response[1]
        end

        # @return [String] Response body
        def body
          result = ""
          @response[2].each {|str| result << str }
          result
        end
      end

      # Base error class for Rack::Spec::ResponseValidation
      class Error < Error
      end

      class InvalidResponseType < Error
        def initialize(errors)
          super JsonSchema::SchemaError.aggregate(errors).join(" ")
        end

        def id
          "invalid_response_type"
        end

        def status
          500
        end
      end

      class InvalidResponseContentType < Error
        def initialize
          super("Response Content-Type wasn't for JSON")
        end

        def id
          "invalid_response_content_type"
        end

        def status
          500
        end
      end
    end
  end
end
