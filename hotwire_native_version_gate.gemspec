# frozen_string_literal: true

require_relative "lib/hotwire_native_version_gate/version"

Gem::Specification.new do |spec|
  spec.name = "hotwire_native_version_gate"
  spec.version = HotwireNativeVersionGate::VERSION
  spec.authors = ["Stuart Yamartino"]
  spec.email = ["stu@stuyam.com"]

  spec.summary = "A gem for version gating Hotwire Native apps in Rails"
  spec.description = "HotwireNativeVersionGate provides functionality to version gate Hotwire Native apps in Rails."
  spec.homepage = "https://github.com/stuyam/hotwire_native_version_gate"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir['lib/**/*'] + ['VERSION']

  spec.add_dependency "activesupport", ">= 6.0.0"
end
