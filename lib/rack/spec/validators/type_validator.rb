require "time"

module Rack
  class Spec
    module Validators
      class TypeValidator < Base
        class << self
          def patterns
            @patterns ||= Hash.new(//)
          end

          def register(name, pattern)
            patterns[name] = pattern
          end
        end

        register "float", /\A-?\d+(?:\.\d+)*\z/
        register "integer", /\A-?\d+\z/
        register "iso8601", ->(value) { Time.iso8601(value) rescue false }

        def validate!(env)
          value = extract_value(env) or return
          unless pattern === value
            raise ValidationError, "Expected #@key to be #@constraint, but in fact #{value.inspect}"
          end
        end

        private

        def pattern
          self.class.patterns[@constraint]
        end
      end
    end
  end
end
