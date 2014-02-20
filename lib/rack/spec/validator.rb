module Rack
  class Spec
    class Validator
      def initialize(app, options = {})
        @app = app
        @options = options
      end

      def call(env)
        query_parameters_validator.validate!(env)
        @app.call(env)
      end

      def document
        Source.new(@options[:source])
      end

      def query_parameters_validator
        @query_parameters_validator ||= QueryParametersValidator.new(document)
      end
    end
  end
end
