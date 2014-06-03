require "spec_helper"

describe Rack::Spec::RequestValidation do
  include Rack::Test::Methods

  let(:app) do
    data = schema
    Rack::Builder.app do
      use Rack::Spec::RequestValidation, schema: data
      run ->(env) do
        [200, {}, ["OK"]]
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

  describe "GET /recipes" do
    let(:verb) do
      :get
    end

    let(:path) do
      "/recipes"
    end

    it { should == 200 }
  end
end
