#!/usr/bin/env python3
import json
import sys

# Load ARB file
with open('lib/l10n/app_ja.arb', 'r', encoding='utf-8') as f:
    arb_data = json.load(f)

# Static labels and buttons to check
static_strings = [
    "記録を削除",
    "編集機能は次のアップデートで実装予定です",
    "🔬 セッションRPE入力",
    "🔬 疲労度分析結果",
    "🔬 総合疲労度分析",
    "6言語対応 - グローバル展開中",
    "新しい目標",
    "目標値を変更",
    "目標タイプ",
    "週間トレーニング回数",
    "月間総重量",
    "目標値を更新しました",
    "体重または体脂肪率を入力してください",
    "体重・体脂肪率",
    "全て",
    "✅ AIクレジット1回分を獲得しました！（テストモード）",
    "✅ AIクレジット1回分を獲得しました！",
    "キャンセル",
    "動画を見る",
    "• AI機能を月10回まで使用可能",
    "• 広告なしで快適に利用",
    "• 30日間無料トライアル",
    "• AI機能を5回追加",
    "• 今月末まで有効",
    "• いつでも追加購入可能",
]

found = []
not_found = []

for string in static_strings:
    matched = False
    for key, value in arb_data.items():
        if key.startswith('@'):
            continue
        if isinstance(value, str) and (value == string or string in value):
            found.append((string, key, value))
            matched = True
            break
    if not matched:
        not_found.append(string)

print(f"✅ Found: {len(found)}/{len(static_strings)}")
print(f"❌ Not found: {len(not_found)}/{len(static_strings)}")
print()

if found:
    print("=" * 60)
    print("FOUND MAPPINGS:")
    print("=" * 60)
    for string, key, value in found:
        print(f"'{string}' → {key}")
        if value != string:
            print(f"  ARB value: '{value}'")
        print()

if not_found:
    print("=" * 60)
    print("NOT FOUND (need new ARB keys):")
    print("=" * 60)
    for string in not_found:
        print(f"- {string}")
