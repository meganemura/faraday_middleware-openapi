# frozen_string_literal: true

require "faraday"
require "yaml"
require "openapi_parser"
require "active_support/core_ext/hash/keys"
require "active_support/core_ext/hash/deep_transform_values"
require_relative "openapi/request_validator"
require_relative "openapi/version"

module FaradayMiddleware
  module OpenAPI
    class Error < StandardError; end
  end
end
