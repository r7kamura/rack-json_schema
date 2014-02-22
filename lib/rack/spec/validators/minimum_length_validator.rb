module Rack
  class Spec
    module Validators
      class MinimumLengthValidator < Base
        def validate!(env)
          value = extract_value(env)
          if value && value.length < minimum_length
            raise ValidationError, "Expected #@key to be equal or longer than #{minimum_length}, but in fact #{value.inspect}"
          end
        end

        private

        def minimum_length
          @constraint
        end
      end
    end
  end
end
