require "spec_helper"
require "rack/test"
require "yaml"

describe Rack::Spec do
  include Rack::Test::Methods

  let(:app) do
    Rack::Builder.app do
      use Rack::Spec, spec: YAML.load_file("spec/fixtures/spec.yml")
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
    send verb, path, params, env
    last_response.status
  end

  describe "GET" do
    let(:verb) do
      :get
    end

    context "with valid request" do
      before do
        params[:page] = 5
        params[:private] = "false"
        params[:rank] = 2.0
        params[:time] = "2000-01-01T00:00:00+00:00"
        params[:kind] = "mono"
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

    context "with query parameter invalid on only" do
      before do
        params[:kind] = "tetra"
      end
      it { should == 400 }
    end
  end

  describe "POST" do
    before do
      params[:title] = "test"
    end

    let(:verb) do
      :post
    end

    context "with valid request" do
      it { should == 200 }
    end

    context "with request body parameter invalid on minimumLength" do
      before do
        params[:title] = "te"
      end
      it { should == 400 }
    end

    context "with request body parameter invalid on maximumLength" do
      before do
        params[:title] = "toooooolong"
      end
      it { should == 400 }
    end

    context "with request body parameter invalid on required" do
      before do
        params.delete(:title)
      end
      it { should == 400 }
    end
  end
end
