# Rack::Spec
Generate API server from [JSON Schema](http://json-schema.org/).

## RequestValidation
* Raise `Rack::Spec::RequestValidation::LinkNotFound` when given request is not defined in schema
* Raise `Rack::Spec::RequestValidation::InvalidContentType` for invalid content type

```ruby
use Rack::Spec::RequestValidation, schema: JSON.parse("schema.json")
```
