module Rack
  class Spec
    module Validators
      class Base
        attr_reader :constraint, :key, :env

        def initialize(key, constraint, env)
          @key = key
          @constraint = constraint
          @env = env
        end

        def validate!
          unless valid?
            raise ValidationError, error_message
          end
        end

        private

        def valid?
          raise NotImplementedError
        end

        def error_message
          raise NotImplementedError
        end

        def value
          @value ||= request.params[@key]
        end

        def request
          env["rack-spec.request"] ||= Rack::Request.new(env)
        end
      end
    end
  end
end
