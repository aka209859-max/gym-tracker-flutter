#!/usr/bin/env python3
"""
Week 2 Day 1 - Add new ARB keys for Top 3 files
Adds 17 new keys to all 7 language ARB files
"""

import json
import sys

# New ARB keys to add (Japanese values)
NEW_KEYS = {
    # ai_coaching_screen.tabbed.dart (3 keys)
    "general_navigationError": "画面遷移に失敗しました",
    "general_configure": "設定する",
    "workout_noAnalysisResults": "分析結果がありません",
    
    # add_workout_screen.dart (7 keys)
    "workout_offlineSaveError": "オフライン保存エラー",
    "workout_recordApplied": "記録を反映しました",
    "workout_historyFetchError": "履歴の取得に失敗しました",
    "workout_alreadyRestDay": "この日は既にオフ日として登録されています",
    "workout_restDaySaveError": "オフ日の保存に失敗しました",
    "workout_normal": "通常",
    "general_tryIt": "試してみる",
    
    # profile_screen.dart (7 keys)
    "profile_dataImport": "データ取り込み",
    "profile_analyzingImage": "画像を解析しています...",
    "profile_imageAnalysisError": "画像解析エラー",
    "profile_csvParseError": "CSV解析エラー",
    "general_codeCopied": "コードをコピーしました！",
    "general_shareMessageCopied": "シェア用メッセージをコピーしました！",
    "general_fileSizeTooLarge": "ファイルサイズが大きすぎます（5MB以下）",
}

# Language files to update
LANG_FILES = {
    'ja': 'lib/l10n/app_ja.arb',
    'en': 'lib/l10n/app_en.arb',
    'ko': 'lib/l10n/app_ko.arb',
    'zh': 'lib/l10n/app_zh.arb',
    'zh_TW': 'lib/l10n/app_zh_TW.arb',
    'de': 'lib/l10n/app_de.arb',
    'es': 'lib/l10n/app_es.arb',
}

# English translations (for non-Japanese files)
ENGLISH_TRANSLATIONS = {
    "general_navigationError": "Screen transition failed",
    "general_configure": "Configure",
    "workout_noAnalysisResults": "No analysis results",
    "workout_offlineSaveError": "Offline save error",
    "workout_recordApplied": "Record applied",
    "workout_historyFetchError": "Failed to fetch history",
    "workout_alreadyRestDay": "This day is already registered as a rest day",
    "workout_restDaySaveError": "Failed to save rest day",
    "workout_normal": "Normal",
    "general_tryIt": "Try it",
    "profile_dataImport": "Data Import",
    "profile_analyzingImage": "Analyzing image...",
    "profile_imageAnalysisError": "Image analysis error",
    "profile_csvParseError": "CSV parse error",
    "general_codeCopied": "Code copied!",
    "general_shareMessageCopied": "Share message copied!",
    "general_fileSizeTooLarge": "File size too large (5MB or less)",
}

def add_keys_to_arb(file_path, lang_code, dry_run=False):
    """Add new keys to an ARB file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            arb = json.load(f)
        
        added = 0
        skipped = 0
        
        for key, ja_value in NEW_KEYS.items():
            if key in arb:
                skipped += 1
                continue
            
            # Use English translation for non-Japanese files
            value = ja_value if lang_code == 'ja' else ENGLISH_TRANSLATIONS[key]
            arb[key] = value
            added += 1
        
        if added > 0 and not dry_run:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(arb, f, ensure_ascii=False, indent=2)
        
        return added, skipped
        
    except Exception as e:
        print(f"  ❌ Error processing {file_path}: {e}")
        return 0, 0

def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--dry-run', action='store_true', help='Dry run (no files modified)')
    args = parser.parse_args()
    
    print("🚀 Week 2 Day 1 - Add New ARB Keys")
    print(f"{'🔵 DRY-RUN MODE' if args.dry_run else '✅ LIVE MODE'}\n")
    print(f"📋 Adding {len(NEW_KEYS)} new keys to 7 language files...\n")
    
    total_added = 0
    total_skipped = 0
    
    for lang_code, file_path in LANG_FILES.items():
        added, skipped = add_keys_to_arb(file_path, lang_code, args.dry_run)
        total_added += added
        total_skipped += skipped
        
        status = "🔵" if args.dry_run else "✅"
        print(f"{status} {lang_code:6} ({file_path:35}): +{added:2} keys, {skipped:2} skipped")
    
    print(f"\n{'='*70}")
    print(f"📊 Summary:")
    print(f"   Total keys added: {total_added}")
    print(f"   Total keys skipped (already exist): {total_skipped}")
    print(f"   {'Mode: DRY-RUN' if args.dry_run else 'Mode: LIVE'}")
    print(f"{'='*70}\n")
    
    if args.dry_run:
        print("💡 Run without --dry-run to apply changes")
    else:
        print("✅ ARB keys added successfully!")
        print("📋 Next step: Run replacement script")

if __name__ == "__main__":
    main()
