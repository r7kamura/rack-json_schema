module Rack
  class Spec
    class Validation
      def initialize(app, options = {})
        @app = app
        @options = options
      end

      def call(env)
        parameters_validator.validate!(env)
        @app.call(env)
      end

      private

      def spec
        Spec.new(@options[:spec])
      end

      def parameters_validator
        @parameters_validator ||= Validators::ParametersValidator.new(spec)
      end
    end
  end
end
