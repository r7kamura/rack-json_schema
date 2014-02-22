module Rack
  class Spec
    module Validators
      class OnlyValidator < Base
        register_as "only"

        private

        def valid?
          value.nil? || constraint.include?(value)
        end

        def error_message
          "Expected #{key} to be included in #{constraint}, but in fact #{value.inspect}"
        end
      end
    end
  end
end
