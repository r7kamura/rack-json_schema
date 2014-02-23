require "addressable/template"

module Rack
  class Spec
    class Spec < Hash
      def initialize(hash)
        hash.each do |key, value|
          self[key] = value
        end
      end

      def find_endpoint(env)
        self["endpoints"].find do |path, source|
          if parameters = Addressable::Template.new(path).extract(env["PATH_INFO"])
            if endpoint = source[env["REQUEST_METHOD"]]
              env["rack-spec.uri_parameters"] = parameters
              break endpoint
            end
          end
        end
      end

      def reach(*keys)
        keys.inject(self) do |hash, key|
          hash[key] if hash.respond_to?(:[])
        end
      end
    end
  end
end
