require "spec_helper"
require "ostruct"

describe Rack::Spec::Restful do
  include Rack::Test::Methods

  before do
    stub_const(
      "Recipe",
      Class.new do
        class << self
          def index(params)
            [
              { name: "test" }
            ]
          end

          def show(id, params)
            { name: "test#{id}" }
          end

          def create(params)
            { name: "test" }
          end

          def update(id, params)
          end

          def destroy(id, params)
          end
        end
      end
    )
  end

  let(:app) do
    Rack::Builder.app do
      use Rack::Spec::Restful, spec: YAML.load_file("spec/fixtures/spec.yml")
      run ->(env) do
        [404, {}, ["Not Found"]]
      end
    end
  end

  let(:response) do
    last_response
  end

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
    it "calls Recipe.show(id, params)" do
      get "/recipes/1"
      response.status.should == 200
      response.body.should be_json_as(name: "test1")
    end
  end

  context "with POST /recipes" do
    it "calls Recipe.create(params)" do
      post "/recipes"
      response.status.should == 201
      response.body.should be_json_as(name: "test")
    end
  end

  context "with PUT /recipes/{id}" do
    it "calls Recipe.update(id, params)" do
      put "/recipes/1"
      response.status.should == 204
    end
  end

  context "with DELETE /recipes/{id}" do
    it "calls Recipe.update(id, params)" do
      delete "/recipes/1"
      response.status.should == 204
    end
  end

  context "with undefined endpoint" do
    it "falls back to the inner rack app" do
      get "/undefined"
      response.status.should == 404
      response.body.should == "Not Found"
    end
  end
end
