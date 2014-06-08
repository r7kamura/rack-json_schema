module Rack
  module JsonSchema

    # Utility wrapper class for JsonSchema::Schema
    class Schema
      # Recursively extracts all links in given JSON schema
      # @param json_schema [JsonSchema::Schema]
      # @return [Array] An array of JsonSchema::Schema::Link
      def self.extract_links(json_schema)
        links = json_schema.links.select {|link| link.method && link.href }
        links + json_schema.properties.map {|key, schema| extract_links(schema) }.flatten
      end

      # @param schema [Hash]
      # @raise [JsonSchema::SchemaError]
      # @example
      #   hash = JSON.parse("schema.json")
      #   schema = Rack::JsonSchema::Schema.new(hash)
      def initialize(schema)
        @json_schema = ::JsonSchema.parse!(schema).tap(&:expand_references!)
      end

      # @param method [String] Uppercase HTTP method name (e.g. GET, POST)
      # @param path [String] Path string, which may include URI template
      # @return [JsonSchema::Scheam::Link, nil] Link defined for the given method and path
      # @example
      #   schema.has_link_for?(method: "GET", path: "/recipes/{+id}") #=> nil
      def link_for(method: nil, path: nil)
        links_indexed_by_method[method].find do |link|
          %r<^#{link.href.gsub(/\{(.*?)\}/, "[^/]+")}$> === path
        end
      end

      # @return [Array] All links defined in given JSON schema
      # @example
      #   schema.links #=> [#<JsonSchema::Schema::Link>]
      def links
        @links ||= self.class.extract_links(@json_schema)
      end

      private

      # @return [Hash] A key-value pair of HTTP method and an Array of links
      # @note This Hash always returns an Array for any key
      # @example
      #   schema.links_indexed_by_method #=> { "GET" => [#<JsonSchema::Schema::Link>] }
      def links_indexed_by_method
        @links_indexed_by_method ||= links.inject(Hash.new {|hash, key| hash[key] = [] }) do |result, link|
          result[link.method.to_s.upcase] << link
          result
        end
      end
    end
  end
end
