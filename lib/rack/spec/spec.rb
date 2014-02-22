module Rack
  class Spec
    class Spec < Hash
      def initialize(hash)
        hash.each do |key, value|
          self[key] = value
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
