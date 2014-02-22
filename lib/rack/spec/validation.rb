module Rack
  class Spec
    class Validation
      def initialize(app, options = {})
        @app = app
        @options = options
      end

      def call(env)
        query_parameters_validator.validate!(env)
        @app.call(env)
      end

      private

      def spec
        Spec.new(@options[:spec])
      end

      def query_parameters_validator
        @query_parameters_validator ||= Validators::QueryParametersValidator.new(spec)
      end
    end
  end
end
