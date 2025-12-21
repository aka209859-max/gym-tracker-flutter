# 🌍 Native Speaker Translation Review Checklist

**Version**: v1.0.279  
**Date**: 2025-12-21  
**Total Keys**: 944 keys × 6 languages = 5,664 translations to review

---

## 📋 Overview

This document provides a structured checklist for native speakers to review machine-translated content in GYM MATCH fitness app. All translations were generated using rule-based machine translation with comprehensive fitness terminology dictionaries.

**Languages Requiring Review**:
- 🇺🇸 **English (EN)**: 944 keys
- 🇰🇷 **Korean (KO)**: 944 keys  
- 🇨🇳 **Chinese Simplified (ZH)**: 944 keys
- 🇹🇼 **Chinese Traditional (ZH_TW)**: 944 keys
- 🇩🇪 **German (DE)**: 944 keys
- 🇪🇸 **Spanish (ES)**: 944 keys

---

## 🎯 Review Objectives

### Primary Goals
1. ✅ **Accuracy**: Ensure translations correctly convey the original Japanese meaning
2. ✅ **Naturalness**: Verify translations sound natural to native speakers
3. ✅ **Consistency**: Check fitness terminology consistency across the app
4. ✅ **Cultural Appropriateness**: Adapt content for local cultural contexts
5. ✅ **Grammar & Spelling**: Identify and correct any grammatical errors

### Secondary Goals
6. ⚠️ **Formality Level**: Adjust tone (casual vs formal) as appropriate
7. ⚠️ **Gender Neutrality**: Ensure inclusive language where applicable
8. ⚠️ **Regional Variations**: Note differences (e.g., US English vs UK English)

---

## 📊 Priority Categories for Review

### 🔴 **HIGH PRIORITY** (Review First)

#### 1. User-Facing UI Text (300+ keys)
**Location**: Basic actions, navigation, buttons  
**Examples**:
- Buttons: "Save", "Delete", "Cancel", "Confirm"
- Navigation: "Home", "Profile", "Settings", "Search"
- Status: "Loading", "Success", "Error", "Failed"

**Review Focus**:
- Are button labels concise and action-oriented?
- Do navigation terms match platform conventions?
- Are error messages clear and helpful?

#### 2. Fitness Terminology (150+ keys)
**Location**: Exercise types, body parts, training levels  
**Examples**:
- Body parts: "Chest", "Back", "Shoulders", "Legs", "Core"
- Exercises: "Bench Press", "Squat", "Deadlift", "Pull-up"
- Levels: "Beginner", "Intermediate", "Advanced", "Expert"

**Review Focus**:
- Are fitness terms consistent with industry standards?
- Do body part names match anatomical terminology?
- Are exercise names recognizable to fitness enthusiasts?

#### 3. Goals & Metrics (50+ keys)
**Location**: User goals, training objectives, measurements  
**Examples**:
- Goals: "Muscle Hypertrophy", "Weight Loss", "Strength Gain"
- Metrics: "Body Weight", "Body Fat Percentage", "Max Weight"
- Stats: "Total Sets", "Total Reps", "Current Streak"

**Review Focus**:
- Are goal descriptions motivating and clear?
- Do metric names match fitness industry standards?
- Are units (kg, lbs, cm) appropriately localized?

#### 4. Error Messages (40+ keys)
**Location**: Validation errors, system errors  
**Examples**:
- "Invalid email format"
- "Password must be at least 6 characters"
- "Save failed"
- "Data loading error"

**Review Focus**:
- Are error messages clear about what went wrong?
- Do they provide actionable guidance?
- Is the tone helpful rather than accusatory?

---

### 🟡 **MEDIUM PRIORITY** (Review Second)

#### 5. Authentication & Onboarding (30+ keys)
**Location**: Login, registration, tutorial  
**Examples**:
- "Welcome", "Get Started", "Skip", "Login"
- "Email Address", "Password", "Access Code"
- "Tutorial", "Help", "FAQ"

**Review Focus**:
- Is onboarding language welcoming and encouraging?
- Are instructions clear for first-time users?
- Does tutorial content flow naturally?

#### 6. Social & Community Features (30+ keys)
**Location**: Partner search, forums, sharing  
**Examples**:
- "Partner Search", "Community", "Forum", "Discussion"
- "Like", "Follow", "Comment", "Share"
- "Inappropriate content", "Report"

**Review Focus**:
- Do social action terms match platform norms?
- Is content moderation language clear?
- Are community guidelines understandable?

#### 7. Subscription & Purchase (20+ keys)
**Location**: Plans, pricing, purchase flow  
**Examples**:
- "View Pro Plan", "AI Add-on Pack", "Purchase"
- "Purchase Error", "Trial Period", "Subscription"

**Review Focus**:
- Are pricing terms clear and transparent?
- Do purchase flow instructions make sense?
- Are error messages for payment failures helpful?

---

### 🟢 **LOW PRIORITY** (Review Last)

#### 8. Developer Tools (10+ keys)
**Location**: Debug menus, technical settings  
**Examples**:
- "Developer Menu", "Debug Info", "Stack Trace"
- "Document ID", "Total Documents"

**Review Focus**:
- Are technical terms accurate for developers?
- (Less critical for end-user experience)

#### 9. Japanese Prefectures (47 keys) 🇯🇵
**Location**: Location selection  
**Examples**:
- Tokyo (東京都), Osaka (大阪府), Kyoto (京都府)

**Review Focus**:
- Are prefecture names romanized correctly?
- (EN: Check romanization, Other languages: Major cities only)

