#!/bin/bash
echo "🔍 Phase 4破壊ファイルの完全スキャン（改良版）..."

FILES=$(git diff be85dff^..be85dff --name-only | grep "\.dart$")
BROKEN=()

for file in $FILES; do
  [ ! -f "$file" ] && continue
  
  # パターン1: static const + AppLocalizations (最も一般的)
  if grep -q "static const.*AppLocalizations\.of(context)" "$file" 2>/dev/null; then
    BROKEN+=("$file|static_const_applocal")
  fi
  
  # パターン2: Constant expression expected (= [] without const)
  if grep -q "= \[\]" "$file" 2>/dev/null && grep -q "const.*{" "$file" 2>/dev/null; then
    if [[ ! " ${BROKEN[@]} " =~ " ${file}|" ]]; then
      BROKEN+=("$file|const_expression")
    fi
  fi
  
  # パターン3: enum + AppLocalizations
  if grep -A 10 "enum " "$file" 2>/dev/null | grep -q "AppLocalizations\.of(context)"; then
    if [[ ! " ${BROKEN[@]} " =~ " ${file}|" ]]; then
      BROKEN+=("$file|enum_applocal")
    fi
  fi
done

echo "📊 発見された問題ファイル数: ${#BROKEN[@]}"
echo ""
for item in "${BROKEN[@]}"; do
  echo "❌ ${item/|/ - Pattern: }"
done

# 重複なしリスト
echo ""
echo "🔧 修正が必要なファイル（重複なし）:"
printf '%s\n' "${BROKEN[@]}" | cut -d'|' -f1 | sort -u
