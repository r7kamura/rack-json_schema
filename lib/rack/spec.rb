require "rack/builder"
require "rack/spec/exception_handler"
require "rack/spec/spec"
require "rack/spec/validation"
require "rack/spec/validation_error"
require "rack/spec/validators/base"
require "rack/spec/validators/null_validator"
require "rack/spec/validator_factory"
require "rack/spec/validators/maximum_length_validator"
require "rack/spec/validators/maximum_validator"
require "rack/spec/validators/minimum_length_validator"
require "rack/spec/validators/minimum_validator"
require "rack/spec/validators/null_validator"
require "rack/spec/validators/only_validator"
require "rack/spec/validators/parameters_validator"
require "rack/spec/validators/required_validator"
require "rack/spec/validators/type_validator"
require "rack/spec/version"

module Rack
  class Spec
    def initialize(app, options)
      @app = Rack::Builder.app do
        use Rack::Spec::ExceptionHandler
        use Rack::Spec::Validation, options
        run app
      end
    end

    def call(env)
      @app.call(env)
    end
  end
end
