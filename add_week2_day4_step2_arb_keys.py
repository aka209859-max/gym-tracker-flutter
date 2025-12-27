#!/usr/bin/env python3
"""
Week 2 Day 4 Step 2 - ARB Keys Addition Script  
profile_screen.dart の次の4件（変数補間あり）
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

# 新しいARBキー（変数補間4件）
NEW_KEYS = {
    'ja': {
        'profile_imageAnalysisError': '❌ 画像解析エラー: {error}',
        '@profile_imageAnalysisError': {
            'description': '画像解析失敗時のエラーメッセージ',
            'placeholders': {
                'error': {
                    'type': 'String',
                    'example': 'Invalid format'
                }
            }
        },
        'profile_csvParseError': '❌ CSV解析エラー: {error}',
        '@profile_csvParseError': {
            'description': 'CSV解析失敗時のエラーメッセージ',
            'placeholders': {
                'error': {
                    'type': 'String',
                    'example': 'Invalid CSV format'
                }
            }
        },
        'profile_codeCopied': '✅ コードをコピーしました！',
        'profile_shareMessageCopied': '✅ シェア用メッセージをコピーしました！'
    },
    'en': {
        'profile_imageAnalysisError': '❌ Image analysis error: {error}',
        'profile_csvParseError': '❌ CSV parse error: {error}',
        'profile_codeCopied': '✅ Code copied!',
        'profile_shareMessageCopied': '✅ Share message copied!'
    },
    'ko': {
        'profile_imageAnalysisError': '❌ 이미지 분석 오류: {error}',
        'profile_csvParseError': '❌ CSV 분석 오류: {error}',
        'profile_codeCopied': '✅ 코드를 복사했습니다!',
        'profile_shareMessageCopied': '✅ 공유 메시지를 복사했습니다!'
    },
    'zh': {
        'profile_imageAnalysisError': '❌ 图片分析错误：{error}',
        'profile_csvParseError': '❌ CSV解析错误：{error}',
        'profile_codeCopied': '✅ 代码已复制！',
        'profile_shareMessageCopied': '✅ 分享消息已复制！'
    },
    'zh_TW': {
        'profile_imageAnalysisError': '❌ 圖片分析錯誤：{error}',
        'profile_csvParseError': '❌ CSV解析錯誤：{error}',
        'profile_codeCopied': '✅ 代碼已複製！',
        'profile_shareMessageCopied': '✅ 分享訊息已複製！'
    },
    'de': {
        'profile_imageAnalysisError': '❌ Bildanalysefehler: {error}',
        'profile_csvParseError': '❌ CSV-Analysefehler: {error}',
        'profile_codeCopied': '✅ Code kopiert!',
        'profile_shareMessageCopied': '✅ Teilnachricht kopiert!'
    },
    'es': {
        'profile_imageAnalysisError': '❌ Error de análisis de imagen: {error}',
        'profile_csvParseError': '❌ Error de análisis CSV: {error}',
        'profile_codeCopied': '✅ ¡Código copiado!',
        'profile_shareMessageCopied': '✅ ¡Mensaje compartido copiado!'
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
                if not key.startswith('@'):
                    total_added += 1
        
        # ファイルに書き戻し
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"Week 2 Day 4 Step 2 - ARBキー追加（変数補間あり）")
    print(f"Total: {total_added} keys added (4 keys × 7 languages = 28 entries)")
    print("\nNew ARB keys:")
    print("1. profile_imageAnalysisError(error)")
    print("2. profile_csvParseError(error)")
    print("3. profile_codeCopied")
    print("4. profile_shareMessageCopied")

if __name__ == '__main__':
    main()
