# frozen_string_literal: true

module HotwireNativeVersionGate
  module Concern
    extend ActiveSupport::Concern

    class_methods do
      def native_feature(feature, ios: false, android: false)
        VersionGate.native_feature(feature, ios: ios, android: android)
      end

      def native_version_regexes
        VersionGate.native_version_regexes
      end

      def native_version_regexes=(regexes)
        VersionGate.native_version_regexes = regexes
      end
    end

    included do
      if respond_to?(:helper_method)
        helper_method :native_feature_enabled?, :hotwire_native_ios?, :hotwire_native_android?
      end
    end

    def native_feature_enabled?(feature)
      user_agent = respond_to?(:request) && request&.user_agent
      VersionGate.feature_enabled?(feature, user_agent, context: self)
    end

    def hotwire_native_ios?
      user_agent = respond_to?(:request) && request&.user_agent
      VersionGate.ios?(user_agent)
    end

    def hotwire_native_android?
      user_agent = respond_to?(:request) && request&.user_agent
      VersionGate.android?(user_agent)
    end
  end
end
