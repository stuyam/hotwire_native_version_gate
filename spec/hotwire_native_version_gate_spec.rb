# frozen_string_literal: true

require "spec_helper"

RSpec.describe HotwireNativeVersionGate do
  it "has a version number" do
    expect(HotwireNativeVersionGate::VERSION).not_to be nil
  end

  describe HotwireNativeVersionGate::VersionGate do
    before do
      # Reset state between tests
      HotwireNativeVersionGate::VersionGate.instance_variable_set(:@native_features, {})
      HotwireNativeVersionGate::VersionGate.instance_variable_set(
        :@native_version_regex,
        HotwireNativeVersionGate::VersionGate::DEFAULT_NATIVE_VERSION_REGEX
      )
    end

    describe ".native_version_regex" do
      it "has a default regex" do
        regex = HotwireNativeVersionGate::VersionGate.native_version_regex
        expect(regex).to eq(HotwireNativeVersionGate::VersionGate::DEFAULT_NATIVE_VERSION_REGEX)
      end

      it "can be customized" do
        custom_regex = /MyApp (iOS|Android)\/(\d+\.\d+\.\d+)/
        HotwireNativeVersionGate::VersionGate.native_version_regex = custom_regex
        expect(HotwireNativeVersionGate::VersionGate.native_version_regex).to eq(custom_regex)
      end

      it "raises ArgumentError if set to non-Regexp" do
        expect {
          HotwireNativeVersionGate::VersionGate.native_version_regex = "not a regex"
        }.to raise_error(ArgumentError, "native_version_regex must be a Regexp")
      end
    end

    describe ".native_feature" do
      it "registers a feature with iOS and Android flags" do
        HotwireNativeVersionGate::VersionGate.native_feature(:new_feature, ios: true, android: false)
        features = HotwireNativeVersionGate::VersionGate.native_features
        expect(features[:new_feature]).to eq({ ios: true, android: false })
      end

      it "allows multiple features to be registered" do
        HotwireNativeVersionGate::VersionGate.native_feature(:feature1, ios: true, android: true)
        HotwireNativeVersionGate::VersionGate.native_feature(:feature2, ios: false, android: true)

        features = HotwireNativeVersionGate::VersionGate.native_features
        expect(features[:feature1]).to eq({ ios: true, android: true })
        expect(features[:feature2]).to eq({ ios: false, android: true })
      end

      it "allows version strings as requirements" do
        HotwireNativeVersionGate::VersionGate.native_feature(:versioned_feature, ios: "1.2.0", android: "2.0.0")
        features = HotwireNativeVersionGate::VersionGate.native_features
        expect(features[:versioned_feature]).to eq({ ios: "1.2.0", android: "2.0.0" })
      end
    end

    describe ".feature_enabled?" do
      let(:ios_user_agent) { "Hotwire Native App iOS/1.0.0" }
      let(:android_user_agent) { "Hotwire Native App Android/1.0.0" }
      let(:invalid_user_agent) { "Mozilla/5.0" }

      context "when feature is not registered" do
        it "returns false" do
          result = HotwireNativeVersionGate::VersionGate.feature_enabled?(:unknown_feature, ios_user_agent)
          expect(result).to be false
        end
      end

      context "when user agent doesn't match regex" do
        before do
          HotwireNativeVersionGate::VersionGate.native_feature(:test_feature, ios: true, android: true)
        end

        it "returns false" do
          result = HotwireNativeVersionGate::VersionGate.feature_enabled?(:test_feature, invalid_user_agent)
          expect(result).to be false
        end
      end

      context "with boolean flags" do
        before do
          HotwireNativeVersionGate::VersionGate.native_feature(:enabled_feature, ios: true, android: true)
          HotwireNativeVersionGate::VersionGate.native_feature(:disabled_feature, ios: false, android: false)
          HotwireNativeVersionGate::VersionGate.native_feature(:ios_only, ios: true, android: false)
          HotwireNativeVersionGate::VersionGate.native_feature(:android_only, ios: false, android: true)
        end

        it "returns true when feature is enabled for platform" do
          expect(HotwireNativeVersionGate::VersionGate.feature_enabled?(:enabled_feature, ios_user_agent)).to be true
          expect(HotwireNativeVersionGate::VersionGate.feature_enabled?(:enabled_feature, android_user_agent)).to be true
        end

        it "returns false when feature is disabled for platform" do
          expect(HotwireNativeVersionGate::VersionGate.feature_enabled?(:disabled_feature, ios_user_agent)).to be false
          expect(HotwireNativeVersionGate::VersionGate.feature_enabled?(:disabled_feature, android_user_agent)).to be false
        end

        it "returns true for iOS-only feature on iOS" do
          expect(HotwireNativeVersionGate::VersionGate.feature_enabled?(:ios_only, ios_user_agent)).to be true
        end

        it "returns false for iOS-only feature on Android" do
          expect(HotwireNativeVersionGate::VersionGate.feature_enabled?(:ios_only, android_user_agent)).to be false
        end

        it "returns true for Android-only feature on Android" do
          expect(HotwireNativeVersionGate::VersionGate.feature_enabled?(:android_only, android_user_agent)).to be true
        end

        it "returns false for Android-only feature on iOS" do
          expect(HotwireNativeVersionGate::VersionGate.feature_enabled?(:android_only, ios_user_agent)).to be false
        end
      end

      context "with version string requirements" do
        before do
          HotwireNativeVersionGate::VersionGate.native_feature(:versioned_feature, ios: "1.2.0", android: "2.0.0")
        end

        it "returns true when app version meets minimum requirement" do
          user_agent = "Hotwire Native App iOS/1.2.0"
          expect(HotwireNativeVersionGate::VersionGate.feature_enabled?(:versioned_feature, user_agent)).to be true
        end

        it "returns true when app version exceeds minimum requirement" do
          user_agent = "Hotwire Native App iOS/1.3.0"
          expect(HotwireNativeVersionGate::VersionGate.feature_enabled?(:versioned_feature, user_agent)).to be true
        end

        it "returns false when app version is below minimum requirement" do
          user_agent = "Hotwire Native App iOS/1.1.0"
          expect(HotwireNativeVersionGate::VersionGate.feature_enabled?(:versioned_feature, user_agent)).to be false
        end

        it "handles different version requirements for different platforms" do
          ios_old = "Hotwire Native App iOS/1.0.0"
          ios_new = "Hotwire Native App iOS/1.2.0"
          android_old = "Hotwire Native App Android/1.0.0"
          android_new = "Hotwire Native App Android/2.0.0"

          expect(HotwireNativeVersionGate::VersionGate.feature_enabled?(:versioned_feature, ios_old)).to be false
          expect(HotwireNativeVersionGate::VersionGate.feature_enabled?(:versioned_feature, ios_new)).to be true
          expect(HotwireNativeVersionGate::VersionGate.feature_enabled?(:versioned_feature, android_old)).to be false
          expect(HotwireNativeVersionGate::VersionGate.feature_enabled?(:versioned_feature, android_new)).to be true
        end
      end

      context "with custom regex" do
        before do
          HotwireNativeVersionGate::VersionGate.native_version_regex = /MyApp (iOS|Android)\/(\d+\.\d+\.\d+)/
          HotwireNativeVersionGate::VersionGate.native_feature(:custom_feature, ios: true, android: true)
        end

        it "works with custom user agent format" do
          user_agent = "MyApp iOS/1.0.0"
          expect(HotwireNativeVersionGate::VersionGate.feature_enabled?(:custom_feature, user_agent)).to be true
        end

        it "doesn't match default format with custom regex" do
          user_agent = "Hotwire Native App iOS/1.0.0"
          expect(HotwireNativeVersionGate::VersionGate.feature_enabled?(:custom_feature, user_agent)).to be false
        end
      end
    end
  end

  describe HotwireNativeVersionGate::Concern do
    let(:controller_class) do
      Class.new do
        include HotwireNativeVersionGate::Concern

        def request
          @request ||= double("Request", user_agent: user_agent_string)
        end

        attr_accessor :user_agent_string
      end
    end

    let(:controller) { controller_class.new }

    before do
      # Reset state
      HotwireNativeVersionGate::VersionGate.instance_variable_set(:@native_features, {})
      HotwireNativeVersionGate::VersionGate.instance_variable_set(
        :@native_version_regex,
        HotwireNativeVersionGate::VersionGate::DEFAULT_NATIVE_VERSION_REGEX
      )
    end

    describe ".native_feature" do
      it "delegates to VersionGate" do
        controller_class.native_feature(:test_feature, ios: true, android: false)
        features = HotwireNativeVersionGate::VersionGate.native_features
        expect(features[:test_feature]).to eq({ ios: true, android: false })
      end
    end

    describe ".native_version_regex=" do
      it "delegates to VersionGate" do
        custom_regex = /Custom (iOS|Android)\/(\d+\.\d+\.\d+)/
        controller_class.native_version_regex = custom_regex
        expect(HotwireNativeVersionGate::VersionGate.native_version_regex).to eq(custom_regex)
      end
    end

    describe "#native_feature_enabled?" do
      before do
        controller_class.native_feature(:test_feature, ios: true, android: true)
        controller.user_agent_string = "Hotwire Native App iOS/1.0.0"
      end

      it "returns true when feature is enabled" do
        expect(controller.native_feature_enabled?(:test_feature)).to be true
      end

      it "returns false when feature is disabled" do
        controller_class.native_feature(:disabled_feature, ios: false, android: false)
        expect(controller.native_feature_enabled?(:disabled_feature)).to be false
      end

      it "handles nil user agent gracefully" do
        controller.user_agent_string = nil
        expect(controller.native_feature_enabled?(:test_feature)).to be false
      end

      it "handles missing request method gracefully" do
        controller_without_request = Class.new do
          include HotwireNativeVersionGate::Concern
        end.new

        controller_class.native_feature(:test_feature, ios: true, android: true)
        expect(controller_without_request.native_feature_enabled?(:test_feature)).to be false
      end
    end

    context "when helper_method is available" do
      it "calls helper_method when the concern is included" do
        helper_methods_called = []

        controller_class = Class.new do
          def self.helper_method(method_name)
            helper_methods_called << method_name
          end

          def request
            @request ||= double("Request", user_agent: "Hotwire Native App iOS/1.0.0")
          end
        end

        controller_class.include(HotwireNativeVersionGate::Concern)
        expect(helper_methods_called).to include(:native_feature_enabled?)
      end

      it "does not call helper_method when it's not available" do
        controller_class = Class.new do
          def request
            @request ||= double("Request", user_agent: "Hotwire Native App iOS/1.0.0")
          end
        end

        expect { controller_class.include(HotwireNativeVersionGate::Concern) }.not_to raise_error
      end
    end
  end
end
