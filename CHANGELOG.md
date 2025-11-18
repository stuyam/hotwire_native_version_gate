# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2025-11-18

### Added
- Added `hotwire_native_ios?` and `hotwire_native_android?` helpers for controller and view checks without needing to define a feature.

## [0.2.0] - 2025-11-18

### Added
- Support for multiple regex patterns tried in order until one matches.
- Fallback regex support for user agents without version numbers (e.g., `Hotwire Native iOS;`).
- Support for boolean flags (`true`/`false`) with fallback regex for apps without version information.
- Graceful handling of regexes that match but don't have optional capture groups (e.g., `version`).
- `native_version_regexes` reader method to access current regex array for prepending custom regexes.

### Changed
- `native_version_regex` renamed to `native_version_regexes` (plural) to support arrays.
- Regex matching now tries multiple patterns in order, allowing fallback patterns for older app versions.
- Version string requirements return `false` when user agent matches but has no version information.

## [0.1.0] - 2025-11-17

### Added
- Initial release of `hotwire_native_version_gate` gem.
- Feature gating system for Hotwire Native apps in Rails based on iOS/Android and their version via user agent matching.
- `native_feature` API to declare feature flags for specific versions/platforms.
- Support for static, versioned, and method-based gates.
- `native_feature_enabled?` helper method for controllers and views.
- Configurable user agent regex for custom app formats.
- Rails concern for easy inclusion in controllers.
