module Rack
  class Spec
    module Validators
      class MinimumValidator
        def initialize(key, minimum)
          @key = key
          @minimum = minimum
        end

        def validate!(env)
          request = Rack::Request.new(env)
          value = request.params[@key]
          if value && value.to_i < @minimum
            raise ValidationError, "Expected #@key to be equal or higher than #@minimum, but in fact #{value.inspect}"
          end
        end
      end
    end
  end
end
