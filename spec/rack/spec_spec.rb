require "spec_helper"
require "active_support/core_ext/string/strip"
require "rack/test"
require "yaml"

describe Rack::Spec do
  include Rack::Test::Methods

  let(:app) do
    described_class.new(original_app, source: source)
  end

  let(:original_app) do
    ->(env) do
      [200, {}, ["OK"]]
    end
  end

  let(:source) do
    YAML.load(yaml)
  end

  let(:yaml) do
    <<-EOS.strip_heredoc
      ---
      meta:
        baseUri: http://api.example.com/

      endpoints:
        /recipes:
          GET:
            queryParameters:
              page:
                type: integer
                minimum: 1
    EOS
  end

  let(:path) do
    "/recipes"
  end

  let(:params) do
    {}
  end

  let(:env) do
    {}
  end

  describe "#call" do
    context "with invalid type query parameter" do
      before do
        params[:page] = "x"
      end

      it "returns 400 with JSON error message" do
        get path, params, env
        last_response.status.should == 400
        last_response.header["Content-Type"].should == "application/json"
        last_response.body.should be_json_as(message: String)
      end
    end
  end
end
