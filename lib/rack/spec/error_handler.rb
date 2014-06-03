module Rack
  module Spec
    class ErrorHandler
      # Behaves as a rack middleware
      # @param app [Object] Rack application
      def initialize(app)
        @app = app
      end

      # Behaves as a rack middleware
      # @param env [Hash] Rack env
      def call(env)
        @app.call(env)
      rescue Rack::Spec::Error => exception
        exception.to_rack_response
      end
    end
  end
end
