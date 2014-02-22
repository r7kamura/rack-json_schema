module Rack
  class Spec
    module Validators
      class RequiredValidator < Base
        register_as "required"

        def valid?
          value.nil? == !constraint
        end
      end
    end
  end
end
