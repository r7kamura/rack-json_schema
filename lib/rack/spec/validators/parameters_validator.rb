module Rack
  class Spec
    module Validators
      class ParametersValidator
        def initialize(spec)
          @spec = spec
        end

        def validate!(env)
          parameters = @spec.reach("endpoints", env["PATH_INFO"], env["REQUEST_METHOD"], "parameters") || {}
          parameters.each do |key, hash|
            hash.each do |type, constraint|
              ValidatorFactory.build(key, type, constraint, env).validate!
            end
          end
        end
      end
    end
  end
end
