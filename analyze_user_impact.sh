#!/bin/bash
echo "🔍 ユーザー影響度分析"
echo "================================"
echo ""

# 各ファイルの日本語ハードコードとユーザー可視性を分析

echo "📱 1. locale_provider.dart (2箇所)"
echo "   影響: ⭐⭐⭐⭐⭐ CRITICAL"
echo "   場所: 言語切り替えメニュー"
echo "   表示: 設定画面で「日本語」と表示"
grep -n "name: '日本語'" lib/providers/locale_provider.dart | head -1
echo ""

echo "📱 2. subscription_management_service.dart (14箇所)"
echo "   影響: ⭐⭐⭐⭐ HIGH"
echo "   場所: サブスクリプション解約理由の選択肢"
echo "   表示: 解約画面のドロップダウン"
grep -n "'料金が高い'" lib/services/subscription_management_service.dart | head -3
echo ""

echo "📱 3. profile_edit_screen.dart (59箇所)"
echo "   影響: ⭐⭐⭐⭐ HIGH"
echo "   場所: プロフィール編集の都道府県選択"
echo "   表示: 「北海道」「東京都」など47都道府県"
grep -n "'北海道'" lib/screens/profile_edit_screen.dart | head -1
echo ""

echo "📱 4. workout_import_preview_screen.dart (76箇所)"
echo "   影響: ⭐⭐⭐ MEDIUM"
echo "   場所: トレーニング部位選択"
echo "   表示: 「胸」「脚」「背中」など"
grep -n "'胸'" lib/screens/workout_import_preview_screen.dart | head -1
echo ""

echo "📱 5. habit_formation_service.dart (9箇所)"
echo "   影響: ⭐⭐ LOW"
echo "   場所: バックエンドロジック（曜日名など）"
echo "   表示: ログや内部処理（ユーザーには直接見えない可能性）"
grep -n "'月曜日'" lib/services/habit_formation_service.dart | head -1
echo ""

echo "================================"
echo "📊 優先度サマリー:"
echo "  🔴 CRITICAL: 1ファイル (2箇所)"
echo "  🟠 HIGH: 2ファイル (73箇所)"
echo "  🟡 MEDIUM: 1ファイル (76箇所)"
echo "  🟢 LOW: 1ファイル (9箇所)"
