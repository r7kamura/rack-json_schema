module Rack
  module JsonSchema
    class Docs
      DEFAULT_PATH = "/docs"

      # Behaves as a rack-middleware
      # @param app [Object] Rack application
      # @param path [String, nil] URL path to return document (default: /docs)
      # @param schema [Hash] Schema object written in JSON schema format
      def initialize(app, path: nil, schema: nil)
        @app = app
        @path = path
        @markdown = Jdoc::Generator.call(schema)
        @html = Jdoc::Generator.call(schema, html: true)
      end

      # Returns rendered document for document request
      # @param env [Hash] Rack env
      def call(env)
        DocumentGenerator.call(
          app: @app,
          env: env,
          html: @html,
          markdown: @markdown,
          path: path,
        )
      end

      private

      # @return [String] Path to return document
      def path
        @path || DEFAULT_PATH
      end

      class DocumentGenerator
        def self.call(*args)
          new(*args).call
        end

        # @param app [Object] Rack application
        # @param env [Hash] Rack env
        # @param html [String] HTML rendered docs
        # @param markdown [String] Markdown rendered docs
        # @param path [String] Route for docs
        def initialize(app: nil, env: nil, html: nil, markdown: nil, path: nil)
          @app = app
          @env = env
          @html = html
          @markdown = markdown
          @path = path
        end

        # Generates suited response body from given env & document to docs request
        # @return [Array] Rack response
        def call
          if has_docs_request?
            if has_markdown_request?
              markdown_response
            else
              html_response
            end
          else
            delegate
          end
        end

        private

        # Delegates request to given rack app
        def delegate
          @app.call(@env)
        end

        # @return [true, false] True if docs are requested
        def has_docs_request?
          request_method == "GET" && path_without_extname == @path
        end

        # @return [true, false] True if raw markdown content are requested
        def has_markdown_request?
          extname == ".md"
        end

        # @return [String] Extension name of request path
        # @example
        #   extname #=> ".md"
        def extname
          ::File.extname(path)
        end

        # @return [String] Request path
        def path
          @env["PATH_INFO"]
        end

        # @return [String]
        def request_method
          @env["REQUEST_METHOD"]
        end

        # @return [String]
        def path_without_extname
          path.gsub(/\..+\z/, "")
        end

        # @return [Array] Rack response of raw markdown text
        def markdown_response
          [
            200,
            { "Content-Type" => "text/plain; charset=utf-8" },
            [@markdown],
          ]
        end

        # @return [Array] Rack response of human readable HTML document, rendered from given document
        def html_response
          [
            200,
            { "Content-Type" => "text/html; charset=utf-8" },
            [@html],
          ]
        end
      end
    end
  end
end
