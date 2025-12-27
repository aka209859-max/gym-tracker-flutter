#!/usr/bin/env python3
"""
Week 2 Day 4 Step 3 - String Replacement Script
subscription_screen.dart の10件を置換
"""

import re

FILE_PATH = 'lib/screens/subscription_screen.dart'

# 置換パターン（10件）
REPLACEMENTS = [
    # 1. プラン管理 (title)
    {
        'old': r"title: Text\('プラン管理'\)",
        'new': r"title: Text(AppLocalizations.of(context)!.subscription_planManagement)"
    },
    # 2. 利用規約を開けませんでした
    {
        'old': r"Text\('利用規約を開けませんでした'\)",
        'new': r"Text(AppLocalizations.of(context)!.subscription_termsOpenFailed)"
    },
    # 3. 無料プランへの変更は...
    {
        'old': r"Text\('無料プランへの変更は、App Store設定でサブスクリプションをキャンセルしてください'\)",
        'new': r"Text(AppLocalizations.of(context)!.subscription_cancelInAppStore)"
    },
    # 4. 購入に失敗しました
    {
        'old': r"Text\('購入に失敗しました: \$\{e\.toString\(\)\}'\)",
        'new': r"Text(AppLocalizations.of(context)!.subscription_purchaseFailed(e.toString()))"
    },
    # 5. 復元に失敗しました
    {
        'old': r"Text\('復元に失敗しました: \$\{e\.toString\(\)\}'\)",
        'new': r"Text(AppLocalizations.of(context)!.subscription_restoreFailed(e.toString()))"
    },
    # 6. $targetPlanName に変更
    {
        'old': r"Text\('\$targetPlanName に変更'\)",
        'new': r"Text(AppLocalizations.of(context)!.subscription_changeTo(targetPlanName))"
    },
    # 7. $targetPlanName に変更すると...
    {
        'old': r"Text\('\$targetPlanName に変更すると、以下の機能が制限されます：'\)",
        'new': r"Text(AppLocalizations.of(context)!.subscription_changeWarning(targetPlanName))"
    },
    # 8. App Store設定から...
    {
        'old': r"Text\('App Store設定から\$targetPlanNameへ変更してください'\)",
        'new': r"Text(AppLocalizations.of(context)!.subscription_changeInAppStore(targetPlanName))"
    },
    # 9. 1. iPhoneの「設定」アプリを開く
    {
        'old': r"Text\('1\. iPhoneの「設定」アプリを開く'\)",
        'new': r"Text(AppLocalizations.of(context)!.subscription_step1)"
    },
    # 10. 2. 一番上の[Apple ID]をタップ
    {
        'old': r"Text\('2\. 一番上の\[Apple ID\]をタップ'\)",
        'new': r"Text(AppLocalizations.of(context)!.subscription_step2)"
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
    
    print(f"\nWeek 2 Day 4 Step 3 - 文字列置換")
    print(f"File: {FILE_PATH}")
    print(f"Total replacements: {replacements_made}/10")

if __name__ == '__main__':
    main()
