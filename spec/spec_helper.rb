require "bundler/setup"
require "hotwire_native_version_gate"

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
