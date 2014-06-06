ENV["RACK_ENV"] ||= "none"
require "rack/spec"
require "pathname"

pathname = Pathname.new("spec/fixtures/schema.json")
schema = JSON.parse(pathname.read)
use Rack::Spec::ErrorHandler
use Rack::Spec::Mock, schema: schema

run ->(env) do
  [
    200,
    {},
    ["It works!"],
  ]
end
