module Rack
  class Spec
    class ExceptionHandler
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call(env)
      rescue ValidationError => exception
        exception.to_rack_response
      end
    end
  end
end
