module Rack
  class Spec
    module Validators
      class MaximumValidator < Base
        def validate!(env)
          value = extract_value(env)
          if value && value.to_f > maximum
            raise ValidationError, "Expected #@key to be equal or less than #{maximum}, but in fact #{value.inspect}"
          end
        end

        private

        def maximum
          @constraint
        end
      end
    end
  end
end
