# Hotwire Native Version Gate
Easy version gating for Hotwire Native Apps in Rails. Allows you to specify features that you want turned on or off based on Hotwire Native iOS or Android versions.

### How it works?
App version information is appened in the apps User Agent so the backend can feature gate based on that info.

### Setup
Step 1: iOS and/or Android, prepend to the User Agent:
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

Step 2: Install the gem in your Rails app:
```
bundle add hotwire_native_version_gate
```

Step 3: Include the concern in your ApplicationController. You can also include it in it's own concern if you for example have a lot of features and don't want to crowd your ApplicaitonController:
```ruby
class ApplicationController < ActionController::Base
  include HotwireNativeVersionGate::Concern
end
```

Step 4: Add features:
```ruby
class ApplicationController < ActionController::Base
  include HotwireNativeVersionGate::Concern
  native_feature :html_tabs, ios: '1.2.0', android: '1.1'
end
```

Step 5: Call the helper method in your controllers or views to see if the feature is enable:
```erb
<% if native_feature_enabled?(:html_tabs) %>
  <div>HTML built tabs</div>
<% end >
```

### Options
#### `native_feature` method options

The `native_feature` method allows you to specify feature flags that are enabled for specific Hotwire Native app versions on iOS and Android.

- `feature_name` (Symbol): The name of your feature. Use a symbol to reference it when checking if it's enabled.
- `ios:` / `android:` (String, Symbol `true`, `false`): The minimum iOS app version for which this feature should be enabled. (Default: `false`)
  - Set to a version string (e.g., `'1.2.0'`) to enable for that version and above.
  - Set to symbol of a method to be called in the controller.
  - Set to `true` for enabled on all iOS versions.
  - Set to `false` (or omit) to disable on all iOS.

#### Examples
Enable a feature on iOS `1.2.0`+ and Android `1.1.0`+:
```ruby
native_feature :html_tabs, ios: '1.2.0', android: '1.1.0'
```

Enable a feature only for Android (version `2.0.0`+):
```ruby
native_feature :new_drawer_ui, android: '2.0.0'
```

Enable a feature only for iOS (version `3.0.0`+):
```ruby
native_feature :onboarding_refactor, ios: '3.0.0'
```

Enable for iOS but Disable for Android:
```ruby
native_feature :future_feature, ios: true, android: false # default is false
```

Enable a feature for iOS based on a symbol method on your controller:
```ruby
native_feature :beta_feature, ios: :should_enable_ios_beta?

def should_enable_ios_beta?
  ENV['BETA_ENABLED'] == true
end
```
Here, `should_enable_ios_beta?` should be a method defined in your controller that returns `true` or `false`.


Once defined, you can use `native_feature_enabled?(:feature_name)` anywhere the concern is included (e.g., controllers or views) to conditionally enable the feature based on the requesting app's platform and version.

