# Translation Scripts

This directory contains scripts for managing translations in the GYM MATCH app.

## 📄 Files

### `translate_arb.py`
Automated translation script using Google Cloud Translation API.

**Purpose**: Translate ARB files from Japanese to 6 target languages (EN, ES, KO, ZH, ZH_TW, DE)

**Features**:
- ✅ Batch translation via Google Cloud Translation API
- ✅ Preserves existing high-quality manual translations
- ✅ 100% coverage for all target languages
- ✅ Zero cost (within Google's perpetual free tier)
- ✅ Professional translation quality

---

## 🚀 Usage

### Prerequisites

1. **Google Cloud Project Setup**
   - Create project at https://console.cloud.google.com/
   - Enable "Cloud Translation API"
   - Create service account with "Cloud Translation API User" role
   - Download JSON key file

2. **Install Dependencies**
   ```bash
   pip3 install google-cloud-translate==3.15.0
   ```

3. **Set Environment Variable**
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your-key.json"
   ```

---

### Running the Translation Script

#### Basic Usage
```bash
# From project root
cd /home/user/webapp
python3 scripts/translate_arb.py
```

#### With Custom API Key Path
```bash
# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/gym-match-key.json"

# Run script
python3 scripts/translate_arb.py
```

#### Expected Output
```
🌍 Starting complete ARB translation via Google Cloud Translation API
📖 Source: lib/l10n/app_ja.arb (964 keys)

🔄 Translating to English (en)...
✅ English: 964/964 keys (100%) - 69 new translations

🔄 Translating to Spanish (es)...
✅ Spanish: 964/964 keys (100%) - 319 new translations

🔄 Translating to Korean (ko)...
✅ Korean: 964/964 keys (100%) - 216 new translations

🔄 Translating to Chinese Simplified (zh)...
✅ Chinese (Simplified): 964/964 keys (100%) - 627 new translations

🔄 Translating to Chinese Traditional (zh_TW)...
✅ Chinese (Traditional): 964/964 keys (100%) - 654 new translations

🔄 Translating to German (de)...
✅ German: 964/964 keys (100%) - 337 new translations

🎉 Translation complete! All 6 languages now have 100% coverage.
```

---

## 📋 Translation Workflow

### Adding New Translation Keys

Follow this workflow when adding new features that require translation:

#### 1. Add Keys to Japanese ARB
```bash
# Edit the source ARB file
vim lib/l10n/app_ja.arb
```

Add your new keys in Japanese:
```json
{
  "@@locale": "ja",
  "newFeatureTitle": "新機能のタイトル",
  "newFeatureDescription": "新機能の説明文",
  ...
}
```

#### 2. Run Translation Script
```bash
# Translate to all 6 languages automatically
python3 scripts/translate_arb.py
```

This will:
- ✅ Detect new keys in `app_ja.arb`
- ✅ Translate them to all 6 target languages
- ✅ Preserve existing translations
- ✅ Update all ARB files with 100% coverage

#### 3. Generate Flutter Localization Code
```bash
# Generate Dart code from ARB files
flutter gen-l10n
```

#### 4. Verify Translations
```bash
# Check that all languages have the same key count
for lang in en es ko zh zh_TW de; do
  echo -n "app_${lang}.arb: "
  grep -c '"[^@]' lib/l10n/app_${lang}.arb
done
```

Expected output (all should show same count):
```
app_en.arb: 964
app_es.arb: 964
app_ko.arb: 964
app_zh.arb: 964
app_zh_TW.arb: 964
app_de.arb: 964
```

#### 5. Test in App
```bash
# Clean build
flutter clean
flutter pub get

# Run app and test each language
flutter run
```

#### 6. Commit Changes
```bash
# Stage all ARB files
git add lib/l10n/*.arb

# Commit with descriptive message
git commit -m "feat(i18n): Add translations for new feature XYZ

- Added 5 new translation keys
- Translated to all 7 languages (JA/EN/ES/KO/ZH/ZH_TW/DE)
- Coverage: 100% for all languages"

# Push to remote
git push origin main
```

---

## 💰 Cost Information

### Google Cloud Translation API Pricing

#### Free Tier (Permanent)
- **Quota**: 500,000 characters/month
- **Cost**: $0
- **Reset**: Monthly (perpetual)

#### Paid Tier (if exceeded)
- **Cost**: $20 per 1 million characters
- **Unlikely**: Our usage is <5% of free tier

#### Our Usage Pattern
- **Initial Translation**: ~15,348 characters (3% of free tier)
- **Monthly Maintenance**: ~3,000 characters (0.6% of free tier)
- **Annual Total**: ~36,000 characters (7.2% of free tier)

**Result**: $0 cost indefinitely ✅

---

## 🔧 Troubleshooting

### Error: "Authentication failed"
```bash
# Solution: Set environment variable correctly
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your-key.json"

# Verify it's set
echo $GOOGLE_APPLICATION_CREDENTIALS
```

### Error: "google.cloud.translate not found"
```bash
# Solution: Install the SDK
pip3 install google-cloud-translate==3.15.0
```

### Error: "API not enabled"
```bash
# Solution: Enable Cloud Translation API
# Visit: https://console.cloud.google.com/apis/library/translate.googleapis.com
# Click "Enable"
```

### Error: "Insufficient permissions"
```bash
# Solution: Grant correct role to service account
# Role needed: "Cloud Translation API User" (roles/cloudtranslate.user)
# Visit: https://console.cloud.google.com/iam-admin/serviceaccounts
```

### Translation Quality Issues
```bash
# Solution: Manual review and override
# 1. Edit specific key in target ARB file
# 2. Script will preserve your manual translation
# 3. Re-run script - your edits won't be overwritten
```

---

## 📊 Translation Statistics

### Current Coverage (as of v1.0.303+325)

| Language | Code | Keys | Coverage | Status |
|----------|------|------|----------|--------|
| Japanese | ja | 964 | 100% | ✅ SOURCE |
| English | en | 964 | 100% | ✅ Perfect |
| Spanish | es | 964 | 100% | ✅ Perfect |
| Korean | ko | 964 | 100% | ✅ Perfect |
| Chinese (Simplified) | zh | 964 | 100% | ✅ Perfect |
| Chinese (Traditional) | zh_TW | 964 | 100% | ✅ Perfect |
| German | de | 964 | 100% | ✅ Perfect |

**Total**: 6,748 translation keys (964 × 7 languages)

---

## 🎯 Best Practices

### 1. Always Use Japanese as Source
- Japanese (`app_ja.arb`) is the authoritative source
- All translations derive from Japanese
- Never translate from English/other languages

### 2. Preserve Manual High-Quality Translations
- The script preserves existing translations
- Override API translations manually if needed
- Script won't overwrite your manual edits

### 3. Keep Keys Consistent
- Use descriptive, meaningful key names
- Follow camelCase convention (e.g., `workoutDetail`, `addNote`)
- Group related keys with prefixes (e.g., `note*`, `workout*`)

### 4. Add Metadata for Placeholders
```json
{
  "welcomeMessage": "こんにちは、{username}さん！",
  "@welcomeMessage": {
    "placeholders": {
      "username": {
        "type": "String"
      }
    }
  }
}
```

### 5. Test All Languages
- Don't just test Japanese and English
- Verify all 7 languages render correctly
- Check for UI layout issues with longer translations

### 6. Regular Maintenance
- Run translation script after adding new keys
- Keep all languages at 100% coverage
- Review translation quality periodically

---

## 📝 Script Maintenance

### Updating Target Languages

To add a new language (e.g., French):

1. Edit `scripts/translate_arb.py`
2. Add to `target_languages` dictionary:
   ```python
   target_languages = {
       'en': 'en',
       'es': 'es',
       'ko': 'ko',
       'zh': 'zh-CN',
       'zh_TW': 'zh-TW',
       'de': 'de',
       'fr': 'fr',  # NEW: French
   }
   ```
3. Create empty ARB file:
   ```bash
   echo '{"@@locale": "fr"}' > lib/l10n/app_fr.arb
   ```
4. Run translation script:
   ```bash
   python3 scripts/translate_arb.py
   ```

### Updating Translation API

If Google changes their API:

1. Check new SDK version:
   ```bash
   pip3 search google-cloud-translate
   ```
2. Update requirements:
   ```bash
   pip3 install google-cloud-translate==<new-version>
   ```
3. Test script:
   ```bash
   python3 scripts/translate_arb.py
   ```

---

## 🔗 Resources

- **Google Cloud Console**: https://console.cloud.google.com/
- **Cloud Translation API Docs**: https://cloud.google.com/translate/docs
- **Flutter Internationalization**: https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
- **ARB Format Spec**: https://github.com/google/app-resource-bundle

---

## 📄 Version History

- **v1.0.303** (2025-12-23): Initial API-based translation implementation
  - Achieved 100% coverage for all 6 non-Japanese languages
  - Eliminated all Japanese fallback text
  - Reduced translation time from hours to minutes

---

**Last Updated**: 2025-12-23  
**Maintained By**: GYM MATCH Development Team  
**Status**: ✅ Production Ready
