# Rack::Spec
[JSON Schema](http://json-schema.org/) based Rack middlewares.

## Usage
```ruby
use Rack::Spec::ErrorHandler
use Rack::Spec::RequestValidation, schema: JSON.parse(File.read("schema.json")))
```

### Example
```sh
$ curl http://localhost:9292/recipes
{"id":"link_not_found","message":"Not found"}

$ curl http://localhost:9292/apps -H "Content-Type: application/json" -d "invalid-json"
{"id":"invalid_json","message":"Request body wasn't valid JSON"}

$ curl http://localhost:9292/apps -H "Content-Type: text/plain" -d "{}"
{"id":"invalid_content_type","message":"Invalid content type"}

$ curl http://localhost:9292/apps -H "Content-Type: application/json" -d '{"name":"x"}'
{"id":"invalid_parameter","message":"Invalid request.\n#/name: failed schema #/definitions/app/links/0/schema/properties/name: Expected string to match pattern \"/^[a-z][a-z0-9-]{3,50}$/\", value was: x."}
```

### Rack::Spec::RequestValidation
Validates request and raises following errors:

* Rack::Spec::RequestValidation::InvalidContentType
* Rack::Spec::RequestValidation::InvalidJson
* Rack::Spec::RequestValidation::InvalidParameter
* Rack::Spec::RequestValidation::LinkNotFound

### Rack::Spec::ErrorHandler
Returns appropriate error response including following properties when RequestValidation raises error.

* id: Error type identifier (e.g. `link_not_found`, `invalid_content_type`)
* message: Human readable message (e.g. `Not Found`, `Invalid Content-Type`)

### Errors
```
StandardError
|
Rack::Spec::Error
|
Rack::Spec::RequestValidation::Error
|
|--Rack::Spec::RequestValidation::InvalidContentType
|
|--Rack::Spec::RequestValidation::InvalidJson
|
|--Rack::Spec::RequestValidation::InvalidParameter
|
`--Rack::Spec::RequestValidation::LinkNotFound
```
