# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-11-17

### Added
- Initial release of `hotwire_native_version_gate` gem.
- Feature gating system for Hotwire Native apps in Rails based on iOS/Android and their version via user agent matching.
- `native_feature` API to declare feature flags for specific versions/platforms.
- Support for static, versioned, and method-based gates.
- `native_feature_enabled?` helper method for controllers and views.
- Configurable user agent regex for custom app formats.
- Rails concern for easy inclusion in controllers.
