module Rack
  class Spec
    class ValidatorFactory
      class << self
        def build(key, type, constraint)
          select_class(type, constraint).new(key, constraint)
        end

        private

        def select_class(type, constraint)
          case
          when type == "type" && constraint == "integer"
            Validators::IntegerValidator
          when type == "minimum"
            Validators::MinimumValidator
          when type == "maximum"
            Validators::MaximumValidator
          else
            Validators::NullValidator
          end
        end
      end
    end
  end
end
