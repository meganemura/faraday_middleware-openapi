# frozen_string_literal: true

module FaradayMiddleware
  module OpenAPI
    class RequestValidator < Faraday::Middleware
      def on_request(env)
        validate(env)
      end

      def initialize(app, options = {})
        super(app)
        schema_path = options.fetch(:schema_path)
        @schema_path = schema_path
      end

      private

      attr_reader :schema_path

      def validate(env)
        request_operation = RequestOperation.new(env: env, schema_path: schema_path)
        request_operation.validate_request_parameter
        request_operation.validate_request_body
      end

      class RequestOperation
        def initialize(env:, schema_path:)
          @env = env
          @schema_path = schema_path
        end

        def validate_request_parameter
          request_operation.validate_request_parameter(env.params || {}, {})
        rescue OpenAPIParser::OpenAPIError => e
          raise ::FaradayMiddleware::OpenAPI::Error.new(e.message)
        end

        def validate_request_body
          request_operation.validate_request_body(content_type, request_body)
        rescue OpenAPIParser::OpenAPIError => e
          raise ::FaradayMiddleware::OpenAPI::Error.new(e.message)
        end

        private

        attr_reader :env
        attr_reader :schema_path

        def content_type
          env.request_headers['Content-Type']
        end

        def request_body
          case content_type
          when 'application/json' # Use regexp
            begin
              JSON.parse(env.request_body)
            rescue
              nil
            end
          when "multipart/form-data"
            validatablize_multipart_form_data(env.request_body)
          end
        end

        def validatablize_multipart_form_data(request_body)
          body = request_body.deep_stringify_keys
          body.deep_transform_values do |value|
            case value
            when Faraday::FilePart
              value.yield_self {|x| v = x.read; x.rewind; v }
            else
              value
            end
          end
        end

        def request_operation
          openapi_parser.request_operation(env.method, env.url.path)
        end

        def openapi_parser
          @openapi_parser ||= OpenAPIParser.parse(YAML.load_file(schema_path), coerce_value: false)
        end
      end
    end
  end
end

Faraday::Request.register_middleware openapi: -> { ::FaradayMiddleware::OpenAPI::RequestValidator }
