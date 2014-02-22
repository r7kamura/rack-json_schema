module Rack
  class Spec
    class ValidatorFactory
      class << self
        def build(key, type, constraint)
          select_class(type, constraint).new(key, constraint)
        end

        private

        def select_class(type, constraint)
          case type
          when "type"
            Validators::TypeValidator
          when "minimum"
            Validators::MinimumValidator
          when "maximum"
            Validators::MaximumValidator
          else
            Validators::NullValidator
          end
        end
      end
    end
  end
end
