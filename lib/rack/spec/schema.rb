module Rack
  module Spec

    # Utility wrapper class for JsonSchema::Schema
    class Schema
      # Recursively extracts all links in given JSON schema
      # @param json_schema [JsonSchema::Schema]
      # @return [Array] An array of JsonSchema::Schema::Link
      def self.extract_links(json_schema)
        links = json_schema.links
        links + json_schema.properties.map {|key, schema| extract_links(schema) }.flatten
      end

      # @param schema [Hash]
      # @raise [JsonSchema::SchemaError]
      # @example
      #   hash = JSON.parse("schema.json")
      #   schema = Rack::Spec::Schema.new(hash)
      def initialize(schema)
        @json_schema = JsonSchema.parse!(schema).tap(&:expand_references!)
      end

      # @param method [String] Uppercase HTTP method name (e.g. GET, POST)
      # @param path [String] Path string, which may include URI template
      # @return [true, false] True if any link is defined in JSON schema for the given method & path
      # @example
      #   schema.has_link_for?(method: "GET", path: "/recipes/{+id}") #=> false
      def has_link_for?(method: nil, path: nil)
        routes[method].any? do |href|
          %r<^#{href.gsub(/\{(.*?)\}/, "[^/]+")}$> === path
        end
      end

      private

      # @return [Array] All links defined in given JSON schema
      # @example
      #   schema.links #=> [{ href: "/recipes", method: "GET" }]
      def links
        @links ||= self.class.extract_links(@json_schema).map do |link|
          if link.method && link.href
            {
              href: link.href,
              method: link.method.to_s.upcase,
            }
          end
        end.compact
      end

      # @return [Hash] A key-value pair of HTTP method and an Array of href paths under the method
      # @note This Hash always returns an Array for any key
      # @example
      #   schema.routes #=> { "GET" => ["/recipes"] }
      def routes
        @routes ||= links.inject(Hash.new {|hash, key| hash[key] = [] }) do |result, link|
          method = link[:method]
          result[method] << link[:href]
          result
        end
      end
    end
  end
end
