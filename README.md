# Rack::Spec
Define specifications of your Rack application.

Rack::Spec is a rack-middleware and works as a validation layer for your rack-application.
It loads spec definition (= a pure Hash object in specific format) to validate each request.
If the request is not valid on your definition,
it returns 400 response with applicaiton/json body by default.

## Installation
```
gem install rack-spec
```

## Usage
```ruby
require "rack"
require "rack/spec"
require "yaml"

use Rack::Spec, spec: YAML.load_file("spec.yml")

run ->(env) do
  [200, {}, ["OK"]]
end
```

```yaml
# spec.yml
meta:
  baseUri: http://api.example.com/

endpoints:
  /recipes:
    GET:
      parameters:
        page:
          type: integer
          minimum: 1
          maximum: 10
        private:
          type: boolean
        rank:
          type: float
        time:
          type: iso8601
        kind:
          type: string
          only:
            - mono
            - di
            - tri
    POST:
      parameters:
        title:
          type: string
          minimumLength: 3
          maximumLength: 10
          required: true
```

## Custom Validator
Custom validator can be defined by inheriting Rack::Spec::Validators::Base.
The following FwordValidator rejects any parameter starting with "F".
See [lib/rack/spec/validators](https://github.com/r7kamura/rack-spec/tree/master/lib/rack/spec/validators) for more examples.

```ruby
# Example:
#
# parameters:
#   title:
#     fword: false
#
class FwordValidator < Rack::Spec::Validators::Base
  register_as "fword"

  def valid?
    value.nil? || !value.start_with?("F")
  end
end
```

## Exception Handling
The error behavior is customizable because Rack::Request is two-layer structure of
Rack::Spec::ExceptionHandler & Rack::Spec::Validation.
To customize the error behavior,
directly use Rack::Spec::Validation with your favorite exception handler.

```ruby
use MyExceptionHandler # Rack::Spec::ValidationError must be rescued
use Rack::Spec::Validation, spec: YAML.load_file("spec.yml")
```

## Development
```sh
# setup
git clone git@github.com:r7kamura/rack-spec.git
cd rack-spec
bundle install

# testing
bundle exec rspec
```
