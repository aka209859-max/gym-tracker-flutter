#!/bin/bash
echo "🔍 日本語ハードコードを検索中..."

# Phase 4で復元したファイルから日本語文字列を検索
FILES=(
  "lib/services/habit_formation_service.dart"
  "lib/services/subscription_management_service.dart"
  "lib/screens/workout_import_preview_screen.dart"
  "lib/screens/profile_edit_screen.dart"
  "lib/providers/locale_provider.dart"
)

count=0
for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    matches=$(grep -o "'[ぁ-ん一-龯ァ-ヶー]*'" "$file" 2>/dev/null | wc -l)
    if [ $matches -gt 0 ]; then
      echo "📄 $file: $matches 箇所"
      grep -n "'[ぁ-ん一-龯ァ-ヶー]*'" "$file" | head -3
      echo ""
      count=$((count + matches))
    fi
  fi
done

echo "合計: $count 箇所の日本語ハードコードが残存"
