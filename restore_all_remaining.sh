#!/bin/bash
# Phase 4以前の正しいバージョンから復元

# 最初に各ファイルの正しいコミットを特定
declare -A FILES_MAP=(
  ["lib/models/training_partner.dart"]="768b631"
  ["lib/models/review.dart"]="768b631"
  ["lib/screens/partner/partner_search_screen_new.dart"]="768b631"
)

echo "🔄 Phase 4破壊ファイルを復元中..."

for file in "${!FILES_MAP[@]}"; do
  commit="${FILES_MAP[$file]}"
  echo "復元: $file from $commit"
  git show "$commit:$file" > "$file"
  if [ $? -eq 0 ]; then
    echo "  ✅ 成功"
  else
    echo "  ❌ 失敗"
  fi
done

echo ""
echo "✅ 復元完了"
