module Rack
  class Spec
    module Exceptions
      class NoEndpointError < Base
        def initialize(proxy)
          @proxy = proxy
        end
      end
    end
  end
end
