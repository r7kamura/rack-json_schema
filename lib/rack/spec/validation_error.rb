require "json"

module Rack
  class Spec
    class ValidationError < StandardError
      def initialize(message)
        @message = message
      end

      def message
        @message
      end

      def to_rack_response
        [status, header, body]
      end

      private

      def status
        400
      end

      def header
        { "Content-Type" => "application/json" }
      end

      def body
        { message: @message }.to_json
      end
    end
  end
end
