#!/bin/bash
echo "🔍 不足しているキーを特定中..."

# 日本語ARBのすべてのキーを抽出
jq -r 'keys[]' lib/l10n/app_ja.arb | grep -v "^@" | sort > /tmp/ja_keys.txt

# 各言語で不足しているキーをチェック
for lang in en ko zh de es zh_TW; do
  echo ""
  echo "📊 $lang の不足キー:"
  jq -r 'keys[]' lib/l10n/app_$lang.arb | grep -v "^@" | sort > /tmp/${lang}_keys.txt
  missing=$(comm -23 /tmp/ja_keys.txt /tmp/${lang}_keys.txt | wc -l)
  echo "不足数: $missing"
  
  if [ $missing -gt 0 ] && [ $missing -le 10 ]; then
    echo "不足キー一覧:"
    comm -23 /tmp/ja_keys.txt /tmp/${lang}_keys.txt | head -10
  fi
done

rm /tmp/*_keys.txt
