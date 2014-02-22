module Rack
  class Spec
    class Validation
      def initialize(app, options = {})
        @app = app
        @options = options
      end

      def call(env)
        Validators::ParametersValidator.new(spec, env).validate!
        @app.call(env)
      end

      private

      def spec
        Spec.new(@options[:spec])
      end
    end
  end
end
