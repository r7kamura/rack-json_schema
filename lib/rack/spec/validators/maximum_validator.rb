module Rack
  class Spec
    module Validators
      class MaximumValidator < Base
        register_as "maximum"

        def valid?
          value.nil? || value.to_f <= constraint
        end
      end
    end
  end
end
