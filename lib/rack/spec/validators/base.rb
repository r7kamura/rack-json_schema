module Rack
  class Spec
    module Validators
      class Base
        def initialize(key, constraint)
          @key = key
          @constraint = constraint
        end

        def validate!(env)
          raise NotImplementedError
        end

        private

        def extract_value(env)
          env["rack-spec.request"] ||= Rack::Request.new(env)
          env["rack-spec.request"].params[@key]
        end
      end
    end
  end
end
