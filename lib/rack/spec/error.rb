module Rack
  module Spec
    class Error < StandardError
      # @return [Array] Rack response
      def to_rack_response
        [status, headers, [body]]
      end

      private

      # @note Override this
      def status
        500
      end

      # @note Override this
      def id
        "internal_server_error"
      end

      def headers
        { "Content-Type" => "application/json" }
      end

      def body
        { id: id, message: message }.to_json
      end
    end
  end
end
