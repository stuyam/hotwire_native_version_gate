# frozen_string_literal: true

module HotwireNativeVersionGates
  class VersionGate
    # Default regex example: Hotwire Native App iOS/1.0.0;
    # Expected capture groups: [1] = platform (iOS|Android), [2] = version (semantic version)
    DEFAULT_NATIVE_VERSION_REGEX = /Hotwire Native App (iOS|Android)\/(\d+\.\d+\.\d+)/

    @native_features = {}
    @native_version_regex = DEFAULT_NATIVE_VERSION_REGEX

    class << self
      attr_reader :native_features, :native_version_regex

      def native_version_regex=(regex)
        unless regex.is_a?(Regexp)
          raise ArgumentError, "native_version_regex must be a Regexp"
        end
        @native_version_regex = regex
      end

      def native_feature(feature, ios: false, android: false)
        @native_features ||= {}
        @native_features[feature] = { ios: ios, android: android }
      end

      def feature_enabled?(feature, user_agent)
        @native_features ||= {}
        return false unless @native_features.key?(feature)

        platform = match_platform(user_agent)
        return false if platform.nil?

        platform_key = platform.downcase.to_sym
        feature_config = @native_features[feature][platform_key]
        handle_feature(feature_config, user_agent)
      end

      private

      def match_platform(user_agent)
        match = user_agent.to_s.match(@native_version_regex)
        return match[1] if match
        nil
      end

      def handle_feature(feature_config, user_agent)
        # if false or nil, return false
        return false unless feature_config
        # if true, return true
        return true if feature_config == true
        # if a string, compare the version
        if feature_config.is_a?(String)
          match = user_agent.to_s.match(@native_version_regex)
          return false unless match
          return Gem::Version.new(feature_config) <= Gem::Version.new(match[2])
        end
        # if a symbol, call the method
        return send(feature_config, user_agent) if feature_config.is_a?(Symbol)
        # else, raise an error
        raise InvalidVersionGateError, "Invalid version gate: #{feature_config}"
      end
    end
  end
end
