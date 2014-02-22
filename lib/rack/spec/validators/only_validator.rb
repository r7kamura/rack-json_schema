module Rack
  class Spec
    module Validators
      class OnlyValidator < Base
        register_as "only"

        private

        def valid?
          value.nil? || constraint.include?(value)
        end
      end
    end
  end
end
