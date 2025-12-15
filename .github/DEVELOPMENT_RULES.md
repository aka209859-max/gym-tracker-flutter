# GYM MATCH Development Rules

## 🚨 Critical Rules for Apple App Store Submission

### Rule 1: iOS-Only Application
**GYM MATCH is an iOS-only application.**

- ❌ **DO NOT** add Android platform code
- ❌ **DO NOT** use `TargetPlatform.android` checks
- ❌ **DO NOT** include Android-specific dependencies
- ❌ **DO NOT** mention "Android" in code comments
- ✅ **ONLY** use `TargetPlatform.iOS` checks
- ✅ Web preview is allowed for development testing

**Reason**: Including Android references will cause **Apple App Store rejection**.

### Rule 2: Platform Checks - Allowed Patterns

✅ **CORRECT**:
```dart
if (defaultTargetPlatform == TargetPlatform.iOS) {
  // iOS-specific code
}

if (kIsWeb) {
  // Web preview code
}

if (defaultTargetPlatform == TargetPlatform.iOS || kIsWeb) {
  // iOS or Web preview
}
```

❌ **WRONG**:
```dart
if (defaultTargetPlatform == TargetPlatform.android) {
  // Never use this!
}

if (defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.android) {
  // Never include Android!
}
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

### Rule 4: Package Dependencies
- ✅ Only use packages that support iOS
- ✅ Verify pub.dev shows "iOS" platform support
- ❌ Do not add Android-only packages

### Rule 5: Firebase Configuration
- ✅ `firebase_options.dart` must include iOS configuration
- ✅ Web configuration allowed for preview
- ❌ Android configuration should throw `UnsupportedError`

### Rule 6: RevenueCat Integration
- ✅ iOS App Store In-App Purchases only
- ✅ Apple promotion codes supported
- ✅ Subscription sync must work for anonymous users

## 🔍 Pre-Commit Checklist

Before committing code, verify:

1. ✅ No Android platform references in `.dart` files
2. ✅ No Android-specific dependencies in `pubspec.yaml`
3. ✅ Anonymous user support in authentication flows
4. ✅ iOS platform checks only (or iOS + Web)
5. ✅ RevenueCat integration works for anonymous users

## 🚀 Version History

- **v1.0.87**: Fixed anonymous user subscription sync bug
- **v1.0.87**: Removed all Android platform references
- **v1.0.86**: Initial App Store release

## 📝 Apple App Store Compliance

**Target Platform**: iOS only
**Minimum iOS Version**: iOS 13.0+
**Device Support**: iPhone, iPad
**Orientation**: Portrait
**Languages**: Japanese
**Age Rating**: 4+

---

**Last Updated**: 2025-11-27
**Maintained by**: NexaJP Development Team
