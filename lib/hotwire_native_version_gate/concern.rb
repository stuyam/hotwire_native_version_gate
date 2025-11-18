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
        helper_method :native_feature?, :native_ios?, :native_android?
      end
    end

    def native_feature?(feature)
      user_agent = respond_to?(:request) && request.respond_to?(:user_agent) ? request.user_agent : nil
      VersionGate.feature_enabled?(feature, user_agent, context: self)
    end

    def native_ios?(min_version = nil)
      user_agent = respond_to?(:request) && request.respond_to?(:user_agent) ? request.user_agent : nil
      VersionGate.ios?(user_agent, min_version)
    end

    def native_android?(min_version = nil)
      user_agent = respond_to?(:request) && request.respond_to?(:user_agent) ? request.user_agent : nil
      VersionGate.android?(user_agent, min_version)
    end
  end
end
