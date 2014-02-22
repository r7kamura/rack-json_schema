module Rack
  class Spec
    module Validators
      class MinimumLengthValidator < Base
        private

        def valid?
          value.nil? || value.length >= constraint
        end

        def error_message
          "Expected #{key} to be equal or longer than #{constraint}, but in fact #{value.inspect}"
        end
      end
    end
  end
end
