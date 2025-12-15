# 🚨 CRITICAL: Repository Separation Policy for Claude AI

## ⚠️ READ THIS FIRST - BEFORE ANY CODE CHANGES

### This is the **iOS-ONLY** Repository

**Repository URL**: https://github.com/aka209859-max/gym-tracker-flutter  
**Platform**: iOS ONLY  
**Purpose**: Apple App Store submission

---

## 🔴 ABSOLUTE RULES - NO EXCEPTIONS

### ❌ NEVER Do These in THIS Repository:
1. ❌ Add Android platform code
2. ❌ Use `TargetPlatform.android` checks
3. ❌ Include Android-specific dependencies
4. ❌ Mention "Android" in code comments
5. ❌ Add Android documentation (e.g., `ANDROID_SETUP_GUIDE.md`)
6. ❌ Modify Android directory files (except iOS-compatible changes)

### ✅ ONLY Do These in THIS Repository:
1. ✅ iOS-specific code and `TargetPlatform.iOS` checks
2. ✅ iOS dependencies from pub.dev
3. ✅ Apple App Store compliance work
4. ✅ Web preview code (for development testing)

---

## 🤖 Android Work? Use the SEPARATE Repository

**Android Repository URL**: https://github.com/aka209859-max/gym-tracker-flutter-android  
**Platform**: Android ONLY  
**Purpose**: Google Play Store submission

**If you need to work on Android**:
```bash
cd /home/user/webapp-android
git remote -v  # Verify: gym-tracker-flutter-android
```

---

## 🔍 MANDATORY: Pre-Operation Checklist

**BEFORE making ANY changes, ALWAYS run**:
```bash
cd /home/user/webapp
git remote -v
```

**Expected output**:
```
origin  https://github.com/aka209859-max/gym-tracker-flutter.git (fetch)
origin  https://github.com/aka209859-max/gym-tracker-flutter.git (push)
```

✅ If you see `gym-tracker-flutter` → This is the iOS repository (CORRECT)  
❌ If you see `gym-tracker-flutter-android` → You're in the Android repository (WRONG LOCATION)

---

## 📖 Why Separate Repositories?

1. **Apple App Store Rejection Risk**: Including Android references causes automatic rejection
2. **Google Play Store Compliance**: Clean Android-only codebase required
3. **Clear Separation**: No cross-platform contamination
4. **Independent Release Cycles**: iOS and Android released separately

---

## 🚨 Historical Context (Learn from This Mistake)

### What Happened (2025-12-15):
1. ⚠️ **Mistake**: Accidentally added Android preparation code to iOS repository (commit `5aa1a0b`)
2. ✅ **Fix**: Immediately reverted Android code (commit `ad69ee4`)
3. 📝 **Result**: Established this strict separation policy

### Files That Were Mistakenly Added:
- `ANDROID_SETUP_GUIDE.md` (Android documentation)
- Android-specific changes to `build.gradle`
- Android-specific changes to `AndroidManifest.xml`
- Multi-platform changes to `DEVELOPMENT_RULES.md`

### The Fix:
```bash
git revert 5aa1a0b  # Revert Android preparation commit
git push origin main  # Push the fix
```

---

## 🆘 Emergency Procedure

**If you accidentally add Android code to THIS repository**:

1. **STOP immediately** - Do not push more commits
2. **Report to user immediately** - Be transparent
3. **Revert the commit**:
   ```bash
   git log --oneline -5  # Find the bad commit
   git revert <commit-hash>
   git push origin main
   ```
4. **Verify iOS-only state**:
   ```bash
   head -50 .github/DEVELOPMENT_RULES.md  # Should show "iOS-Only Application"
   ```

---

## 📊 Repository Information Summary

| Item | iOS Repository (THIS) | Android Repository (SEPARATE) |
|------|----------------------|------------------------------|
| **URL** | `gym-tracker-flutter` | `gym-tracker-flutter-android` |
| **Location** | `/home/user/webapp` | `/home/user/webapp-android` |
| **Platform** | iOS ONLY | Android ONLY |
| **Store** | Apple App Store | Google Play Store |
| **Code** | iOS-specific | Android-specific |

---

## 📝 Additional Resources

- Full development rules: `.github/DEVELOPMENT_RULES.md`
- iOS release guide: `IOS_RELEASE_GUIDE.md` (if exists)
- Project context: `PROJECT_CONTEXT.md`

---

**Last Updated**: 2025-12-15  
**Repository Separation Policy Established**: 2025-12-15  
**Maintained by**: NexaJP Development Team

---

## 🎯 Quick Reference

**Before ANY commit**:
```bash
# 1. Verify repository
cd /home/user/webapp && git remote -v

# 2. Check for Android references (should be minimal)
grep -r "android" lib/ --include="*.dart" | wc -l

# 3. If working on Android, switch repos
cd /home/user/webapp-android
```

**Remember**: This separation policy is CRITICAL for App Store compliance. No exceptions.
