#!/usr/bin/env python3
"""
Week 2 Day 4 Step 1 - String Replacement Script
profile_screen.dart の最初の5件（静的文字列）を置換
"""

import re

FILE_PATH = 'lib/screens/profile_screen.dart'

# 置換パターン（静的文字列5件）
REPLACEMENTS = [
    # 1. 📸 写真から取り込み
    {
        'old': r"Text\('📸 写真から取り込み'\)",
        'new': r"Text(AppLocalizations.of(context)!.profile_importFromPhoto)"
    },
    # 2. 📄 CSVから取り込み
    {
        'old': r"Text\('📄 CSVから取り込み'\)",
        'new': r"Text(AppLocalizations.of(context)!.profile_importFromCSV)"
    },
    # 3. ファイルサイズが大きすぎます
    {
        'old': r"Text\('❌ ファイルサイズが大きすぎます（5MB以下）'\)",
        'new': r"Text(AppLocalizations.of(context)!.profile_fileSizeTooLarge)"
    },
    # 4. CSVファイルを解析しています
    {
        'old': r"Text\('CSVファイルを解析しています\.\.\.'\)",
        'new': r"Text(AppLocalizations.of(context)!.profile_parsingCSV)"
    },
    # 5. 6言語対応
    {
        'old': r"Text\('6言語対応 - グローバル展開中'\)",
        'new': r"Text(AppLocalizations.of(context)!.profile_multiLanguageSupport)"
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
    
    print(f"Week 2 Day 4 Step 1 - 文字列置換（静的文字列）")
    print(f"File: {FILE_PATH}")
    print(f"Replacements: {replacements_made}")
    print("\nReplaced strings:")
    print("1. 📸 写真から取り込み")
    print("2. 📄 CSVから取り込み")
    print("3. ❌ ファイルサイズが大きすぎます")
    print("4. CSVファイルを解析しています...")
    print("5. 6言語対応 - グローバル展開中")

if __name__ == '__main__':
    main()
