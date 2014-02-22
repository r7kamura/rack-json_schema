module Rack
  class Spec
    module Validators
      class QueryParametersValidator
        def initialize(spec)
          @spec = spec
        end

        def validate!(env)
          parameters = @spec.reach("endpoints", env["PATH_INFO"], env["REQUEST_METHOD"], "queryParameters") || {}
          parameters.each do |key, hash|
            hash.each do |type, constraint|
              ValidatorFactory.build(key, type, constraint).validate!(env)
            end
          end
        end
      end
    end
  end
end
