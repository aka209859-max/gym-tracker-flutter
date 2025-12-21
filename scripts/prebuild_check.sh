#!/bin/bash
# Pre-build validation script for GYM MATCH iOS
set -e

echo "🔍 GYM MATCH Pre-Build Validation"
echo "=================================="
echo ""

# Check 1: Verify ARB files
echo "✅ Step 1: Verify ARB files"
for lang in ja en ko zh de es; do
  arb_file="lib/l10n/app_${lang}.arb"
  if [ -f "$arb_file" ]; then
    echo "  ✓ $arb_file exists"
    # Validate JSON
    if ! python3 -m json.tool "$arb_file" > /dev/null 2>&1; then
      echo "  ❌ $arb_file: Invalid JSON"
      exit 1
    fi
  else
    echo "  ❌ $arb_file: NOT FOUND"
    exit 1
  fi
done
echo ""

# Check 2: Verify l10n.yaml
echo "✅ Step 2: Verify l10n.yaml"
if [ -f "l10n.yaml" ]; then
  echo "  ✓ l10n.yaml exists"
  cat l10n.yaml | grep "arb-dir:" > /dev/null && echo "  ✓ arb-dir configured"
  cat l10n.yaml | grep "template-arb-file:" > /dev/null && echo "  ✓ template-arb-file configured"
else
  echo "  ❌ l10n.yaml NOT FOUND"
  exit 1
fi
echo ""

# Check 3: Verify pubspec.yaml
echo "✅ Step 3: Verify pubspec.yaml"
if grep -q "generate: true" pubspec.yaml; then
  echo "  ✓ generate: true is set"
else
  echo "  ❌ generate: true NOT FOUND"
  exit 1
fi

if grep -q "flutter_localizations:" pubspec.yaml; then
  echo "  ✓ flutter_localizations is included"
else
  echo "  ❌ flutter_localizations NOT FOUND"
  exit 1
fi
echo ""

# Check 4: iOS project structure
echo "✅ Step 4: Verify iOS project structure"
if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
  echo "  ✓ Xcode project exists"
else
  echo "  ❌ Xcode project NOT FOUND"
  exit 1
fi

if [ -f "ios/Podfile" ]; then
  echo "  ✓ Podfile exists"
else
  echo "  ❌ Podfile NOT FOUND"
  exit 1
fi
echo ""

# Check 5: Verify main.dart configuration
echo "✅ Step 5: Verify main.dart localization setup"
if grep -q "localizationsDelegates:" lib/main.dart; then
  echo "  ✓ localizationsDelegates configured"
else
  echo "  ⚠️  localizationsDelegates NOT FOUND (may cause runtime errors)"
fi

if grep -q "supportedLocales:" lib/main.dart; then
  echo "  ✓ supportedLocales configured"
else
  echo "  ⚠️  supportedLocales NOT FOUND (may cause runtime errors)"
fi
echo ""

echo "🎉 All pre-build checks passed!"
echo ""
echo "Next steps:"
echo "1. Run: flutter pub get"
echo "2. Verify generated files: lib/.dart_tool/flutter_gen/gen_l10n/"
echo "3. Run: flutter build ipa --release"
