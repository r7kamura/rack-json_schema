require "spec_helper"
require "ostruct"

describe Rack::Spec::Rest do
  include Rack::Test::Methods

  before do
    stub_const(
      "Recipe",
      Class.new do
        class << self
          def index(params)
            [
              { name: "test" }
            ]
          end
        end
      end
    )
  end

  let(:app) do
    Rack::Spec::Rest.new(spec: spec)
  end

  let(:spec) do
    YAML.load_file("spec/fixtures/spec.yml")
  end

  it "defines REST API on convention" do
    get "/recipes"
    last_response.status.should == 200
    last_response.header["Content-Type"].should == "application/json"
    last_response.body.should be_json_as(
      [
        { name: "test" },
      ]
    )
  end
end
