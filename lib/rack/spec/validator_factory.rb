module Rack
  class Spec
    class ValidatorFactory
      def self.build(key, type, constraint)
        case type
        when "type"
          TypeValidator.new(key, constraint)
        else
          NullValidator.new
        end
      end
    end
  end
end
