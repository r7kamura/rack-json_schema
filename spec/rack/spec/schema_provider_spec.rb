require "spec_helper"

describe Rack::JsonSchema::SchemaProvider do
  include Rack::Test::Methods

  let(:app) do
    local_schema_url_path = schema_url_path
    local_schema = schema
    Rack::Builder.app do
      use Rack::JsonSchema::SchemaProvider, path: local_schema_url_path, schema: local_schema
      run ->(env) do
        [
          200,
          {},
          ["dummy"],
        ]
      end
    end
  end

  let(:schema) do
    str = File.read(schema_path)
    JSON.parse(str)
  end

  let(:schema_path) do
    File.expand_path("../../../fixtures/schema.json", __FILE__)
  end

  let(:schema_url_path) do
    nil
  end

  let(:response) do
    last_response
  end

  let(:env) do
    {}
  end

  let(:params) do
    {}
  end

  subject do
    send(verb, path, params, env)
    response.status
  end

  describe "#call" do
    let(:verb) do
      :get
    end

    context "without :path option" do
      let(:path) do
        "/schema"
      end

      it "returns JSON Schema to request to GET /schema" do
        should == 200
        expect(response.body).to include("app")
      end
    end

    context "with :path option" do
      let(:schema_url_path) do
        "/json_schema"
      end

      let(:path) do
        "/json_schema"
      end

      it "responds to specified path" do
        should == 200
        expect(response.body).not_to eq("dummy")
      end
    end

    context "without targeted request" do
      let(:path) do
        "/apps"
      end

      it "delegates request to inner app" do
        should == 200
        expect(response.body).to eq("dummy")
      end
    end
  end
end
