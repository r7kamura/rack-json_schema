require "spec_helper"

describe Rack::Spec do
  include Rack::Test::Methods

  before do
    stub_const(
      "Recipe",
      Class.new do
        class << self
          def get(params)
            if params["id"]
              { name: "test#{params["id"]}"}
            else
              [
                { name: "test" }
              ]
            end
          end

          def post(params)
            { name: "test" }
          end

          def put(params)
          end

          def delete(params)
          end
        end
      end
    )
  end

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

  let(:response) do
    last_response
  end

  subject do
    send verb, path, params, env
    last_response.status
  end

  describe "Validation on GET" do
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

  describe "Validation on POST" do
    before do
      params[:title] = "test"
    end

    let(:verb) do
      :post
    end

    context "with valid request" do
      it { should == 201 }
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

  describe "Restful" do
    context "with GET /recipes" do
      it "calls Recipe.index(params)" do
        get "/recipes"
        response.status.should == 200
        response.body.should be_json_as(
          [
            { name: "test" },
          ]
        )
      end
    end

    context "with GET /recipes/{id}" do
      it "calls Recipe.get(params)" do
        get "/recipes/1"
        response.status.should == 200
        response.body.should be_json_as(name: "test1")
      end
    end

    context "with POST /recipes" do
      before do
        params[:title] = "test"
      end

      it "calls Recipe.post(params)" do
        post "/recipes", params
        response.status.should == 201
        response.body.should be_json_as(name: "test")
      end
    end

    context "with PUT /recipes/{id}" do
      it "calls Recipe.put(params)" do
        put "/recipes/1"
        response.status.should == 204
      end
    end

    context "with DELETE /recipes/{id}" do
      it "calls Recipe.delete(params)" do
        delete "/recipes/1"
        response.status.should == 204
      end
    end

    context "with undefined endpoint" do
      it "falls back to the inner rack app" do
        get "/undefined"
        response.status.should == 200
        response.body.should == "OK"
      end
    end
  end
end
