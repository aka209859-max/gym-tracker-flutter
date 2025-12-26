#!/usr/bin/env python3
"""
Week 2 Day 2 Phase 1: Replace static strings with existing ARB keys
Target: 23 strings across 5 files
"""
import re
import sys

# Mapping of exact strings to ARB keys
MAPPINGS = {
    # home_screen.dart
    "記録を削除": "deleteWorkoutConfirm",
    "編集機能は次のアップデートで実装予定です": "general_d2802ea4",
    "🔬 セッションRPE入力": "general_9bef87b7",
    "🔬 疲労度分析結果": "general_2b363a80",
    "🔬 総合疲労度分析": "general_9879fe60",
    "6言語対応 - グローバル展開中": "profile_d15e7de3",
    
    # goals_screen.dart
    "新しい目標": "general_6b0cabf8",
    "目標値を変更": "general_fbfd31d9",
    "目標タイプ": "general_654c46cb",
    "週間トレーニング回数": "general_e9b451c8",
    "月間総重量": "general_12bffb53",
    "目標値を更新しました": "general_583ed93e",
    
    # body_measurement_screen.dart
    "体重または体脂肪率を入力してください": "general_6d12fd22",
    "体重・体脂肪率": "profileBodyWeight",
    "全て": "general_3582fe36",
    
    # reward_ad_dialog.dart
    "キャンセル": "cancel",
    "動画を見る": "general_3968b846",
    
    # ai_coaching_screen.dart
    "• AI機能を月10回まで使用可能": "workout_302d148c",
    "• 広告なしで快適に利用": "workout_18419fdb",
    "• 30日間無料トライアル": "workout_995040b8",
    "• AI機能を5回追加": "workout_940a74d8",
    "• 今月末まで有効": "workout_d9fd4ff4",
    "• いつでも追加購入可能": "workout_fdf1a277",
}

FILES = {
    "lib/screens/home_screen.dart": [
        ("記録を削除", "deleteWorkoutConfirm"),
        ("編集機能は次のアップデートで実装予定です", "general_d2802ea4"),
        ("🔬 セッションRPE入力", "general_9bef87b7"),
        ("🔬 疲労度分析結果", "general_2b363a80"),
        ("🔬 総合疲労度分析", "general_9879fe60"),
        ("6言語対応 - グローバル展開中", "profile_d15e7de3"),
    ],
    "lib/screens/goals_screen.dart": [
        ("新しい目標", "general_6b0cabf8"),
        ("目標値を変更", "general_fbfd31d9"),
        ("目標タイプ", "general_654c46cb"),
        ("週間トレーニング回数", "general_e9b451c8"),
        ("月間総重量", "general_12bffb53"),
        ("目標値を更新しました", "general_583ed93e"),
    ],
    "lib/screens/body_measurement_screen.dart": [
        ("体重または体脂肪率を入力してください", "general_6d12fd22"),
        ("体重・体脂肪率", "profileBodyWeight"),
        ("全て", "general_3582fe36"),
    ],
    "lib/widgets/reward_ad_dialog.dart": [
        ("キャンセル", "cancel"),
        ("動画を見る", "general_3968b846"),
    ],
    "lib/screens/workout/ai_coaching_screen.dart": [
        ("• AI機能を月10回まで使用可能", "workout_302d148c"),
        ("• 広告なしで快適に利用", "workout_18419fdb"),
        ("• 30日間無料トライアル", "workout_995040b8"),
        ("• AI機能を5回追加", "workout_940a74d8"),
        ("• 今月末まで有効", "workout_d9fd4ff4"),
        ("• いつでも追加購入可能", "workout_fdf1a277"),
    ],
}

def replace_in_file(file_path, replacements):
    """Replace strings in a file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        replacements_made = 0
        
        for old_string, arb_key in replacements:
            # Pattern 1: Text('string')
            pattern1 = f"Text\\('{re.escape(old_string)}'\\)"
            replacement1 = f"Text(AppLocalizations.of(context)!.{arb_key})"
            if re.search(pattern1, content):
                content = re.sub(pattern1, replacement1, content)
                replacements_made += 1
                print(f"  ✓ Replaced: '{old_string}' → {arb_key}")
            
            # Pattern 2: const Text('string')
            pattern2 = f"const Text\\('{re.escape(old_string)}'\\)"
            replacement2 = f"Text(AppLocalizations.of(context)!.{arb_key})"
            if re.search(pattern2, content):
                content = re.sub(pattern2, replacement2, content)
                replacements_made += 1
                print(f"  ✓ Replaced: 'const {old_string}' → {arb_key}")
        
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return replacements_made
        return 0
    
    except Exception as e:
        print(f"  ❌ Error processing {file_path}: {e}")
        return 0

def main():
    total_replacements = 0
    
    print("=" * 70)
    print("Week 2 Day 2 Phase 1: Static String Replacement")
    print("=" * 70)
    print()
    
    for file_path, replacements in FILES.items():
        print(f"Processing: {file_path}")
        count = replace_in_file(file_path, replacements)
        total_replacements += count
        print(f"  Replaced: {count}/{len(replacements)} strings")
        print()
    
    print("=" * 70)
    print(f"Total replacements: {total_replacements}")
    print("=" * 70)
    
    return 0 if total_replacements > 0 else 1

if __name__ == "__main__":
    sys.exit(main())
