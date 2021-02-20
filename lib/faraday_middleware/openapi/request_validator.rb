# frozen_string_literal: true

module FaradayMiddleware
  module OpenAPI
    class RequestValidator < Faraday::Middleware
      def on_request(env)
        content_type = env.request_headers['Content-Type']
        operation = request_operation(env.method, env.url.path)
        operation.validate_request_parameter(env.params || {}, {})
        request_body = case content_type
                       when 'application/json' # Use regexp
                         begin
                           JSON.parse(env.request_body)
                         rescue
                           nil
                         end
                       end
        operation.validate_request_body(content_type, request_body)
      rescue OpenAPIParser::NotExistRequiredKey, OpenAPIParser::NotNullError => e
        raise ::FaradayMiddleware::OpenAPI::Error.new(e.message)
      end

      def initialize(app, options = {})
        super(app)
        schema_path = options.fetch(:schema_path)
        @schema_path = schema_path
      end

      private

      attr_reader :schema_path

      def openapi_parser
        @openapi_parser ||= OpenAPIParser.parse(YAML.load_file(schema_path), coerce_value: false)
      end

      def request_operation(method, path)
        openapi_parser.request_operation(method, path)
      end
    end
  end
end

Faraday::Request.register_middleware openapi: -> { ::FaradayMiddleware::OpenAPI::RequestValidator }