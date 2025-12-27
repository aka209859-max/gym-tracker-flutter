#!/usr/bin/env python3
"""
Week 2 Day 5 Step 1b - String Replacement Script
simple_workout_detail_screen.dart の残り6件を置換
"""

import re

FILE_PATH = 'lib/screens/workout/simple_workout_detail_screen.dart'

# 置換パターン（残り6件）
REPLACEMENTS = [
    # 1. 📊 削除後のセット数: ${afterDeleteSets.length}
    {
        'old': r"Text\('📊 削除後のセット数: \$\{afterDeleteSets\.length\}', style: TextStyle\(fontSize: 11, fontWeight: FontWeight\.bold, color: afterDeleteSets\.isEmpty \? Colors\.red : Colors\.green\)\)",
        'new': r"Text(AppLocalizations.of(context)!.workout_debugAfterDeleteSetsCount(afterDeleteSets.length), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: afterDeleteSets.isEmpty ? Colors.red : Colors.green))"
    },
    # 2. 🔍 セット詳細:
    {
        'old': r"Text\('🔍 セット詳細:', style: TextStyle\(fontSize: 11, color: Colors\.grey\[700\], fontWeight: FontWeight\.bold\)\)",
        'new': r"Text(AppLocalizations.of(context)!.workout_debugSetDetails, style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.bold))"
    },
    # 3. ⚠️ exercises フィールド検出: ${exercises.runtimeType}
    {
        'old': r"Text\('⚠️ exercises フィールド検出: \$\{exercises\.runtimeType\}',",
        'new': r"Text(AppLocalizations.of(context)!.workout_debugExercisesField(exercises.runtimeType.toString()),"
    },
    # 4. ⚠️ 全削除防止
    {
        'old': r"child: Text\('⚠️ 全削除防止'\)",
        'new': r"child: Text(AppLocalizations.of(context)!.workout_preventFullDelete)"
    },
    # 5. 「$exerciseName」を削除しました（残り${remainingExerciseNames}種目）
    {
        'old': r"content: Text\('「\$exerciseName」を削除しました（残り\$\{remainingExerciseNames\}種目）'\)",
        'new': r"content: Text(AppLocalizations.of(context)!.workout_exerciseDeletedWithCount(exerciseName, remainingExerciseNames))"
    },
    # 6. 「$exerciseName」を削除しました（残り${exercises.length}種目）
    {
        'old': r"content: Text\('「\$exerciseName」を削除しました（残り\$\{exercises\.length\}種目）'\)",
        'new': r"content: Text(AppLocalizations.of(context)!.workout_exerciseDeletedWithCountNum(exerciseName, exercises.length))"
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
    
    print(f"\nWeek 2 Day 5 Step 1b - 文字列置換")
    print(f"File: {FILE_PATH}")
    print(f"Total replacements: {replacements_made}/6")

if __name__ == '__main__':
    main()
