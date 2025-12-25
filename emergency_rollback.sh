#!/bin/bash
# 緊急ロールバックスクリプト

echo "🚨 緊急ロールバック戦略"
echo ""

# 過去の安全なコミットを表示
echo "📜 過去の安全なビルド成功コミット:"
git log --oneline --all --grep="SUCCESS\|COMPLETE\|READY" | head -5

echo ""
echo "🔄 ロールバック手順:"
echo "1. 安全なコミットを選択: git checkout <commit-hash>"
echo "2. 新しいブランチを作成: git checkout -b rollback-safe"
echo "3. 問題のあるファイルだけを再度修正"
echo "4. テストして push"

echo ""
echo "📋 現在のブランチの最近のコミット:"
git log --oneline -5

echo ""
echo "💡 推奨アクション:"
echo "- まず問題のファイルだけをPhase 4以前に戻す"
echo "- それでもダメなら、最後に成功したビルドまで完全ロールバック"
