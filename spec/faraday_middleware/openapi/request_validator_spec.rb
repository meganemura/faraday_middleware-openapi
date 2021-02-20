# frozen_string_literal: true

RSpec.describe FaradayMiddleware::OpenAPI::RequestValidator do
  let(:middleware) { described_class.new(->(env) { env }, schema_path: File.join(__dir__, "blog.yaml")) }

  def process(method, url, body, content_type = nil)
    env = { method: method, url: url, body: body, request_headers: Faraday::Utils::Headers.new }
    env[:request_headers]['content-type'] = content_type if content_type
    middleware.on_request(Faraday::Env.from(env))
  end

  describe "parameters" do
    pending
  end

  describe "request body" do
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
end
