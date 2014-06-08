require "spec_helper"

describe Rack::JsonSchema::Docs do
  include Rack::Test::Methods

  let(:app) do
    local_docs_path = docs_path
    local_schema = schema
    Rack::Builder.app do
      use Rack::JsonSchema::Docs, path: local_docs_path, schema: local_schema
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

  let(:docs_path) do
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
        "/docs"
      end

      it "generates API documentation and returns it to request to GET /docs" do
        should == 200
        response.body.should include("Example API")
      end
    end

    context "with :path option" do
      let(:docs_path) do
        "/api_document"
      end

      let(:path) do
        "/api_document"
      end

      it "responds to specified path" do
        should == 200
        response.body.should_not == "dummy"
      end
    end

    context "without targeted request" do
      let(:path) do
        "/apps"
      end

      it "delegates request to inner app" do
        should == 200
        response.body.should == "dummy"
      end
    end
  end
end
