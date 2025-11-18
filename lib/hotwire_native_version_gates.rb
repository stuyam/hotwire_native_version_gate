# frozen_string_literal: true

require "active_support/concern"
require_relative "hotwire_native_version_gates/version"
require_relative "hotwire_native_version_gates/version_gate"
require_relative "hotwire_native_version_gates/concern"

module HotwireNativeVersionGates
  class Error < StandardError; end
  class InvalidVersionGateError < StandardError; end
end
