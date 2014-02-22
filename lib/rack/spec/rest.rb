require "active_support/core_ext/object/try"
require "active_support/core_ext/string/inflections"

module Rack
  class Spec
    class Rest
      def initialize(options = {})
        @options = options
      end

      def call(env)
        Proxy.new(spec, env).call
      end

      private

      def spec
        Spec.new(@options[:spec])
      end

      class Proxy
        def initialize(spec, env)
          @spec = spec
          @env = env
        end

        def call
          if endpoint
            response = handler_class.send(handler_method_name, *handler_args)
            [
              response.try(:status) || default_status,
              default_header.merge(response.try(:header) || {}),
              [(response.try(:body) || response).to_json]
            ]
          else
            raise Exceptions::NoEndpointError, self
          end
        end

        private

        def endpoint
          @endpoint ||= @spec.reach("endpoints", path, request_method)
        end

        def handler_args
          if id
            [id, params]
          else
            [params]
          end
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
          case request_method
          when "GET"
            if id
              :show
            else
              :index
            end
          when "POST"
            :create
          when "PUT"
            :update
          when "DELETE"
            :destroy
          end
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
          request.params
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