---

## 🔍 Detailed Review Process

### Step 1: Environment Setup
1. Clone repository: `git clone https://github.com/aka209859-max/gym-tracker-flutter.git`
2. Navigate to l10n directory: `cd lib/l10n/`
3. Open your language ARB file:
   - English: `app_en.arb`
   - Korean: `app_ko.arb`
   - Chinese (Simplified): `app_zh.arb`
   - Chinese (Traditional): `app_zh_TW.arb`
   - German: `app_de.arb`
   - Spanish: `app_es.arb`

### Step 2: Review Methodology

For each key in the ARB file:

1. **Read the Japanese original** (reference `app_ja.arb`)
2. **Check the current translation** in your language
3. **Ask these questions**:
   - ✅ Does it convey the same meaning?
   - ✅ Would a native speaker say it this way?
   - ✅ Is it consistent with other translations?
   - ✅ Is it grammatically correct?
   - ✅ Is it culturally appropriate?

4. **If issues found**, note:
   - Key name
   - Current translation
   - Suggested improvement
   - Reason for change

### Step 3: Testing in Context

**Recommended**:
1. Build the app locally: `flutter run`
2. Switch to your language in Settings
3. Navigate through key screens:
   - Home screen
   - Workout logging
   - AI coaching
   - Gym search
   - Profile settings
4. Check if translations feel natural in context

### Step 4: Documentation

Create a review document with this structure:

```markdown
# [Language] Translation Review - [Your Name]
**Date**: YYYY-MM-DD
**Keys Reviewed**: X / 944
**Issues Found**: X

## Critical Issues (Must Fix)
1. Key: `keyName`
   - Current: "..."
   - Suggested: "..."
   - Reason: ...

## Minor Issues (Nice to Fix)
1. Key: `keyName`
   - Current: "..."
   - Suggested: "..."
   - Reason: ...

## General Observations
- ...
```

---

## 🎯 Common Issues to Look For

### Fitness Industry Terminology

**English**:
- ✅ "Reps" (not "Repetitions")
- ✅ "Sets" (standard term)
- ✅ "PR" or "Personal Record" (both acceptable)
- ✅ "Cardio" (not "Aerobic Exercise" in casual context)

**Korean**:
- Check if "세트" (set) is more natural than "설정"
- Verify "횟수" (reps) vs "반복" usage
- Confirm "벤치프레스" vs "bench press" romanization

**Chinese**:
- Simplified vs Traditional character consistency
- Verify "组" (set) vs "次" (reps) usage
- Check if "健身房" vs "体育馆" for gym

**German**:
- Verify compound nouns (e.g., "Trainingsprotokoll")
- Check capitalization (all nouns capitalized)
- Confirm "Wiederholungen" vs "Reps"

**Spanish**:
- Spain Spanish vs Latin American Spanish
- Verify "repeticiones" vs "repes" informality
- Check "gimnasio" vs "gym" usage

### Grammar & Style

1. **Capitalization**:
   - English: Sentence case for UI ("Save changes")
   - German: Capitalize all nouns
   - Other languages: Follow local conventions

2. **Punctuation**:
   - Question marks: "Are you sure?" vs "Seguro?"
   - Exclamation marks: Use sparingly, match original intensity

3. **Formality**:
   - Japanese is moderately formal (です・ます体)
   - Match this tone in target language
   - Avoid overly casual or overly formal extremes

4. **Gender**:
   - Use gender-neutral language where possible
   - For languages with grammatical gender (ES, DE), choose appropriate default

---

## 📝 Submission Process

### Option 1: GitHub Pull Request (Recommended)
1. Fork the repository
2. Create a new branch: `translation-review-[lang]-[yourname]`
3. Edit the ARB file with your corrections
4. Commit with clear messages
5. Submit Pull Request with review notes

### Option 2: Issue Report
1. Create a new GitHub Issue
2. Title: "Translation Review: [Language]"
3. Attach your review document
4. Tag with `translation` label

### Option 3: Email
Send review document to: [Your project email]
Subject: "GYM MATCH Translation Review - [Language]"

---

## 💰 Compensation (If Applicable)

**Rate**: [To be determined]
**Payment Method**: [To be determined]
**Estimated Time**:
- HIGH priority review: 8-12 hours
- MEDIUM priority review: 4-6 hours
- LOW priority review: 2-3 hours
- Total: 14-21 hours per language

---

## 🏆 Quality Standards

### Excellent Translation
✅ Reads naturally to native speakers  
✅ Consistent terminology throughout  
✅ Grammatically flawless  
✅ Culturally appropriate  
✅ Matches original intent and tone

### Acceptable Translation
✅ Meaning is clear and correct  
✅ Grammar is mostly correct  
⚠️ May sound slightly unnatural  
⚠️ Minor consistency issues  

### Needs Improvement
❌ Unnatural phrasing  
❌ Inconsistent terminology  
❌ Grammatical errors  
❌ Misses original meaning  

---

## 📞 Contact & Support

**Questions?** Open a GitHub Discussion or contact:
- Project Manager: [Name/Email]
- Technical Lead: [Name/Email]
- Translation Coordinator: [Name/Email]

**Resources**:
- ARB Files: `lib/l10n/`
- Documentation: `MULTILINGUAL_*.md`
- GitHub Repo: https://github.com/aka209859-max/gym-tracker-flutter

---

## 🎉 Thank You!

Your native speaker expertise is invaluable for creating a truly global fitness app. Thank you for helping GYM MATCH serve users worldwide in their native languages! 💪🌍

