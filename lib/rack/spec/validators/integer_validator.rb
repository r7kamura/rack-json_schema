module Rack
  class Spec
    module Validators
      class IntegerValidator < Base
        def initialize(key)
          @key = key
        end

        def validate!(env)
          value = extract_value(env)
          if value && value =~ /\A-?\d+\z/
            raise ValidationError, "Expected #@key to be integer, but in fact #{value.inspect}"
          end
        end
      end
    end
  end
end
