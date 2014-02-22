module Rack
  class Spec
    module Validators
      class MinimumValidator < Base
        def validate!(env)
          value = extract_value(env)
          if value && value.to_f < minimum
            raise ValidationError, "Expected #@key to be equal or higher than #{minimum}, but in fact #{value.inspect}"
          end
        end

        private

        def minimum
          @constraint
        end
      end
    end
  end
end
