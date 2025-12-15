# GYM MATCH Development Rules

## 🚨 Critical Rules - Multi-Platform Application (2025-12-15 Updated)

### Rule 1: Multi-Platform Application (iOS + Android)
**GYM MATCH is now a multi-platform application supporting iOS and Android.**

**Updated Policy (2025-12-15)**:
- ✅ **iOS-first development**: iOS remains the primary platform
- ✅ **Android support**: Android platform code is now allowed
- ✅ **Platform checks**: Use `TargetPlatform.iOS` and `TargetPlatform.android` as needed
- ✅ **Web preview**: Web preview is allowed for development testing

**Historical Context**:
- Prior to v1.0.87, Android references were removed for Apple App Store compliance
- As of v1.0.244+269, Android platform development has been officially resumed

### Rule 2: Platform Checks - Allowed Patterns

✅ **CORRECT** (Updated for multi-platform):
```dart
if (defaultTargetPlatform == TargetPlatform.iOS) {
  // iOS-specific code
}

if (defaultTargetPlatform == TargetPlatform.android) {
  // Android-specific code (NOW ALLOWED)
}

if (kIsWeb) {
  // Web preview code
}

// Cross-platform code
if (defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.android) {
  // Mobile platforms (iOS + Android)
}
```

⚠️ **BEST PRACTICE**:
```dart
// Instead of checking both platforms, consider using common Flutter widgets
// that work across all platforms when possible
```

### Rule 3: Anonymous User Support
**GYM MATCH uses anonymous login (guest mode) as the default.**

- ✅ **ALWAYS** support anonymous users in Firestore operations
- ✅ **DO NOT** exclude anonymous users with `!user.isAnonymous` checks
- ✅ RevenueCat subscriptions must sync for anonymous users

✅ **CORRECT**:
```dart
final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  // Process for all users including anonymous
}
```

❌ **WRONG**:
```dart
final user = FirebaseAuth.instance.currentUser;
if (user != null && !user.isAnonymous) {
  // This excludes anonymous users - BUG!
}
```

### Rule 4: Package Dependencies (Updated for Multi-Platform)
- ✅ Use packages that support both iOS and Android
- ✅ Verify pub.dev shows "iOS" **AND** "Android" platform support
- ✅ Android-specific packages are now allowed when necessary
- ⚠️ Prioritize cross-platform packages for easier maintenance

### Rule 5: Firebase Configuration (Updated for Multi-Platform)
- ✅ `firebase_options.dart` must include iOS configuration
- ✅ `firebase_options.dart` must include Android configuration
- ✅ Web configuration allowed for preview
- ✅ `google-services.json` required for Android (in `android/app/`)
- ✅ `GoogleService-Info.plist` required for iOS (in `ios/Runner/`)

### Rule 6: RevenueCat Integration
- ✅ iOS App Store In-App Purchases only
- ✅ Apple promotion codes supported
- ✅ Subscription sync must work for anonymous users

## 🔍 Pre-Commit Checklist (Updated for Multi-Platform)

Before committing code, verify:

1. ✅ Platform-specific code is properly isolated with platform checks
2. ✅ Android dependencies support Android platform
3. ✅ iOS dependencies support iOS platform
4. ✅ Anonymous user support in authentication flows
5. ✅ RevenueCat integration works for anonymous users
6. ✅ Cross-platform UI consistency maintained
7. ✅ Both iOS and Android builds tested (when applicable)

## 🚀 Version History

- **v1.0.244+269** (2025-12-15): **Android platform development officially resumed**
  - Updated development rules for multi-platform (iOS + Android)
  - Created `ANDROID_SETUP_GUIDE.md` for Android preparation
  - Updated `build.gradle` with correct versionCode/versionName
- **v1.0.87** (2025-11): Fixed anonymous user subscription sync bug
- **v1.0.87** (2025-11): Removed all Android platform references (iOS-only phase)
- **v1.0.86** (2025-11): Initial App Store release

## 📝 Platform Compliance

### iOS (Apple App Store)
**Target Platform**: iOS  
**Minimum iOS Version**: iOS 13.0+  
**Device Support**: iPhone, iPad  
**Orientation**: Portrait  
**Languages**: Japanese  
**Age Rating**: 4+

### Android (Google Play Store)
**Target Platform**: Android  
**Minimum Android SDK**: minSdk from Flutter config  
**Target Android SDK**: targetSdk from Flutter config  
**Package Name**: jp.nexa.fitsync  
**Orientation**: Portrait  
**Languages**: Japanese  
**Age Rating**: Everyone

---

**Last Updated**: 2025-12-15  
**Maintained by**: NexaJP Development Team
