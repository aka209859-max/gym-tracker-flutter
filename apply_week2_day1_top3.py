#!/usr/bin/env python3
"""
Week 2 Day 1 - Pattern A replacement for Top 3 files
Target files:
1. ai_coaching_screen_tabbed.dart (13 strings)
2. add_workout_screen.dart (10 strings)
3. profile_screen.dart (10 strings)
"""

import re
import sys

# Mapping: Japanese string → ARB key
REPLACEMENTS = {
    # ai_coaching_screen_tabbed.dart
    "'動画でAI機能解放'": "AppLocalizations.of(context)!.workout_80a340fe",  # 動画でAI機能解放
    "'広告を読み込んでいます...'": "AppLocalizations.of(context)!.workout_65c94ed8",  # 広告を読み込んでいます...
    "'画面遷移に失敗しました": "AppLocalizations.of(context)!.general_navigationError",  # Need to check ARB
    "'保存に失敗しました": "AppLocalizations.of(context)!.saveWorkoutError",  # 保存に失敗しました
    "'有効な1RMを入力してください'": "AppLocalizations.of(context)!.workout_199dd9c4",  # 有効な1RMを入力してください
    "'アップグレード'": "AppLocalizations.of(context)!.subscription_upgrade",  # Need to check ARB
    "'設定する'": "AppLocalizations.of(context)!.general_set",  # Need to check ARB
    "'分析結果がありません'": "AppLocalizations.of(context)!.workout_noAnalysisResults",  # Need to check ARB
    
    # add_workout_screen.dart
    "'オフライン保存エラー": "AppLocalizations.of(context)!.workout_offlineSaveError",  # Need to check ARB
    "'記録を反映しました": "AppLocalizations.of(context)!.workout_recordApplied",  # New key needed
    "'履歴の取得に失敗しました": "AppLocalizations.of(context)!.workout_historyFetchError",  # Need to check ARB
    "'この日は既にオフ日として登録されています'": "AppLocalizations.of(context)!.workout_alreadyRestDay",  # Need to check ARB
    "'オフ日の保存に失敗しました": "AppLocalizations.of(context)!.workout_restDaySaveError",  # Need to check ARB
    "'通常'": "AppLocalizations.of(context)!.workout_normal",  # 通常
    "'試してみる'": "AppLocalizations.of(context)!.general_tryIt",  # New key needed
    
    # profile_screen.dart
    "'データ取り込み'": "AppLocalizations.of(context)!.profile_dataImport",  # Need to check ARB
    "'画像を解析しています...'": "AppLocalizations.of(context)!.profile_analyzingImage",  # New key needed
    "'画像解析エラー": "AppLocalizations.of(context)!.profile_imageAnalysisError",  # Need to check ARB
    "'ファイルサイズが大きすぎます（5MB以下）'": "AppLocalizations.of(context)!.profile_fileSizeTooLarge",  # Need to check ARB
    "'CSV解析エラー": "AppLocalizations.of(context)!.profile_csvParseError",  # Need to check ARB
    "'コードをコピーしました！'": "AppLocalizations.of(context)!.general_codeCopied",  # Need to check ARB
    "'シェア用メッセージをコピーしました！'": "AppLocalizations.of(context)!.general_shareMessageCopied",  # Need to check ARB
    "'エラー'": "AppLocalizations.of(context)!.general_error",  # エラー
}

def replace_strings_in_file(file_path):
    """Replace Japanese strings with AppLocalizations in a file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        replacements_made = 0
        
        for jp_string, arb_call in REPLACEMENTS.items():
            # Pattern 1: Text('...')
            pattern1 = rf"Text\({re.escape(jp_string)}\)"
            replacement1 = f"Text({arb_call})"
            content, count1 = re.subn(pattern1, replacement1, content)
            replacements_made += count1
            
            # Pattern 2: content: Text('...')
            pattern2 = rf"content:\s*Text\({re.escape(jp_string)}\)"
            replacement2 = f"content: Text({arb_call})"
            content, count2 = re.subn(pattern2, replacement2, content)
            replacements_made += count2
            
            # Pattern 3: label: Text('...')
            pattern3 = rf"label:\s*(?:const\s+)?Text\({re.escape(jp_string)}\)"
            replacement3 = f"label: Text({arb_call})"
            content, count3 = re.subn(pattern3, replacement3, content)
            replacements_made += count3
            
            # Pattern 4: child: Text('...')
            pattern4 = rf"child:\s*(?:const\s+)?Text\({re.escape(jp_string)}\)"
            replacement4 = f"child: Text({arb_call})"
            content, count4 = re.subn(pattern4, replacement4, content)
            replacements_made += count4
            
            if count1 + count2 + count3 + count4 > 0:
                print(f"  ✅ {jp_string[:40]:40} → {arb_call.split('!')[-1]:30} ({count1+count2+count3+count4}x)")
        
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✅ {file_path}: {replacements_made} replacements made")
            return replacements_made
        else:
            print(f"⚠️  {file_path}: No changes")
            return 0
            
    except Exception as e:
        print(f"❌ Error processing {file_path}: {e}")
        return 0

def main():
    files = [
        'lib/screens/workout/ai_coaching_screen_tabbed.dart',
        'lib/screens/workout/add_workout_screen.dart',
        'lib/screens/profile_screen.dart',
    ]
    
    total_replacements = 0
    
    print("🚀 Week 2 Day 1 - Top 3 Files Pattern A Replacement\n")
    
    for file_path in files:
        print(f"\n📝 Processing: {file_path}")
        count = replace_strings_in_file(file_path)
        total_replacements += count
    
    print(f"\n✅ Total replacements: {total_replacements}")
    print(f"📊 Target: 33 strings")
    print(f"📈 Success rate: {total_replacements / 33 * 100:.1f}%")

if __name__ == "__main__":
    main()
