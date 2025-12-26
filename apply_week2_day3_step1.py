#!/usr/bin/env python3
"""
Week 2 Day 3 Step 1 - add_workout_screen.dart 置換（5件）
========================================================
"""

import re

def replace_in_file(file_path: str, replacements: list) -> int:
    """ファイル内の文字列を置換"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    count = 0
    
    for desc, old, new in replacements:
        matches = list(re.finditer(re.escape(old), content))
        if matches:
            print(f"  ✓ {desc}: {len(matches)}箇所")
            content = content.replace(old, new)
            count += len(matches)
        else:
            print(f"  ⚠️  {desc}: 見つかりません")
    
    if content != original:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return count
    return 0

def main():
    print("=" * 80)
    print("Week 2 Day 3 Step 1 - 文字列置換（5件）")
    print("=" * 80)
    print()
    
    file_path = "lib/screens/workout/add_workout_screen.dart"
    
    # 置換パターン（位置引数を使用！）
    replacements = [
        # 1. オフライン保存（line 550）- 静的
        (
            "オフライン保存メッセージ",
            "Text('📴 オフライン保存しました\\nオンライン復帰時に自動同期されます')",
            "Text(AppLocalizations.of(context)!.workout_offlineSaved)"
        ),
        
        # 2. セットコピー（line 1560）- 変数1個
        (
            "セットコピー通知",
            "Text('${exerciseSets.length}セットをコピーしました')",
            "Text(AppLocalizations.of(context)!.workout_setsCopied(exerciseSets.length))"
        ),
        
        # 3-5. アイコン（lines 2178, 2242, 2267）- 静的
        (
            "AIアイコン",
            "Text('🤖', style: TextStyle(fontSize: 16))",
            "Text(AppLocalizations.of(context)!.workout_iconAI, style: TextStyle(fontSize: 16))"
        ),
        (
            "アイデアアイコン",
            "Text('💡', style: TextStyle(fontSize: 16))",
            "Text(AppLocalizations.of(context)!.workout_iconIdea, style: TextStyle(fontSize: 16))"
        ),
        (
            "統計アイコン",
            "Text('📊', style: TextStyle(fontSize: 16))",
            "Text(AppLocalizations.of(context)!.workout_iconStats, style: TextStyle(fontSize: 16))"
        ),
    ]
    
    print(f"対象ファイル: {file_path}")
    print()
    
    count = replace_in_file(file_path, replacements)
    
    print()
    print("=" * 80)
    if count > 0:
        print(f"✓ 完了! {count}箇所を置換しました")
    else:
        print("⚠️  置換箇所が見つかりませんでした")
    print("=" * 80)

if __name__ == '__main__':
    main()
