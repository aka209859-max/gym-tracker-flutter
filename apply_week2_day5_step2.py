#!/usr/bin/env python3
"""
Week 2 Day 5 Step 2 - String Replacement Script
ai_coaching_screen_tabbed.dart の6件を置換
"""

import re

FILE_PATH = 'lib/screens/workout/ai_coaching_screen_tabbed.dart'

# 置換パターン（6件）
REPLACEMENTS = [
    # 1. AI生成完了! ($statusMessage) - 1st occurrence
    {
        'old': r"content: Text\('AI生成完了! \(\$statusMessage\)'\)",
        'new': r"content: Text(AppLocalizations.of(context)!.ai_generationComplete(statusMessage))"
    },
    # 2. 🎁 AI機能1回分を獲得しました! - 1st occurrence
    {
        'old': r"content: Text\('🎁 AI機能1回分を獲得しました!'\)",
        'new': r"content: Text(AppLocalizations.of(context)!.ai_rewardEarned)"
    },
    # 3. AI予測完了! ($statusMessage)
    {
        'old': r"content: Text\('AI予測完了! \(\$statusMessage\)'\)",
        'new': r"content: Text(AppLocalizations.of(context)!.ai_predictionComplete(statusMessage))"
    },
    # 4. AI分析完了! ($statusMessage)
    {
        'old': r"content: Text\('AI分析完了! \(\$statusMessage\)'\)",
        'new': r"content: Text(AppLocalizations.of(context)!.ai_analysisComplete(statusMessage))"
    }
]

def main():
    with open(FILE_PATH, 'r', encoding='utf-8') as f:
        content = f.read()
    
    replacements_made = 0
    
    for i, replacement in enumerate(REPLACEMENTS, 1):
        old_pattern = replacement['old']
        new_text = replacement['new']
        
        # 置換実行（複数の一致がある場合は全て置換）
        new_content, count = re.subn(old_pattern, new_text, content)
        
        if count > 0:
            content = new_content
            replacements_made += count
            print(f"  ✓ Pattern {i}: {count} occurrence(s)")
        else:
            print(f"  ✗ Pattern {i}: No match found")
    
    # ファイルに書き戻し
    with open(FILE_PATH, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"\nWeek 2 Day 5 Step 2 - 文字列置換")
    print(f"File: {FILE_PATH}")
    print(f"Total replacements: {replacements_made}")
    print(f"Note: Some patterns appear multiple times in the file")

if __name__ == '__main__':
    main()
