#!/bin/bash
# エラー修正テンプレート

ERROR_FILE="$1"  # 例: lib/screens/partner/partner_search_screen_new.dart
ERROR_LINE="$2"  # 例: 145

echo "📍 エラー箇所の確認"
echo "File: $ERROR_FILE"
echo "Line: $ERROR_LINE"
echo ""

# エラー周辺のコードを表示
echo "📝 エラー周辺のコード (±5行):"
START=$((ERROR_LINE - 5))
END=$((ERROR_LINE + 5))
sed -n "${START},${END}p" "$ERROR_FILE" | nl -v "$START"

echo ""
echo "🔍 次のステップ:"
echo "1. 上記のコードで 'AppLocalizations.of(context)' が static const 内にないか確認"
echo "2. フィールド初期化で 'context' を使っていないか確認"
echo "3. 'const' が不要な箇所にないか確認"
