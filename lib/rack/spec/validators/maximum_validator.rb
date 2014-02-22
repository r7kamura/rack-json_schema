module Rack
  class Spec
    module Validators
      class MaximumValidator < Base
        private

        def valid?
          value.nil? || value.to_f <= constraint
        end

        def error_message
          "Expected #{key} to be equal or higher than #{constraint}, but in fact #{value.inspect}"
        end
      end
    end
  end
end
