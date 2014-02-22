module Rack
  class Spec
    module Validators
      class MaximumLengthValidator < Base
        def validate!(env)
          value = extract_value(env)
          if value && value.length > maximum_length
            raise ValidationError, "Expected #@key to be equal or shorter than #{maximum_length}, but in fact #{value.inspect}"
          end
        end

        private

        def maximum_length
          @constraint
        end
      end
    end
  end
end
