module Rack
  class Spec
    class ExceptionHandler
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call(env)
      rescue Exceptions::ValidationError => exception
        exception.to_rack_response
      end
    end
  end
end
