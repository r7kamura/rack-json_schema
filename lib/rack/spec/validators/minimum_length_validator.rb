module Rack
  class Spec
    module Validators
      class MinimumLengthValidator < Base
        register_as "minimumLength"

        private

        def valid?
          value.nil? || value.length >= constraint
        end
      end
    end
  end
end
