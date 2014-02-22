module Rack
  class Spec
    module Validators
      class MaximumLengthValidator < Base
        register_as "maximumLength"

        private

        def valid?
          value.nil? || value.length <= constraint
        end

        def error_message
          "Expected #{key} to be equal or shorter than #{constraint}, but in fact #{value.inspect}"
        end
      end
    end
  end
end
