require "spec_helper"

describe Rack::Spec::Mock do
  include Rack::Test::Methods

  let(:app) do
    local_schema = schema
    Rack::Builder.app do
      use Rack::Spec::ErrorHandler
      use Rack::Spec::Mock, schema: local_schema
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
    context "with list API" do
      let(:verb) do
        :get
      end

      let(:path) do
        "/apps"
      end

      it "returns Array dummy response" do
        should == 200
        response.body.should be_json_as(
          [
            {
              id: schema["definitions"]["app"]["definitions"]["id"]["example"],
              name: schema["definitions"]["app"]["definitions"]["name"]["example"],
            }
          ]
        )
      end
    end

    context "with info API" do
      let(:verb) do
        :get
      end

      let(:path) do
        "/apps/1"
      end

      it "returns dummy response" do
        should == 200
        response.body.should be_json_as(
          {
            id: schema["definitions"]["app"]["definitions"]["id"]["example"],
            name: schema["definitions"]["app"]["definitions"]["name"]["example"],
          }
        )
      end
    end

    context "with POST API" do
      let(:verb) do
        :post
      end

      let(:path) do
        "/apps"
      end

      it "returns dummy response with 201" do
        should == 201
      end
    end

    context "without example" do
      before do
        schema["definitions"]["recipe"]["definitions"]["id"].delete("example")
      end

      let(:verb) do
        :get
      end

      let(:path) do
        "/recipes"
      end

      it "returns example_not_found error" do
        should == 500
        response.body.should be_json_as(
          id: "example_not_found",
          message: "No example found for #/definitions/recipe/id",
        )
      end
    end
  end
end
