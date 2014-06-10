lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rack/json_schema/version"

Gem::Specification.new do |spec|
  spec.name          = "rack-json_schema"
  spec.version       = Rack::JsonSchema::VERSION
  spec.authors       = ["Ryo Nakamura"]
  spec.email         = ["r7kamura@gmail.com"]
  spec.summary       = "JSON Schema based Rack middlewares"

  spec.homepage      = "https://github.com/r7kamura/rack-json_schema"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "jdoc", ">= 0.0.3"
  spec.add_dependency "json_schema"
  spec.add_dependency "rack"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "2.14.1"
  spec.add_development_dependency "rspec-console"
  spec.add_development_dependency "rspec-json_matcher"
end
