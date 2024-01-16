# Rack::JsonSchema

[![CI](https://github.com/r7kamura/rack-json_schema/actions/workflows/ci.yml/badge.svg)](https://github.com/r7kamura/rack-json_schema/actions/workflows/ci.yml)

[JSON Schema](http://json-schema.org/) based Rack middlewares.

* [Rack::JsonSchema::RequestValidation](#rackjsonschemarequestvalidation)
* [Rack::JsonSchema::ResponseValidation](#rackjsonschemaresponsevalidation)
* [Rack::JsonSchema::Mock](#rackjsonschemamock)
* [Rack::JsonSchema::ErrorHandler](#rackjsonschemaerrorhandler)
* [Rack::JsonSchema::Docs](#rackjsonschemadocs)
* [Rack::JsonSchema::SchemaProvider](#rackjsonschemaschemaprovider)
* [specup](#specup)

## Usage
```ruby
str = File.read("schema.json")
schema = JSON.parse(str)

use Rack::JsonSchema::Docs, schema: schema
use Rack::JsonSchema::SchemaProvider, schema: schema
use Rack::JsonSchema::ErrorHandler
use Rack::JsonSchema::RequestValidation, schema: schema
use Rack::JsonSchema::ResponseValidation, schema: schema if ENV["RACK_ENV"] == "test"
use Rack::JsonSchema::Mock, schema: schema if ENV["RACK_ENV"] == "mock"
```

### Rack::JsonSchema::RequestValidation
Validates request and raises errors below. The rack will automatically look into the corresponding [hypermedia](http://json-schema.org/latest/json-schema-hypermedia.html#anchor6) definitions.

* Rack::JsonSchema::RequestValidation::InvalidContentType
* Rack::JsonSchema::RequestValidation::InvalidJson
* Rack::JsonSchema::RequestValidation::InvalidParameter
* Rack::JsonSchema::RequestValidation::LinkNotFound

```sh
$ curl http://localhost:8080/users
{
  "id": "link_not_found",
  "message": "Not found"
}

$ curl http://localhost:8080/apps -H "Content-Type: application/json" -d "invalid-json"
{
  "id": "invalid_json",
  "message": "Request body wasn't valid JSON"
}

$ curl http://localhost:8080/apps -H "Content-Type: text/plain" -d "{}"
{
  "id": "invalid_content_type",
  "message": "Invalid content type"
}

$ curl http://localhost:8080/apps -H "Content-Type: application/json" -d '{"name":"x"}'
{
  "id": "invalid_parameter",
  "message": "Invalid request.\n#/name: failed schema #/definitions/app/links/0/schema/properties/name: Expected string to match pattern \"/^[a-z][a-z0-9-]{3,50}$/\", value was: x."
}
```

### Rack::JsonSchema::ResponseValidation
Validates response and raises errors below.

* Rack::JsonSchema::ResponseValidation::InvalidResponseContentType
* Rack::JsonSchema::ResponseValidation::InvalidResponseType

```sh
$ curl http://localhost:8080/apps
{
  "id": "invalid_response_content_type",
  "message": "Response Content-Type wasn't for JSON"
}

$ curl http://localhost:8080/apps
{
  "id": "invalid_response_type",
  "message": "#: failed schema #/definitions/app: Expected data to be of type \"object\"; value was: [\"message\", \"dummy\"]."
}
```

### Rack::JsonSchema::Mock
Generates dummy response from JSON schema.

```sh
$ curl http://localhost:8080/apps
[
  {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "example"
  }
]

$ curl http://localhost:8080/apps/01234567-89ab-cdef-0123-456789abcdef
{
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "example"
}

$ curl http://localhost:8080/apps/1 -d '{"name":"example"}'
{
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "example"
}

$ curl http://localhost:8080/recipes
{
  "id": "example_not_found",
  "message": "No example found for #/definitions/recipe/id"
}
```

### Rack::JsonSchema::ErrorHandler
Returns appropriate error response including following properties when RequestValidation raises error.

* message: Human readable message
* id: Error type identifier listed below
 * example_not_found
 * invalid_content_type
 * invalid_json
 * invalid_parameter
 * invalid_response_content_type
 * invalid_response_type
 * link_not_found

Here is a tree of all possible errors defined in Rack::JsonSchema.

```
StandardError
|
Rack::JsonSchema::Error
|
|--Rack::JsonSchema::Mock::Error
|  |
|  `--Rack::JsonSchema::Mock::ExampleNotFound
|
|--Rack::JsonSchema::RequestValidation::Error
|  |
|  |--Rack::JsonSchema::RequestValidation::InvalidContentType
|  |
|  |--Rack::JsonSchema::RequestValidation::InvalidJson
|  |
|  |--Rack::JsonSchema::RequestValidation::InvalidParameter
|  |
|  `--Rack::JsonSchema::RequestValidation::LinkNotFound
|
`--Rack::JsonSchema::ResponseValidation::Error
   |
   |--Rack::JsonSchema::ResponseValidation::InvalidResponseContentType
   |
   `--Rack::JsonSchema::ResponseValidation::InvalidResponseType
```

### Rack::JsonSchema::Docs
Returns API documentation as text/html (GET /docs) or text/plain (GET /docs.md).

* You can give `path` option to change default path: `GET /docs`
* API documentation is powered by [jdoc](https://github.com/r7kamura/jdoc) gem
* This middleware is also bundled in the `specup` executable command

### Rack::JsonSchema::SchemaProvider
Serves JSON Schema at `GET /schema`.

* You can give `path` option to change default path: `GET /schema`
* This middleware is also bundled in the `specup` executable command

## specup
`specup` executable command is bundled to rackup handy mock API server.
It validates requests,
and returns dummy response,
also returns auto-generated API documentation at `GET /docs`,
and JSON Schema itself at `GET /schema`.

```sh
$ specup schema.json
[2014-06-06 23:01:35] INFO  WEBrick 1.3.1
[2014-06-06 23:01:35] INFO  ruby 2.0.0 (2013-06-27) [x86_64-darwin12.5.0]
[2014-06-06 23:01:35] INFO  WEBrick::HTTPServer#start: pid=24303 port=8080

$ curl :8080/docs
# Example API
* [App](#app)
 * [GET /apps](#get-apps)
 * [POST /apps](#post-apps)
 * [GET /apps/:id](#get-appsid)
 * [PATCH /apps/:id](#patch-appsid)
 * [DELETE /apps/:id](#delete-appsid)
* [Recipe](#recipe)
 * [GET /recipes](#get-recipes)
...

$ curl :8080/schema
HTTP/1.1 200 OK
{
  "$schema": "http://json-schema.org/draft-04/hyper-schema",
  "definitions": {
    "app": {
      "$schema": "http://json-schema.org/draft-04/hyper-schema",
      "description": "An app is a program to be deployed.",
      "id": "schemata/app",
      "title": "App",
      ...
    }
  }
}

$ curl :8080/apps/1
[
  {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "example"
  }
]

$ curl :8080/apps -H "Content-Type: application/json" -d '{"name":1}'
{
  "id": "invalid_parameter",
  "message": "Invalid request.\n#/name: failed schema #/definitions/app/links/0/schema/properties/name: Expected data to be of type \"string\"; value was: 1."
}
```
