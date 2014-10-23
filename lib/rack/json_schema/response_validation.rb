module Rack
  module JsonSchema
    class ResponseValidation
      # Behaves as a rack-middleware
      # @param app [Object] Rack application
      # @param schema [Hash] Schema object written in JSON schema format
      # @raise [JsonSchema::SchemaError]
      def initialize(app, schema: nil)
        @app = app
        @schema = Schema.new(schema)
      end

      # @raise [Rack::JsonSchema::ResponseValidation::Error]
      # @param env [Hash] Rack env
      def call(env)
        @app.call(env).tap do |response|
          Validator.call(env: env, response: response, schema: @schema)
        end
      end

      class Validator < BaseRequestHandler
        # @param env [Hash] Rack env
        # @param response [Array] Rack response
        # @param schema [JsonSchema::Schema] Schema object
        def initialize(env: nil, response: nil, schema: nil)
          @env = env
          @response = response
          @schema = schema
        end

        # Raises an error if any error detected, skipping validation for non-defined link
        # @raise [Rack::JsonSchema::ResponseValidation::InvalidResponse]
        def call
          if !has_redirection_or_error_status? && has_link_for_current_action? && has_link_of_media_type_json?
            case
            when !has_json_content_type?
              raise InvalidResponseContentType
            when !valid?
              raise InvalidResponseType, validator.errors
            end
          end
        end

        # @return [true, false] True if Link mediaType is for JSON
        def has_link_of_media_type_json?
          mime_type_json?(link.media_type)
        end

        # @return [true, false] True if response Content-Type is for JSON
        def has_json_content_type?
          mime_type_json?(mime_type)
        end

        # @return [true, false] True if given data is valid to the JSON schema
        def valid?
          (has_list_data? && data.empty?) || validator.validate(example_item)
        end

        # @return [Hash] Choose an item from response data, to be validated
        def example_item
          if has_list_data?
            data.first
          else
            data
          end
        end

        # @return [Array, Hash] Response body data, decoded from JSON
        def data
          JSON.parse(body)
        end

        # @return [JsonSchema::Validator]
        # @note The result is memoized for returning errors in invalid case
        def validator
          @validator ||= ::JsonSchema::Validator.new(schema_for_current_link)
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

        # @return [Fixnum] Response status code
        def response_status
          @response[0]
        end

        # Skips validation if status code is equal to or larger than 300
        # @return [true, false]
        def has_redirection_or_error_status?
          response_status >= 300
        end

        # @return [String, nil] Response MIME Type specified in Content-Type header field
        # @example
        #   mime_type #=> "application/json"
        def mime_type
          headers["Content-Type"].split(";").first if headers["Content-Type"]
        end

        # @return [true, false] return true if mime type is for JSON
        # @example
        #   "application/json" #=> true
        #   "application/calendar+json" #=> true
        #   "application/vnd.myapp.custom-json" #=> false
        def mime_type_json?(value)
          %r<\Aapplication/(?:.*\+)?json> === value
        end
      end

      # Base error class for Rack::JsonSchema::ResponseValidation
      class Error < Error
      end

      class InvalidResponseType < Error
        def initialize(errors)
          super ::JsonSchema::SchemaError.aggregate(errors).join(" ")
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
