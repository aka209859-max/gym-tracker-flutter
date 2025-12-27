#!/usr/bin/env python3
"""
Week 2 Day 4 Step 1 - ARB Keys Addition Script
profile_screen.dart の最初の5件（静的文字列）
"""

import json

# 7言語のファイルパス
LOCALES = {
    'ja': 'lib/l10n/app_ja.arb',
    'en': 'lib/l10n/app_en.arb',
    'ko': 'lib/l10n/app_ko.arb',
    'zh': 'lib/l10n/app_zh.arb',
    'zh_TW': 'lib/l10n/app_zh_TW.arb',
    'de': 'lib/l10n/app_de.arb',
    'es': 'lib/l10n/app_es.arb'
}

# 新しいARBキー（静的文字列5件）
NEW_KEYS = {
    'ja': {
        'profile_importFromPhoto': '📸 写真から取り込み',
        'profile_importFromCSV': '📄 CSVから取り込み',
        'profile_fileSizeTooLarge': '❌ ファイルサイズが大きすぎます（5MB以下）',
        'profile_parsingCSV': 'CSVファイルを解析しています...',
        'profile_multiLanguageSupport': '6言語対応 - グローバル展開中'
    },
    'en': {
        'profile_importFromPhoto': '📸 Import from Photo',
        'profile_importFromCSV': '📄 Import from CSV',
        'profile_fileSizeTooLarge': '❌ File size too large (5MB max)',
        'profile_parsingCSV': 'Parsing CSV file...',
        'profile_multiLanguageSupport': '6 Languages - Global Expansion'
    },
    'ko': {
        'profile_importFromPhoto': '📸 사진에서 가져오기',
        'profile_importFromCSV': '📄 CSV에서 가져오기',
        'profile_fileSizeTooLarge': '❌ 파일 크기가 너무 큽니다 (5MB 이하)',
        'profile_parsingCSV': 'CSV 파일 분석 중...',
        'profile_multiLanguageSupport': '6개 언어 지원 - 글로벌 확장'
    },
    'zh': {
        'profile_importFromPhoto': '📸 从照片导入',
        'profile_importFromCSV': '📄 从CSV导入',
        'profile_fileSizeTooLarge': '❌ 文件大小过大（最大5MB）',
        'profile_parsingCSV': '正在解析CSV文件...',
        'profile_multiLanguageSupport': '支持6种语言 - 全球扩张'
    },
    'zh_TW': {
        'profile_importFromPhoto': '📸 從照片匯入',
        'profile_importFromCSV': '📄 從CSV匯入',
        'profile_fileSizeTooLarge': '❌ 檔案大小過大（最大5MB）',
        'profile_parsingCSV': '正在解析CSV檔案...',
        'profile_multiLanguageSupport': '支援6種語言 - 全球擴張'
    },
    'de': {
        'profile_importFromPhoto': '📸 Aus Foto importieren',
        'profile_importFromCSV': '📄 Aus CSV importieren',
        'profile_fileSizeTooLarge': '❌ Dateigröße zu groß (max. 5MB)',
        'profile_parsingCSV': 'CSV-Datei wird analysiert...',
        'profile_multiLanguageSupport': '6 Sprachen - Globale Expansion'
    },
    'es': {
        'profile_importFromPhoto': '📸 Importar desde foto',
        'profile_importFromCSV': '📄 Importar desde CSV',
        'profile_fileSizeTooLarge': '❌ Tamaño de archivo demasiado grande (máx. 5MB)',
        'profile_parsingCSV': 'Analizando archivo CSV...',
        'profile_multiLanguageSupport': '6 idiomas - Expansión global'
    }
}

def main():
    total_added = 0
    
    for locale, filepath in LOCALES.items():
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # 新しいキーを追加
        keys_to_add = NEW_KEYS[locale]
        for key, value in keys_to_add.items():
            if key not in data:
                data[key] = value
                total_added += 1
        
        # ファイルに書き戻し
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"Week 2 Day 4 Step 1 - ARBキー追加（静的文字列）")
    print(f"Total: {total_added} keys added (5 keys × 7 languages = 35 entries)")
    print("\nNew ARB keys:")
    print("1. profile_importFromPhoto")
    print("2. profile_importFromCSV")
    print("3. profile_fileSizeTooLarge")
    print("4. profile_parsingCSV")
    print("5. profile_multiLanguageSupport")

if __name__ == '__main__':
    main()
