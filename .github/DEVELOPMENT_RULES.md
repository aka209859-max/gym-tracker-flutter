# GYM MATCH Development Rules

## 🚨 CRITICAL: Repository Separation Policy

### Rule 0: SEPARATE REPOSITORIES FOR iOS AND ANDROID
**GYM MATCH uses completely separate repositories for iOS and Android.**

#### **iOS Repository** (THIS REPOSITORY)
- 🔗 **URL**: https://github.com/aka209859-max/gym-tracker-flutter
- 📱 **Platform**: iOS ONLY
- ⚠️ **STRICT RULE**: NO Android code, references, or documentation allowed
- 🎯 **Purpose**: Apple App Store submission and iOS development

#### **Android Repository** (SEPARATE)
- 🔗 **URL**: https://github.com/aka209859-max/gym-tracker-flutter-android
- 🤖 **Platform**: Android ONLY
- ⚠️ **STRICT RULE**: NO iOS code, references, or documentation allowed
- 🎯 **Purpose**: Google Play Store submission and Android development

#### **WHY Separate Repositories?**
1. **Apple App Store Rejection Risk**: Including Android references causes rejection
2. **Google Play Store Compliance**: Clean Android-only codebase
3. **Clear Separation**: No cross-platform contamination
4. **Independent Release Cycles**: iOS and Android can be released separately

#### **BEFORE Making ANY Changes**
✅ **ALWAYS confirm which repository you are working in**:
```bash
git remote -v  # Check repository URL
```

❌ **NEVER mix iOS and Android code in the same repository**

---

## 🚨 Critical Rules for Apple App Store Submission

### Rule 1: iOS-Only Application (THIS REPOSITORY)
**THIS repository is iOS-only. No exceptions.**

- ❌ **DO NOT** add Android platform code
- ❌ **DO NOT** use `TargetPlatform.android` checks
- ❌ **DO NOT** include Android-specific dependencies
- ❌ **DO NOT** mention "Android" in code comments
- ❌ **DO NOT** add Android documentation (ANDROID_SETUP_GUIDE.md, etc.)
- ❌ **DO NOT** modify Android directory files (except iOS-compatible changes)
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

- **v1.0.244+269** (2025-12-15): **CRITICAL FIX - Repository Separation Policy**
  - ⚠️ Accidentally mixed Android code into iOS repository (commit 5aa1a0b)
  - ✅ Reverted Android preparation commit (commit ad69ee4)
  - ✅ Established strict repository separation rules
  - ✅ iOS repository: https://github.com/aka209859-max/gym-tracker-flutter
  - ✅ Android repository: https://github.com/aka209859-max/gym-tracker-flutter-android
- **v1.0.244+269** (2025-12-15): Fixed 1-month cardio display bug in home screen
- **v1.0.87**: Fixed anonymous user subscription sync bug
- **v1.0.87**: Removed all Android platform references (iOS-only focus)
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
