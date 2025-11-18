# frozen_string_literal: true

module HotwireNativeVersionGate
  class VersionGate
    # Default regex example: Hotwire Native App iOS/1.0.0;
    # Expected capture groups: platform = (iOS|Android), version = semantic version
    DEFAULT_NATIVE_VERSION_REGEX = /\bHotwire Native App (?<platform>iOS|Android)\/(?<version>\d+(?:\.\d+)*)\b/
    # Default fallback for apps that don't have the version in the User Agent ex: Hotwire Native iOS;
    FALLBACK_NATIVE_VERSION_REGEX = /\b(Turbo|Hotwire) Native (?<platform>iOS|Android)\b/

    @native_features = {}
    @native_version_regexes = [ DEFAULT_NATIVE_VERSION_REGEX, FALLBACK_NATIVE_VERSION_REGEX ]

    class << self
      attr_reader :native_features, :native_version_regexes

      def native_version_regexes=(regexes)
        regexes_array = validate_regexes(regexes)
        @native_version_regexes = regexes_array
      end

      def native_feature(feature, ios: false, android: false)
        @native_features ||= {}
        @native_features[feature] = { ios: ios, android: android }
      end

      def feature_enabled?(feature, user_agent, context: nil)
        @native_features ||= {}
        return false unless @native_features.key?(feature)

        platform = match_platform(user_agent)
        return false if platform.nil?

        platform_key = platform.downcase.to_sym
        feature_config = @native_features[feature][platform_key]
        handle_feature(feature_config, user_agent, context: context)
      end

      def ios?(user_agent)
        platform = match_platform(user_agent)
        platform&.downcase == 'ios'
      end

      def android?(user_agent)
        platform = match_platform(user_agent)
        platform&.downcase == 'android'
      end

      private

      def validate_regexes(regexes)
        # Support both single regex and array of regexes
        regexes_array = Array(regexes)

        regexes_array.each do |regex|
          unless regex.is_a?(Regexp)
            raise ArgumentError, "native_version_regexes must be an array of Regexp objects, got: #{regex.class}"
          end
        end

        regexes_array
      end

      def match_key(user_agent, key)
        @native_version_regexes.each do |regex|
          match = user_agent.to_s.match(regex)
          return match[key] if match&.names&.include?(key.to_s) && match[key]
        end
        nil
      end

      def match_platform(user_agent)
        match_key(user_agent, :platform)
      end

      def handle_feature(feature_config, user_agent, context: nil)
        # if false or nil, return false
        return false unless feature_config
        # if true, return true
        return true if feature_config == true
        # if a string, compare the version
        if feature_config.is_a?(String)
          version = match_key(user_agent, :version)
          return false unless version
          return Gem::Version.new(feature_config) <= Gem::Version.new(version)
        end
        # if a symbol, call the method on the context (if provided) or self
        if feature_config.is_a?(Symbol)
          if context
            return context.send(feature_config)
          else
            return send(feature_config)
          end
        end
        # else, raise an error
        raise InvalidVersionGateError, "Invalid version gate: #{feature_config}"
      end
    end
  end
end
