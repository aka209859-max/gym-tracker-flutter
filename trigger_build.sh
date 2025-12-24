#!/bin/bash
# ビルドをトリガーするためのタグ作成スクリプト

# 現在の日付でタグを作成
TAG_NAME="v1.0.$(date +%Y%m%d-%H%M%S)"

echo "🏷️  Creating tag: $TAG_NAME"
git tag -a "$TAG_NAME" -m "Release build for 7-language support (100% complete)

- All 891 locations localized
- 7 languages fully supported: ja, en, de, es, ko, zh, zh_TW
- 3,335 ARB keys per language
- 0 ICU errors
- 0 hardcoded Japanese strings

Ready for TestFlight release."

echo "✅ Tag created: $TAG_NAME"
echo ""
echo "To trigger build, push the tag:"
echo "  git push origin $TAG_NAME"
echo ""
echo "This will start the iOS TestFlight Release workflow on GitHub Actions."
