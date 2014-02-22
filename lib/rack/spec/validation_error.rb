require "json"

module Rack
  class Spec
    class ValidationError < StandardError
      def initialize(validator)
        @validator = validator
      end

      def message
        "Invalid #{key} on `#{constraint_name}` constraint"
      end

      def to_rack_response
        [status, header, body]
      end

      private

      def constraint_name
        @validator.class.registered_name
      end

      def key
        @validator.key
      end

      def status
        400
      end

      def header
        { "Content-Type" => "application/json" }
      end

      def body
        { message: message }.to_json
      end
    end
  end
end
