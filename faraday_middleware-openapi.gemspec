# frozen_string_literal: true

require_relative "lib/faraday_middleware/openapi/version"

Gem::Specification.new do |spec|
  spec.name          = "faraday_middleware-openapi"
  spec.version       = FaradayMiddleware::OpenAPI::VERSION
  spec.authors       = ["meganemura"]
  spec.email         = ["meganemura@users.noreply.github.com"]

  spec.summary       = "Faraday middleware for validation by OpenAPI"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/meganemura/faraday_middleware-openapi"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/meganemura/faraday_middleware-openapi/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", ">= 1.0"
  spec.add_dependency "openapi_parser"
  spec.add_dependency "activesupport"
end
