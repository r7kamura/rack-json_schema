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

  subject do
    get path, params, env
    last_response.status
  end

  describe "#call" do
    context "with valid request" do
      it { should == 200 }
    end

    context "with query parameter invalid to integer constraint" do
      before do
        params[:page] = "x"
      end
      it { should == 400 }
    end

    context "with invalid minimum query parameter" do
      before do
        params[:page] = "0"
      end
      it { should == 400 }
    end
  end
end
