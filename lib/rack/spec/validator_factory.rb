module Rack
  class Spec
    class ValidatorFactory
      class << self
        def validator_classes
          @validator_classes ||= Hash.new(Validators::NullValidator)
        end

        def register(name, klass)
          validator_classes[name] = klass
        end

        def build(key, type, constraint, env)
          validator_classes[type].new(key, constraint, env)
        end
      end

      register "maximum", Validators::MaximumValidator
      register "maximumLength", Validators::MaximumLengthValidator
      register "minimum", Validators::MinimumValidator
      register "minimumLength", Validators::MinimumLengthValidator
      register "only", Validators::OnlyValidator
      register "type", Validators::TypeValidator
    end
  end
end
