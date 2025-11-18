# frozen_string_literal: true

module HotwireNativeVersionGate
  module Concern
    extend ActiveSupport::Concern

    class_methods do
      def native_feature(feature, ios: false, android: false)
        VersionGate.native_feature(feature, ios: ios, android: android)
      end

      def native_version_regexes=(regexes)
        VersionGate.native_version_regexes = regexes
      end

      def prepend_native_version_regexes(regexes)
        VersionGate.prepend_native_version_regexes(regexes)
      end
    end

    included do
      if respond_to?(:helper_method)
        helper_method :native_feature_enabled?
      end
    end

    def native_feature_enabled?(feature)
      user_agent = if respond_to?(:request) && request.respond_to?(:user_agent)
        request.user_agent
      else
        nil
      end

      VersionGate.feature_enabled?(feature, user_agent, context: self)
    end
  end
end
