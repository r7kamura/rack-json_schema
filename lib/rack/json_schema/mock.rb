module Rack
  module JsonSchema
    class Mock
      # Behaves as a rack-middleware
      # @param app [Object] Rack application
      # @param schema [Hash] Schema object written in JSON schema format
      # @raise [JsonSchema::SchemaError]
      def initialize(app, schema: nil)
        @app = app
        @schema = Schema.new(schema)
      end

      # @param env [Hash] Rack env
      def call(env)
        RequestHandler.call(app: @app, env: env, schema: @schema)
      end

      class RequestHandler < BaseRequestHandler
        # @param app [Object] Rack application
        def initialize(app: nil, **args)
          @app = app
          super(**args)
        end

        # Returns dummy response if JSON schema is defined for the current link
        # @return [Array] Rack response
        def call
          if has_link_for_current_action?
            dummy_response
          else
            @app.call(@env)
          end
        end

        private

        def dummy_response
          [dummy_status, dummy_headers, [dummy_body]]
        end

        def dummy_status
          method == "POST" ? 201 : 200
        end

        def dummy_headers
          { "Content-Type" => "application/json; charset=utf-8" }
        end

        def dummy_body
          document = ResponseGenerator.call(schema_for_current_link)
          document = [document] if has_list_data?
          JSON.pretty_generate(document) + "\n"
        end
      end

      class ResponseGenerator
        # Generates example response Hash from given schema
        # @return [Hash]
        # @example
        #   Rack::JsonSchema::Mock::ResponseGenerator(schema) #=> { "id" => 1, "name" => "example" }
        def self.call(schema)
          schema.properties.inject({}) do |result, (key, value)|
            result.merge(
              key => case
              when !value.properties.empty?
                call(value)
              when !value.data["example"].nil?
                value.data["example"]
              when value.type.include?("null")
                nil
              when value.type.include?("array")
                [call(value.items)]
              else
                raise ExampleNotFound, "No example found for #{schema.pointer}/#{key}"
              end
            )
          end
        end
      end

      class Error < Error
      end

      class ExampleNotFound < Error
        def id
          "example_not_found"
        end

        def status
          500
        end
      end
    end
  end
end
