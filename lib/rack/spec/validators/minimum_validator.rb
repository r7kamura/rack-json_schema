module Rack
  class Spec
    module Validators
      class MinimumValidator < Base
        register_as "minimum"

        private

        def valid?
          value.nil? || value.to_f >= constraint
        end
      end
    end
  end
end
