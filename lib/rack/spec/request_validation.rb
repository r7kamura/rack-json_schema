module Rack
  module Spec
    class RequestValidation
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call(env)
      end
    end
  end
end
