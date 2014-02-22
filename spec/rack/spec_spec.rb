require "spec_helper"
require "active_support/core_ext/string/strip"
require "rack/test"
require "yaml"

describe Rack::Spec do
  include Rack::Test::Methods

  let(:app) do
    Rack::Builder.app do
      use Rack::Spec, spec: YAML.load(<<-EOS.strip_heredoc)
        meta:
          baseUri: http://api.example.com/
        endpoints:
          /recipes:
            GET:
              queryParameters:
                page:
                  type: integer
                  minimum: 1
                  maximum: 10
                private:
                  type: boolean
                rank:
                  type: float
                time:
                  type: iso8601
      EOS
      run ->(env) do
        [200, {}, ["OK"]]
      end
    end
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
      before do
        params[:page] = 5
        params[:private] = "false"
        params[:rank] = 2.0
        params[:time] = "2000-01-01T00:00:00+00:00"
      end
      it { should == 200 }
    end

    context "with query parameter invalid on integer" do
      before do
        params[:page] = "1.0"
      end
      it { should == 400 }
    end

    context "with query parameter invalid on float" do
      before do
        params[:rank] = "x"
      end
      it { should == 400 }
    end

    context "with query parameter invalid on boolean" do
      before do
        params[:private] = 1
      end
      it { should == 400 }
    end

    context "with query parameter invalid on iso8601" do
      before do
        params[:time] = "2000-01-01 00:00:00 +0000"
      end
      it { should == 400 }
    end

    context "with query parameter invalid on minimum" do
      before do
        params[:page] = 0
      end
      it { should == 400 }
    end

    context "with query parameter invalid on maximum" do
      before do
        params[:page] = 11
      end
      it { should == 400 }
    end
  end
end
