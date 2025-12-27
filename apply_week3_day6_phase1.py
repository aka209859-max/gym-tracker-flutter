#!/usr/bin/env python3
"""
Week 3 Day 6 Phase 1 - String Replacement Script
developer_menu_screen.dart の10件を置換
"""

import re

FILE_PATH = 'lib/screens/developer_menu_screen.dart'

# 置換パターン（10件）
REPLACEMENTS = [
    # 1. ✅ UIDをコピーしました\n$_currentUserUid
    {
        'old': r"Text\('✅ UIDをコピーしました\\n\$_currentUserUid'\)",
        'new': r"Text(AppLocalizations.of(context)!.dev_uidCopied(_currentUserUid))"
    },
    # 2. ✅ AI使用回数をリセットしました
    {
        'old': r"Text\('✅ AI使用回数をリセットしました'\)",
        'new': r"Text(AppLocalizations.of(context)!.dev_aiUsageReset)"
    },
    # 3. ❌ リセット失敗: $e (3 occurrences)
    {
        'old': r"Text\('❌ リセット失敗: \$e'\)",
        'new': r"Text(AppLocalizations.of(context)!.dev_resetFailed(e.toString()))"
    },
    # 4. ✅ オンボーディングをリセットしました\nアプリを再起動してください
    {
        'old': r"Text\('✅ オンボーディングをリセットしました\\nアプリを再起動してください'\)",
        'new': r"Text(AppLocalizations.of(context)!.dev_onboardingReset)"
    },
    # 5. ✅ Phase 1機能をすべてリセットしました\nアプリを再起動してください
    {
        'old': r"Text\('✅ Phase 1機能をすべてリセットしました\\nアプリを再起動してください'\)",
        'new': r"Text(AppLocalizations.of(context)!.dev_phase1Reset)"
    },
    # 6. AI使用回数をリセット (label)
    {
        'old': r"label: const Text\('AI使用回数をリセット'\)",
        'new': r"label: Text(AppLocalizations.of(context)!.dev_resetAiUsage)"
    },
    # 7. オンボーディングをリセット (label)
    {
        'old': r"label: const Text\('オンボーディングをリセット'\)",
        'new': r"label: Text(AppLocalizations.of(context)!.dev_resetOnboarding)"
    },
    # 8. Phase 1機能をすべてリセット (label)
    {
        'old': r"label: const Text\('Phase 1機能をすべてリセット'\)",
        'new': r"label: Text(AppLocalizations.of(context)!.dev_resetPhase1)"
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
            print(f"  ✓ Pattern {i}: {count} occurrence(s)")
        else:
            print(f"  ✗ Pattern {i}: No match found")
    
    # ファイルに書き戻し
    with open(FILE_PATH, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"\nWeek 3 Day 6 Phase 1 - 文字列置換")
    print(f"File: {FILE_PATH}")
    print(f"Total replacements: {replacements_made}")

if __name__ == '__main__':
    main()
