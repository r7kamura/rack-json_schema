module Rack
  class Spec
    module Validators
      class IntegerValidator
        def initialize(key)
          @key = key
        end

        def validate!(env)
          request = Rack::Request.new(env)
          value = request.params[@key]
          if value && value =~ /\A-?\d+\z/
            raise ValidationError, "Expected #@key to be integer, but in fact #{value.inspect}"
          end
        end
      end
    end
  end
end
