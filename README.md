# Rack::Spec
Define specifications of your Rack application.

## Installation
```
gem install rack-spec
```

## Rack::Spec::Validation
Rack::Spec::Validation is a rack-middleware and works as a validation layer for your rack-application.
It loads spec definition (= a pure Hash object in specific format) to validate each request.
If the request is not valid on your definition, it will raise Rack::Spec::Exceptions::ValidationError.
Rack::Spec::ExceptionHandler is a utility rack-middleware to rescue validation error and return 400.

```ruby
require "rack"
require "rack/spec"
require "yaml"

use Rack::Spec::ExceptionHandler
use Rack::Spec::Validation, spec: YAML.load_file("spec.yml")

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
Replace Rack::Spec::ExceptionHandler to customize error behavior.

```ruby
use MyExceptionHandler # Rack::Spec::ValidationError must be rescued
use Rack::Spec::Validation, spec: YAML.load_file("spec.yml")
```

## Rack::Spec::Restful
Rack::Spec::Restful provides strongly conventional RESTful APIs as a rack-middleware.
It recognizes a preferred instruction from the request method & path, then tries to call it.

| verb   | path          | instruction                |
| ----   | ----          | ----                       |
| GET    | /recipes/     | Recipe.index(id)           |
| GET    | /recipes/{id} | Recipe.show(id, params)    |
| POST   | /recipes/     | Recipe.create(id)          |
| PUT    | /recipes/{id} | Recipe.update(id, params)  |
| DELETE | /recipes/{id} | Recipe.destroy(id, params) |

```ruby
class Recipe
  def self.index(params)
    order(params[:order]).page(params[:page])
  end

  def self.show(id, params)
    find(id)
  end
end
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
