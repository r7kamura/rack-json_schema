module Rack
  class Spec
    module Validators
      class TypeValidator < Base
        def validate!(env)
          value = extract_value(env) or return
          unless value.match(pattern)
            raise ValidationError, "Expected #@key to be #@constraint, but in fact #{value.inspect}"
          end
        end

        private

        def pattern
          case @constraint
          when "integer"
            /\A-?\d+\z/
          else
            //
          end
        end
      end
    end
  end
end
