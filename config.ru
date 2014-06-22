require "rack/json_schema"

path = File.expand_path("../spec/fixtures/schema.json", __FILE__)
str = File.read(path)
schema = JSON.parse(str)

use Rack::JsonSchema::Docs, schema: schema
use Rack::JsonSchema::SchemaProvider, schema: schema
use Rack::JsonSchema::ErrorHandler
use Rack::JsonSchema::RequestValidation, schema: schema
use Rack::JsonSchema::ResponseValidation, schema: schema
use Rack::JsonSchema::Mock, schema: schema
run ->(env) { [404, {}, ["Not found"]] }
