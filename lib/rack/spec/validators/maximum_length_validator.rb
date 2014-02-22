module Rack
  class Spec
    module Validators
      class MaximumLengthValidator < Base
        register_as "maximumLength"

        private

        def valid?
          value.nil? || value.length <= constraint
        end
      end
    end
  end
end
