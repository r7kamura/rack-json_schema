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

  describe "#call" do
    let(:verb) do
      :get
    end

    let(:path) do
      "/apps"
    end

    context "with defined route" do
      it { should == 200 }
    end

    context "with undefined route" do
      let(:path) do
        "/undefined"
      end

      it "raises Rack::Spec::RequestValidation::LinkNotFound" do
        expect { subject }.to raise_error(Rack::Spec::RequestValidation::LinkNotFound)
      end
    end
  end
end
