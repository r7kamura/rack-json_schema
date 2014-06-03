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
          end
        end

        private

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
      end

      # Base error class for Rack::Spec::RequestValidation
      class Error < StandardError
      end

      # Error class for case when no link defined for given request
      class LinkNotFound < Error
      end

      # Error class for invalid request content type
      class InvalidContentType < Error
      end
    end
  end
end
