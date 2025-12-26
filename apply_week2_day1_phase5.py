#!/usr/bin/env python3
"""
Week 2 Day 1 - Phase 5: Top 3 Files Replacement
Manual ARB key mapping with context-aware replacements
"""

import re
import sys

# ============================================================================
# FILE 1: ai_coaching_screen_tabbed.dart (8 unique strings)
# ============================================================================
MAPPINGS_AI_COACHING = {
    "'動画でAI機能解放'": "AppLocalizations.of(context)!.workout_80a340fe",
    "'広告を読み込んでいます...'": "AppLocalizations.of(context)!.workout_65c94ed8",
    "'画面遷移に失敗しました": "AppLocalizations.of(context)!.general_navigationError",  # Will add to ARB
    "'保存に失敗しました": "AppLocalizations.of(context)!.saveWorkoutError",
    "'有効な1RMを入力してください'": "AppLocalizations.of(context)!.workout_199dd9c4",
    "'アップグレード'": "AppLocalizations.of(context)!.upgradeToPremium",
    "'設定する'": "AppLocalizations.of(context)!.general_configure",  # Will add to ARB
    "'分析結果がありません'": "AppLocalizations.of(context)!.workout_noAnalysisResults",  # Will add to ARB
}

# ============================================================================
# FILE 2: add_workout_screen.dart (10 unique strings)
# ============================================================================
MAPPINGS_ADD_WORKOUT = {
    "'オフライン保存エラー": "AppLocalizations.of(context)!.workout_offlineSaveError",  # Will add to ARB
    "'記録を反映しました": "AppLocalizations.of(context)!.workout_recordApplied",  # Will add to ARB
    "'履歴の取得に失敗しました": "AppLocalizations.of(context)!.workout_historyFetchError",  # Will add to ARB
    "'この日は既にオフ日として登録されています'": "AppLocalizations.of(context)!.workout_alreadyRestDay",  # Will add to ARB
    "'オフ日の保存に失敗しました": "AppLocalizations.of(context)!.workout_restDaySaveError",  # Will add to ARB
    "'通常'": "AppLocalizations.of(context)!.workout_normal",  # Will add to ARB
    "'試してみる'": "AppLocalizations.of(context)!.general_tryIt",  # Will add to ARB
}

# ============================================================================
# FILE 3: profile_screen.dart (10 unique strings)
# ============================================================================
MAPPINGS_PROFILE = {
    "'データ取り込み'": "AppLocalizations.of(context)!.profile_dataImport",  # Will add to ARB
    "'画像を解析しています...'": "AppLocalizations.of(context)!.profile_analyzingImage",  # Will add to ARB
    "'画像解析エラー": "AppLocalizations.of(context)!.profile_imageAnalysisError",  # Will add to ARB
    "'CSV解析エラー": "AppLocalizations.of(context)!.profile_csvParseError",  # Will add to ARB
    "'コードをコピーしました！'": "AppLocalizations.of(context)!.general_codeCopied",  # Will add to ARB
    "'シェア用メッセージをコピーしました！'": "AppLocalizations.of(context)!.general_shareMessageCopied",  # Will add to ARB
}

def replace_in_file(file_path, mappings):
    """Replace strings in a file using the given mappings"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        replacements_made = 0
        
        for jp_string, arb_call in mappings.items():
            # Remove quotes from jp_string for matching
            jp_clean = jp_string.strip("'\"")
            
            # Pattern 1: Text('...') or Text("...")
            pattern1 = rf"Text\(['\"]({re.escape(jp_clean)}[^'\"]*)['\"]"
            
            def replace_text(match):
                full_string = match.group(1)
                if full_string == jp_clean:
                    return f"Text({arb_call}"
                else:
                    # String has variable interpolation like: $e
                    # Keep the interpolation
                    var_part = full_string[len(jp_clean):]
                    return f"Text({arb_call} + '{var_part}'"
            
            content, count = re.subn(pattern1, replace_text, content)
            
            if count > 0:
                replacements_made += count
                print(f"  ✅ {jp_clean[:35]:35} → {arb_call.split('.')[-1]:30} ({count}x)")
        
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return replacements_made
        else:
            return 0
            
    except Exception as e:
        print(f"  ❌ Error: {e}")
        return 0

def main():
    files_and_mappings = [
        ('lib/screens/workout/ai_coaching_screen_tabbed.dart', MAPPINGS_AI_COACHING),
        ('lib/screens/workout/add_workout_screen.dart', MAPPINGS_ADD_WORKOUT),
        ('lib/screens/profile_screen.dart', MAPPINGS_PROFILE),
    ]
    
    total_replacements = 0
    
    print("🚀 Week 2 Day 1 - Phase 5: Top 3 Files Replacement\n")
    print("⚠️  Note: Some ARB keys need to be added to app_ja.arb first!\n")
    
    for file_path, mappings in files_and_mappings:
        print(f"📝 {file_path}")
        count = replace_in_file(file_path, mappings)
        total_replacements += count
        print()
    
    print(f"{'='*70}")
    print(f"✅ Total replacements: {total_replacements}")
    print(f"🎯 Target: 33 strings")
    print(f"{'='*70}\n")
    
    print("📋 Next steps:")
    print("1. Add missing ARB keys to lib/l10n/app_ja.arb")
    print("2. Run this script again")
    print("3. Test compilation")
    print("4. Commit changes")

if __name__ == "__main__":
    main()
