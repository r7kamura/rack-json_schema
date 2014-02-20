# Rack::Spec
Define specifications of your Rack application.

## Installation
```
gem install rack-spec
```

## Usage
```ruby
require "rack"
require "rack/spec"
require "yaml"

use Rack::Spec, spec: YAML.load("spec.yml")

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
      queryParameters:
        page:
          type: integer
```
