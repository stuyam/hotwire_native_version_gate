# Hotwire Native Version Gate

[![Gem](https://img.shields.io/gem/v/hotwire_native_version_gate.svg)](https://rubygems.org/gems/hotwire_native_version_gate)
[![Gem](https://img.shields.io/gem/dt/hotwire_native_version_gate.svg)](https://rubygems.org/gems/hotwire_native_version_gate)

Easy version gating for Hotwire Native Apps in Rails. Allows you to specify features that you want turned on or off based on whether the request is from iOS, Android, and their app versions.

### How it works

App version information is appended to the app's User Agent so the backend can feature gate based on that information.

### Setup
**Step 1**: Configure your iOS and/or Android app to prepend version information to the User Agent:
```swift
// iOS (swift)
if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
    Hotwire.config.applicationUserAgentPrefix = "Hotwire Native App iOS/\(appVersion);"
}
```
```kotlin
// Android (Kotlin)
val appVersion = packageManager.getPackageInfo(packageName, 0).versionName
Hotwire.config.applicationUserAgentPrefix = "Hotwire Native App Android/$appVersion;"
```
Note: For older apps with the the user agent not set with the version, the gem includes a fallback regex that matches user agents the existing `Hotwire Native iOS;` user agent (without version numbers). For these cases, you can only use boolean flags (`true`/`false`) or symbol methods - version string requirements will return `false` since there's no version to compare. This allows you to still differential ios vs android on older versions of your apps.

**Step 2**: Install the gem in your Rails app:
```
bundle add hotwire_native_version_gate
```

**Step 3**: Include the concern in your ApplicationController. Note: If you have a lot of features defined, it might be a good idea to include it in its own concern to avoid crowding your ApplicationController:
```ruby
class ApplicationController < ActionController::Base
  include HotwireNativeVersionGate::Concern
end
```

**Step 4**: Define features:
```ruby
class ApplicationController < ActionController::Base
  include HotwireNativeVersionGate::Concern
  native_feature :html_tabs, ios: '1.2.0', android: '1.1'
end
```

**Step 5**: Call the helper method in your controllers or views to check if the feature is enabled:
```erb
<% if native_feature_enabled?(:html_tabs) %>
  <div>HTML built tabs</div>
<% end %>
```

### Options
#### `native_feature` method options

The `native_feature` method allows you to specify feature flags that are enabled for specific Hotwire Native app versions on iOS and Android.

- `feature_name` (Symbol): The name of your feature. Use a symbol to reference it when checking if it's enabled.
- `ios:` / `android:` (String, Symbol, `true`, `false`): Controls when the feature is enabled for each platform. (Default: `false`)
  - Set to a version string (e.g., `'1.2.0'`) to enable for that version and above.
  - Set to a symbol representing a method to be called in the controller instance.
  - Set to `true` to enable for all versions of that platform.
  - Set to `false` (or omit) to disable for that platform.

#### Examples
```ruby
class ApplicationController < ActionController::Base
  include HotwireNativeVersionGate::Concern

  # Enable a feature on iOS `1.2.0`+ and Android `1.1.0`+:
  native_feature :html_tabs, ios: '1.2.0', android: '1.1.0'

  # Enable a feature only for Android (version `2.0.0`+):
  native_feature :new_drawer_ui, android: '2.0.0'

  # Enable a feature only for iOS (version `3.0.0`+):
  native_feature :onboarding_refactor, ios: '3.0.0'

  # Enable for iOS but disable for Android:
  native_feature :future_feature, ios: true, android: false # default is false

  # Enable a feature for iOS based on a method defined in your controller:
  native_feature :beta_feature, ios: :should_enable_ios_beta?

  # Enable for apps without version info (works with fallback regex):
  # User agents like "Hotwire Native iOS;" will match and return true/false
  native_feature :legacy_feature, ios: true, android: true

  private

  def should_enable_ios_beta?
    ENV['BETA_ENABLED'] == 'true'
  end
end
```

The method referenced by the symbol (e.g., `should_enable_ios_beta?`) should be defined in your controller and return `true` or `false`. The method will be called in the context of the controller instance, giving you access to instance variables and other controller methods.

Once defined, you can use `native_feature_enabled?(:feature_name)` anywhere the concern is included (e.g., controllers or views) to conditionally render content based on the requesting app's platform and version.

#### Customizing the User Agent regex

**Note:** You typically don't need to customize the regex patterns. The gem includes default regexes that handle most common cases:
1. `Hotwire Native App iOS/1.0.0` or `Hotwire Native App Android/1.0.0` (with version)
2. `Hotwire Native iOS;` or `Turbo Native Android;` (fallback without version)

If your app uses a different User Agent format, you can customize the regex patterns:

```ruby
class ApplicationController < ActionController::Base
  include HotwireNativeVersionGate::Concern

  # Replace all regexes with a single custom regex
  self.native_version_regexes = /\bMyApp (?<platform>iOS|Android)\/(?<version>\d+\.\d+\.\d+)\b/

  # Or prepend a custom regex to try first (keeps defaults as fallback)
  prepend_native_version_regexes(/\bCustomApp (?<platform>iOS|Android)\/(?<version>\d+\.\d+\.\d+)\b/)

  # Or set multiple regexes as an array
  self.native_version_regexes = [
    /\bMyApp (?<platform>iOS|Android)\/(?<version>\d+\.\d+\.\d+)\b/,
    /\bMyApp (?<platform>iOS|Android)\b/  # fallback without version
  ]
end
```

**Important:** Your custom regex must include named capture groups:
- `(?<platform>...)` - Should capture "iOS" or "Android"
- `(?<version>...)` - Optional: Should capture the semantic version number if you want to support version-based feature gating

The regexes are tried in order until one matches. If a regex matches but doesn't have a `version` capture group, version string requirements will return `false`, but boolean flags (`true`/`false`) and symbol methods will work normally.

