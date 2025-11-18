# frozen_string_literal: true

require "active_support/concern"
require_relative "hotwire_native_version_gate/version"
require_relative "hotwire_native_version_gate/version_gate"
require_relative "hotwire_native_version_gate/concern"

module HotwireNativeVersionGate
  class Error < StandardError; end
  class InvalidVersionGateError < StandardError; end
end
