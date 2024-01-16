module Rack
  module JsonSchema
    # Base class for providing some utility methods to handle Rack env and JSON Schema
    class BaseRequestHandler
      # Utility wrapper method
      def self.call(*args, **kwargs)
        new(*args, **kwargs).call
      end

      # @param env [Hash] Rack env
      # @param schema [JsonSchema::Schema] Schema object
      def initialize(env: nil, schema: nil)
        @env = env
        @schema = schema
      end

      private

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

      # @return [JsonSchema::Schema::Link, nil] Link for the current action
      def link
        if instance_variable_defined?(:@link)
          @link
        else
          @link = @schema.link_for(method: method, path: path)
        end
      end

      # @return [true, false] True if link is defined for the current action
      def has_link_for_current_action?
        !!link
      end

      # @return [JsonSchema::Schema] Schema for current link, specified by targetSchema or parent schema
      def schema_for_current_link
        link.target_schema || link.parent
      end

      # @return [true, false] True if response is intended to be list data
      def has_list_data?
        link.rel == "instances"
      end
    end
  end
end
