# frozen_string_literal: true

RSpec.describe FaradayMiddleware::OpenAPI::RequestValidator do
  let(:middleware) { described_class.new(->(env) { env }, schema_path: File.join(__dir__, "blog.yaml")) }

  describe "parameters" do
    pending
  end

  describe "request body" do
    describe "when the content type is application/json" do
      def process(method, url, body, content_type = nil)
        env = { method: method, url: url, body: body, request_headers: Faraday::Utils::Headers.new }
        env[:request_headers]['content-type'] = content_type if content_type
        middleware.on_request(Faraday::Env.from(env))
      end

      let(:method) { :post }
      let(:url) { URI.parse("https://example.com/articles") }

      context "when the request body is valid" do
        it "does not raise error" do
          result = process(method, url, JSON.dump({title: "My first blog"}), 'application/json')
          expect(result[:body]).to be_nil
        end
      end

      context "when the request body is invalid" do
        it "raises error" do
          expect { process(method, url, nil, 'application/json') }.to raise_error(FaradayMiddleware::OpenAPI::Error)
        end
      end
    end

    describe "when the content type is multipart/form-data" do
      def process_x(method, url, params)
        env = { method: method, url: url, request_body: request_body, request_headers: Faraday::Utils::Headers.new }
        env[:request_headers]['content-type'] = "multipart/form-data"
        middleware.on_request(Faraday::Env.from(env))
      end

      let(:method) { :post }
      let(:url) { URI.parse("https://example.com/attachments") }
      context "when the request body is valid" do
        let(:request_body) do
          {
            file: Faraday::FilePart.new(StringIO.new("A"), 'text/plain'),
            fileName: "A.txt",
          }
        end

        it "does not raise error" do
          result = process_x(method, url, request_body)
          expect(result[:body]).to be_nil
        end
      end

      context "when the request body is invalid" do
        let(:request_body) do
          {
            file: Faraday::FilePart.new(StringIO.new("A"), 'text/plain'),
            # fileName: 1, # (required)
          }
        end

        it "raises error" do
          expect { process_x(method, url, request_body) }.to raise_error(FaradayMiddleware::OpenAPI::Error)
        end
      end
    end
  end
end
