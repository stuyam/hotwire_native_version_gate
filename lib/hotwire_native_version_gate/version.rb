# frozen_string_literal: true

module HotwireNativeVersionGate
  VERSION = File.read(
    File.expand_path('../../VERSION', __dir__)
  ).strip.freeze
end
