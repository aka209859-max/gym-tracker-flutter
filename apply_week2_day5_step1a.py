#!/usr/bin/env python3
"""
Week 2 Day 5 Step 1a - String Replacement Script
simple_workout_detail_screen.dart の最初の6件を置換
"""

import re

FILE_PATH = 'lib/screens/workout/simple_workout_detail_screen.dart'

# 置換パターン（6件）
REPLACEMENTS = [
    # 1. 🔍 削除デバッグ
    {
        'old': r"title: Text\('🔍 削除デバッグ'\)",
        'new': r"title: Text(AppLocalizations.of(context)!.workout_deleteDebug)"
    },
    # 2. 「$exerciseName」を削除しますか？
    {
        'old': r"Text\('「\$exerciseName」を削除しますか？'\)",
        'new': r"Text(AppLocalizations.of(context)!.workout_deleteConfirmExercise(exerciseName))"
    },
    # 3. 🎯 $targetInfo
    {
        'old': r"Text\('🎯 \$targetInfo', style: const TextStyle\(fontSize: 11, fontFamily: 'monospace'\)\)",
        'new': r"Text(AppLocalizations.of(context)!.workout_debugTargetInfo(targetInfo), style: const TextStyle(fontSize: 11, fontFamily: 'monospace'))"
    },
    # 4. 📊 現在の種目: ${currentExerciseNames.join(", ")}
    {
        'old': r"Text\('📊 現在の種目: \$\{currentExerciseNames\.join\(\", \"\)\}', style: const TextStyle\(fontSize: 11\)\)",
        'new': r"Text(AppLocalizations.of(context)!.workout_debugCurrentExercises(currentExerciseNames.join(\", \")), style: const TextStyle(fontSize: 11))"
    },
    # 5. 📊 削除後の種目: ${afterDeleteExerciseNames.join(", ")}
    {
        'old': r"Text\('📊 削除後の種目: \$\{afterDeleteExerciseNames\.join\(\", \"\)\}', style: const TextStyle\(fontSize: 11\)\)",
        'new': r"Text(AppLocalizations.of(context)!.workout_debugAfterDeleteExercises(afterDeleteExerciseNames.join(\", \")), style: const TextStyle(fontSize: 11))"
    },
    # 6. 📊 現在のセット数: ${sets.length}
    {
        'old': r"Text\('📊 現在のセット数: \$\{sets\.length\}', style: const TextStyle\(fontSize: 11\)\)",
        'new': r"Text(AppLocalizations.of(context)!.workout_debugCurrentSetsCount(sets.length), style: const TextStyle(fontSize: 11))"
    }
]

def main():
    with open(FILE_PATH, 'r', encoding='utf-8') as f:
        content = f.read()
    
    replacements_made = 0
    
    for i, replacement in enumerate(REPLACEMENTS, 1):
        old_pattern = replacement['old']
        new_text = replacement['new']
        
        # 置換実行
        new_content, count = re.subn(old_pattern, new_text, content)
        
        if count > 0:
            content = new_content
            replacements_made += count
            print(f"  ✓ Replacement {i}: {count} occurrence(s)")
        else:
            print(f"  ✗ Replacement {i}: No match found")
    
    # ファイルに書き戻し
    with open(FILE_PATH, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"\nWeek 2 Day 5 Step 1a - 文字列置換")
    print(f"File: {FILE_PATH}")
    print(f"Total replacements: {replacements_made}/6")

if __name__ == '__main__':
    main()
