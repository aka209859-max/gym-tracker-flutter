#!/bin/bash
# iOS Build Preparation Script
# This script should be run BEFORE flutter build ipa
set -e

echo "🚀 iOS Build Preparation"
echo "========================"
echo ""

# Step 1: Clean previous builds
echo "📦 Step 1: Cleaning previous builds..."
flutter clean
echo "✅ Clean completed"
echo ""

# Step 2: Get dependencies
echo "📦 Step 2: Getting Flutter dependencies..."
flutter pub get
echo "✅ Dependencies installed"
echo ""

# Step 3: Generate localizations
echo "🌍 Step 3: Generating localization files..."
flutter gen-l10n || {
  echo "⚠️  flutter gen-l10n failed, but continuing..."
  echo "Note: If 'generate: true' is set in pubspec.yaml,"
  echo "      localization files should be auto-generated."
}
echo ""

# Step 4: Verify generated files
echo "🔍 Step 4: Verifying generated localization files..."
if [ -d ".dart_tool/flutter_gen/gen_l10n" ]; then
  echo "✅ Localization files generated:"
  ls -la .dart_tool/flutter_gen/gen_l10n/ || true
else
  echo "⚠️  .dart_tool/flutter_gen/gen_l10n/ not found"
  echo "This may cause build failures!"
fi
echo ""

# Step 5: iOS-specific setup
echo "🍎 Step 5: iOS-specific setup..."
cd ios
echo "  Removing old CocoaPods cache..."
rm -rf Pods
rm -rf ~/Library/Caches/CocoaPods
rm -rf Podfile.lock
echo "  Installing CocoaPods..."
pod install --repo-update
cd ..
echo "✅ iOS setup completed"
echo ""

echo "🎉 Build preparation completed successfully!"
echo ""
echo "You can now run:"
echo "  flutter build ipa --release"
