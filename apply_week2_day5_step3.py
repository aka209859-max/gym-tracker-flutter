#!/usr/bin/env python3
"""
Week 2 Day 5 Step 3 - String Replacement Script
gym_review_screen.dart の6件を置換
"""

import re

FILE_PATH = 'lib/screens/gym_review_screen.dart'

# 置換パターン（6件）
REPLACEMENTS = [
    # 1. レビュー投稿に失敗しました: $e
    {
        'old': r"content: Text\('レビュー投稿に失敗しました: \$e'\)",
        'new': r"content: Text(AppLocalizations.of(context)!.gym_reviewPostFailed(e.toString()))"
    },
    # 2. Premium機能
    {
        'old': r"Text\('Premium機能'\)",
        'new': r"Text(AppLocalizations.of(context)!.gym_premiumFeature)"
    },
    # 3. • ジムレビューの投稿
    {
        'old': r"Text\('• ジムレビューの投稿', style: TextStyle\(fontSize: 14\)\)",
        'new': r"Text(AppLocalizations.of(context)!.gym_reviewFeature, style: const TextStyle(fontSize: 14))"
    },
    # 4. • AI機能を月10回使用
    {
        'old': r"Text\('• AI機能を月10回使用', style: TextStyle\(fontSize: 14\)\)",
        'new': r"Text(AppLocalizations.of(context)!.gym_aiUsageLimit, style: const TextStyle(fontSize: 14))"
    },
    # 5. • お気に入り無制限
    {
        'old': r"Text\('• お気に入り無制限', style: TextStyle\(fontSize: 14\)\)",
        'new': r"Text(AppLocalizations.of(context)!.gym_unlimitedFavorites, style: const TextStyle(fontSize: 14))"
    },
    # 6. • 詳細な混雑度統計
    {
        'old': r"Text\('• 詳細な混雑度統計', style: TextStyle\(fontSize: 14\)\)",
        'new': r"Text(AppLocalizations.of(context)!.gym_detailedStats, style: const TextStyle(fontSize: 14))"
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
    
    print(f"\nWeek 2 Day 5 Step 3 - 文字列置換")
    print(f"File: {FILE_PATH}")
    print(f"Total replacements: {replacements_made}/6")

if __name__ == '__main__':
    main()
