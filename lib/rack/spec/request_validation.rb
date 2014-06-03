module Rack
  module Spec
    class RequestValidation
      def initialize(app, schema: nil)
        @app = app
        @schema = schema
      end

      def call(env)
        @app.call(env)
      end
    end
  end
end
