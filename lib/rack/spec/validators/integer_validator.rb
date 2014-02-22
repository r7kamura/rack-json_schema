module Rack
  class Spec
    module Validators
      class IntegerValidator < Base
        def validate!(env)
          value = extract_value(env)
          if value && value =~ /\A-?\d+\z/
            raise ValidationError, "Expected #@key to be #@constraint, but in fact #{value.inspect}"
          end
        end
      end
    end
  end
end
