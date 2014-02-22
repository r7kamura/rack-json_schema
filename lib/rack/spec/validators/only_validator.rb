module Rack
  class Spec
    module Validators
      class OnlyValidator < Base
        def validate!(env)
          value = extract_value(env)
          if value && !candidates.include?(value)
            raise ValidationError, "Expected #@key to be included in ##{candidates}, but in fact #{value.inspect}"
          end
        end

        private

        def candidates
          @constraint
        end
      end
    end
  end
end
