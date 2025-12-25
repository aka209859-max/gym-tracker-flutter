#!/bin/bash
# Phase 4で変更されたすべてのファイルから問題パターンを検出

echo "🔍 Phase 4破壊ファイルの完全スキャン開始..."
echo ""

# Phase 4で変更されたすべてのDartファイルを取得
FILES=$(git diff be85dff^..be85dff --name-only | grep "\.dart$")

BROKEN_FILES=()
PATTERN_COUNTS=()

echo "対象ファイル数: $(echo "$FILES" | wc -l)"
echo ""

for file in $FILES; do
  if [ ! -f "$file" ]; then
    continue
  fi
  
  # パターン1: static const + AppLocalizations
  if grep -q "static const.*AppLocalizations\.of(context)" "$file" 2>/dev/null; then
    BROKEN_FILES+=("$file")
    PATTERN_COUNTS+=("Pattern1: static const + AppLocalizations")
    echo "❌ $file: static const + AppLocalizations"
  fi
  
  # パターン2: enum + AppLocalizations
  if grep -q "enum.*{" "$file" 2>/dev/null && grep -A 20 "enum.*{" "$file" | grep -q "AppLocalizations\.of(context)" 2>/dev/null; then
    if [[ ! " ${BROKEN_FILES[@]} " =~ " ${file} " ]]; then
      BROKEN_FILES+=("$file")
      PATTERN_COUNTS+=("Pattern2: enum + AppLocalizations")
      echo "❌ $file: enum + AppLocalizations"
    fi
  fi
  
  # パターン3: 閉じられていない文字列（'suggestedChange の後に AppLocalizations）
  if grep -q "'\]\['" "$file" 2>/dev/null && grep -q "AppLocalizations\.of(context)" "$file" 2>/dev/null; then
    if [[ ! " ${BROKEN_FILES[@]} " =~ " ${file} " ]]; then
      BROKEN_FILES+=("$file")
      PATTERN_COUNTS+=("Pattern3: Broken string + AppLocalizations")
      echo "❌ $file: Broken string concatenation"
    fi
  fi
done

echo ""
echo "📊 結果サマリー:"
echo "総スキャンファイル数: $(echo "$FILES" | wc -l)"
echo "問題ファイル数: ${#BROKEN_FILES[@]}"
echo ""

if [ ${#BROKEN_FILES[@]} -gt 0 ]; then
  echo "🔧 修正が必要なファイル一覧:"
  printf '%s\n' "${BROKEN_FILES[@]}" | sort -u
fi
