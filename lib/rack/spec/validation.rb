module Rack
  class Spec
    class Validation
      def initialize(app, options = {})
        @app = app
        @options = options
      end

      def call(env)
        validator.call(env)
      end

      private

      def validator
        @validator ||= Validator.new(@app, @options)
      end
    end
  end
end
