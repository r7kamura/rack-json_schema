module Rack
  class Spec
    module Validators
      class Base
        class << self
          attr_accessor :registered_name

          def register_as(name)
            self.registered_name = name
            ValidatorFactory.register(name, self)
          end
        end

        attr_reader :constraint, :key, :env

        def initialize(key, constraint, env)
          @key = key
          @constraint = constraint
          @env = env
        end

        def validate!
          unless valid?
            raise ValidationError, self
          end
        end

        def valid?
          raise NotImplementedError
        end

        private

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
