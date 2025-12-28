#!/usr/bin/env python3
"""
Week 3 Day 6 Phase 2: add_workout_screen_complete.dart の文字列置換

対象: 5件の文字列
"""

import re

FILE_PATH = "lib/screens/workout/add_workout_screen_complete.dart"

def apply_replacements():
    """文字列置換を適用"""
    
    with open(FILE_PATH, 'r', encoding='utf-8') as f:
        content = f.read()
    
    replacements = [
        # 1. AIコーチから読み込み (行168)
        (
            r"SnackBar\(content: Text\('AIコーチから\$\{exercises\.length\}種目を読み込みました'\)\)",
            r"SnackBar(content: Text(AppLocalizations.of(context)!.workout_aiCoachLoaded(exercises.length)))"
        ),
        # 2. 休憩時間の秒数 (行327)
        (
            r"title: Text\('\$\{duration\}秒'\)",
            r"title: Text(AppLocalizations.of(context)!.workout_restDurationSeconds(duration))"
        ),
        # 3. セットコピー (行398)
        (
            r"SnackBar\(content: Text\('\$\{exerciseSets\.length\}セットをコピーしました'\)\)",
            r"SnackBar(content: Text(AppLocalizations.of(context)!.workout_setsCopiedCount(exerciseSets.length)))"
        ),
        # 4. 休憩秒数表示 (行492)
        (
            r"'休憩 \$_restSeconds秒'",
            r"AppLocalizations.of(context)!.workout_restSeconds(_restSeconds)"
        ),
        # 5. カスタム種目追加 (行581)
        (
            r"label: Text\('種目を追加（カスタム）'\)",
            r"label: Text(AppLocalizations.of(context)!.workout_addCustomExercise)"
        ),
    ]
    
    replaced_count = 0
    for i, (pattern, replacement) in enumerate(replacements, 1):
        new_content = re.sub(pattern, replacement, content)
        if new_content != content:
            replaced_count += 1
            print(f"✅ Pattern {i}: 置換成功")
        else:
            print(f"⚠️  Pattern {i}: マッチなし")
        content = new_content
    
    # ファイルに書き込み
    with open(FILE_PATH, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"\n🎉 Week 2 Day 6 Phase 2 - 文字列置換")
    print(f"File: {FILE_PATH}")
    print(f"Total replacements: {replaced_count}/{len(replacements)}")

if __name__ == "__main__":
    apply_replacements()
