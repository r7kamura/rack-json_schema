require "spec_helper"

describe Rack::JsonSchema do
  include Rack::Test::Methods

  let(:app) do
    local_schema = schema
    local_strict = strict
    local_response_body = response_body
    local_response_headers = response_headers
    Rack::Builder.app do
      use Rack::JsonSchema::ErrorHandler
      use Rack::JsonSchema::RequestValidation, schema: local_schema, strict: local_strict
      use Rack::JsonSchema::ResponseValidation, schema: local_schema
      run ->(env) do
        [200, local_response_headers, [local_response_body]]
      end
    end
  end

  let(:response_headers) do
    { "Content-Type" => "application/json" }
  end

  let(:response_body) do
    if verb == :get
      [response_data].to_json
    else
      response_data.to_json
    end
  end

  let(:response_data) do
    {
      id: "01234567-89ab-cdef-0123-456789abcdef",
      name: "example",
    }
  end

  let(:schema) do
    str = File.read(schema_path)
    JSON.parse(str)
  end

  let(:schema_path) do
    File.expand_path("../../fixtures/schema.json", __FILE__)
  end

  let(:strict) do
    true
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

  shared_context "with valid POST request", :with_valid_post_request do
    before do
      env["CONTENT_TYPE"] = "application/json"
    end

    let(:verb) do
      :post
    end

    let(:path) do
      "/apps"
    end

    let(:params) do
      { name: "abcd" }.to_json
    end
  end

  describe "RequestValidation" do
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

      it "returns link_not_found error" do
        should == 404
        response.body.should be_json_as(
          id: "link_not_found",
          message: "Could not find the link definition for request path #{path}.",
        )
      end
    end

    context "with request body & invalid content type", :with_valid_post_request do
      before do
        env["CONTENT_TYPE"] = "text/plain"
      end

      it "returns invalid_content_type error" do
        should == 400
        response.body.should be_json_as(
          id: "invalid_content_type",
          message: "Invalid content type",
        )
      end

      context "when strict is false" do
        let(:strict) do
          false
        end

        it "skips content_type check" do
          should == 200
        end
      end
    end

    context "with valid request property", :with_valid_post_request do
      it { should == 200 }
    end

    context "with suffixed content type", :with_valid_post_request do
      before do
        env["CONTENT_TYPE"] = "application/json; charset=utf8"
      end
      it { should == 200 }
    end

    context "with invalid request property", :with_valid_post_request do
      let(:params) do
        { name: "ab" }.to_json
      end

      it "returns invalid_parameter error" do
        should == 400
        response.body.should be_json_as(
          id: "invalid_parameter",
          message: String,
        )
      end
    end

    context "with non-json content type with non-json request body", :with_valid_post_request do

      let(:path) do
        "/apps/#{app_id}/files"
      end

      let(:app_id) do
        1
      end

      let(:params) do
        { file: Rack::Test::UploadedFile.new(schema_path, 'text/x-yaml') }
      end

      before do
        env["CONTENT_TYPE"] = "multipart/form-data"
      end

      it { should == 200 }
    end

    context "with malformed JSON request body", :with_valid_post_request do
      let(:params) do
        "malformed"
      end

      it "returns invalid_parameter error" do
        should == 400
        response.body.should be_json_as(
          id: "invalid_json",
          message: "Request body wasn't valid JSON",
        )
      end
    end
  end

  describe "ResponseValidation" do
    let(:verb) do
      :get
    end

    let(:path) do
      "/apps"
    end

    let(:body) do
      {
        foo: "bar",
      }.to_json
    end

    context "with response content type except for JSON" do
      let(:response_headers) do
        { "Content-Type" => "text/plain" }
      end

      context "when mediaType is specified as text/plain" do
        let(:path) do
          "/apps/#{response_data[:id]}/text"
        end

        it { should == 200 }
      end

      context "when mediaType is not specified" do
        it "returns invalid_response_content_type error" do
          should == 500
          response.body.should be_json_as(
            id: "invalid_response_content_type",
            message: "Response Content-Type wasn't for JSON",
          )
        end
      end
    end

    context "without required field" do
      before do
        response_data.delete(:id)
      end

      it "returns invalid_response_type error" do
        should == 500
        response.body.should be_json_as(
          id: "invalid_response_type",
          message: String,
        )
      end
    end

    context "with invalid pattern string field" do
      before do
        response_data[:id] = "123"
      end

      it "returns invalid_response_type error" do
        should == 500
        response.body.should be_json_as(
          id: "invalid_response_type",
          message: String,
        )
      end
    end

    context "with response content type for JSON" do
      let(:response_headers) do
        { "Content-Type" => "application/json; charset=utf-8" }
      end

      it { should == 200 }
    end
  end
end
