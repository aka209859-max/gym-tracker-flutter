#!/usr/bin/env python3
"""
Week 2 Day 3 Step 3 - String Replacement Script
add_workout_screen.dart の残り3件を置換
"""

import re

FILE_PATH = 'lib/screens/workout/add_workout_screen.dart'

# 置換パターン（残り3件）
REPLACEMENTS = [
    # 1. 削除確認メッセージ（改行あり）
    {
        'old': r"Text\('「\$exerciseName」を削除しますか？\\nこの操作は取り消せません。'\)",
        'new': r"Text(AppLocalizations.of(context)!.workout_deleteConfirm(exerciseName))"
    },
    # 2. 削除成功メッセージ
    {
        'old': r"Text\('「\$exerciseName」を削除しました'\)",
        'new': r"Text(AppLocalizations.of(context)!.workout_deleteSuccess(exerciseName))"
    },
    # 3. カスタム種目保存メッセージ（$result）
    {
        'old': r"Text\('「\$result」をカスタム種目として保存しました'\)",
        'new': r"Text(AppLocalizations.of(context)!.workout_customExerciseSaved(result))"
    }
]

def main():
    with open(FILE_PATH, 'r', encoding='utf-8') as f:
        content = f.read()
    
    replacements_made = 0
    
    for replacement in REPLACEMENTS:
        old_pattern = replacement['old']
        new_text = replacement['new']
        
        # 置換実行
        new_content, count = re.subn(old_pattern, new_text, content)
        
        if count > 0:
            content = new_content
            replacements_made += count
    
    # ファイルに書き戻し
    with open(FILE_PATH, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Week 2 Day 3 Step 3 - 文字列置換（残り3件）")
    print(f"File: {FILE_PATH}")
    print(f"Replacements: {replacements_made}")
    print("\nReplaced strings:")
    print("1. 削除確認メッセージ (exerciseName)")
    print("2. 削除成功メッセージ (exerciseName)")
    print("3. カスタム種目保存メッセージ (result → exerciseName)")

if __name__ == '__main__':
    main()
