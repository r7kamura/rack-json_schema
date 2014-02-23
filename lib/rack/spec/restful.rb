require "active_support/core_ext/object/try"
require "active_support/core_ext/string/inflections"

module Rack
  class Spec
    class Restful
      def initialize(app, options = {})
        @app = app
        @options = options
      end

      def call(env)
        Proxy.new(@app, spec, env).call
      end

      private

      def spec
        Spec.new(@options[:spec])
      end

      class Proxy
        def initialize(app, spec, env)
          @app = app
          @spec = spec
          @env = env
        end

        def call
          if endpoint
            response = handler_class.send(handler_method_name, params)
            [
              response.try(:status) || default_status,
              default_header.merge(response.try(:header) || {}),
              [(response.try(:body) || response).to_json]
            ]
          else
            @app.call(@env)
          end
        end

        private

        def endpoint
          @endpoint ||= @spec.find_endpoint(@env)
        end

        def handler_class
          path_segments[1].singularize.camelize.constantize
        end

        def id
          path_segments[2]
        end

        def path_segments
          @path_segments ||= path.split("/")
        end

        def handler_method_name
          request_method.downcase
        end

        def path
          request.path
        end

        def request
          @env["rack-spec.request"] ||= Rack::Request.new(@env)
        end

        def request_method
          @env["REQUEST_METHOD"]
        end

        def params
          request.params.merge(@env["rack-spec.uri_parameters"])
        end

        def default_status
          {
            "GET" => 200,
            "POST" => 201,
            "PUT" => 204,
            "DELETE" => 204,
          }[request_method]
        end

        def default_header
          { "Content-tYpe" => "application/json" }
        end
      end
    end
  end
end
