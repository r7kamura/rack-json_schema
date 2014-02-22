module Rack
  class Spec
    module Validators
      class NullValidator < Base
        def valid?
          true
        end
      end
    end
  end
end
