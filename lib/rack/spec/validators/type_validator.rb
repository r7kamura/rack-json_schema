require "time"

module Rack
  class Spec
    module Validators
      class TypeValidator < Base
        def validate!(env)
          value = extract_value(env) or return
          unless pattern === value
            raise ValidationError, "Expected #@key to be #@constraint, but in fact #{value.inspect}"
          end
        end

        private

        def pattern
          case @constraint
          when "float"
            /\A-?\d+(?:\.\d+)*\z/
          when "integer"
            /\A-?\d+\z/
          when "iso8601"
            ->(value) { Time.iso8601(value) rescue false }
          else
            //
          end
        end
      end
    end
  end
end
