#!/usr/bin/env python3
"""
Week 2 Day 3 - add_workout_screen.dart 文字列分析
================================================
13件の未翻訳文字列を分析してARBキー作成
"""

strings = [
    {
        "line": 254,
        "text": "AIコーチの推奨メニューを読み込みました ({count}種目)",
        "type": "notification",
        "placeholders": ["count"],
        "key": "workout_aiMenuLoaded"
    },
    {
        "line": 267,
        "text": "AIコーチデータの読み込みに失敗しました: {error}",
        "type": "error",
        "placeholders": ["error"],
        "key": "workout_aiMenuLoadFailed"
    },
    {
        "line": 550,
        "text": "📴 オフライン保存しました\\nオンライン復帰時に自動同期されます",
        "type": "notification",
        "placeholders": [],
        "key": "workout_offlineSaved"
    },
    {
        "line": 1126,
        "text": "{exerciseName}の履歴がありません",
        "type": "message",
        "placeholders": ["exerciseName"],
        "key": "workout_noHistory"
    },
    {
        "line": 1137,
        "text": "{exerciseName}の過去記録",
        "type": "title",
        "placeholders": ["exerciseName"],
        "key": "workout_pastRecords"
    },
    {
        "line": 1232,
        "text": "{exerciseName}の一括入力",
        "type": "title",
        "placeholders": ["exerciseName"],
        "key": "workout_bulkInput"
    },
    {
        "line": 1343,
        "text": "「{exerciseName}」を削除しますか？\\nこの操作は取り消せません。",
        "type": "confirmation",
        "placeholders": ["exerciseName"],
        "key": "workout_deleteConfirm"
    },
    {
        "line": 1367,
        "text": "「{exerciseName}」を削除しました",
        "type": "notification",
        "placeholders": ["exerciseName"],
        "key": "workout_deleteSuccess"
    },
    {
        "line": 1416,
        "text": "「{result}」をカスタム種目として保存しました",
        "type": "notification",
        "placeholders": ["result"],
        "key": "workout_customExerciseSaved"
    },
    {
        "line": 1560,
        "text": "{count}セットをコピーしました",
        "type": "notification",
        "placeholders": ["count"],
        "key": "workout_setsCopied"
    },
    {
        "line": 2178,
        "text": "🤖",
        "type": "icon",
        "placeholders": [],
        "key": "workout_iconAI"
    },
    {
        "line": 2242,
        "text": "💡",
        "type": "icon",
        "placeholders": [],
        "key": "workout_iconIdea"
    },
    {
        "line": 2267,
        "text": "📊",
        "type": "icon",
        "placeholders": [],
        "key": "workout_iconStats"
    }
]

print("=" * 80)
print("Week 2 Day 3 - add_workout_screen.dart 文字列分析")
print("=" * 80)
print(f"\n総数: {len(strings)}件\n")

print("ARBキー作成リスト:")
print("-" * 80)
for i, s in enumerate(strings, 1):
    print(f"{i}. {s['key']}")
    print(f"   原文: {s['text']}")
    print(f"   型: {s['type']}")
    if s['placeholders']:
        print(f"   プレースホルダー: {', '.join(s['placeholders'])}")
    print()

print("=" * 80)
print(f"新規ARBキー: {len(strings)}個")
print(f"7言語対応: {len(strings)} × 7 = {len(strings) * 7}個")
print("=" * 80)
