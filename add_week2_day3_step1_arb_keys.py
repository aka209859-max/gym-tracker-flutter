#!/usr/bin/env python3
"""
Week 2 Day 3 Step 1 - 最初の5件ARBキー追加
============================================
確実に動作する静的文字列から開始
"""

import json
from pathlib import Path

# 最初の5件（シンプルな順）
new_keys = {
    # 3. 静的文字列（変数なし）- 最も安全
    "workout_offlineSaved": "📴 オフライン保存しました\nオンライン復帰時に自動同期されます",
    
    # 11-13. アイコン文字列 - 超安全
    "workout_iconAI": "🤖",
    "workout_iconIdea": "💡",
    "workout_iconStats": "📊",
    
    # 10. 単純な変数補間（1個）
    "workout_setsCopied": "{count}セットをコピーしました",
}

# メタデータ
metadata = {
    "@workout_offlineSaved": {
        "description": "オフライン保存完了メッセージ"
    },
    "@workout_iconAI": {
        "description": "AIアイコン絵文字"
    },
    "@workout_iconIdea": {
        "description": "アイデアアイコン絵文字"
    },
    "@workout_iconStats": {
        "description": "統計アイコン絵文字"
    },
    "@workout_setsCopied": {
        "description": "セットコピー完了メッセージ",
        "placeholders": {
            "count": {
                "type": "int"
            }
        }
    }
}

# 翻訳（Google翻訳ベース）
translations = {
    "en": {
        "workout_offlineSaved": "📴 Saved offline\nWill sync automatically when back online",
        "workout_iconAI": "🤖",
        "workout_iconIdea": "💡",
        "workout_iconStats": "📊",
        "workout_setsCopied": "{count} sets copied",
    },
    "ko": {
        "workout_offlineSaved": "📴 오프라인으로 저장됨\n온라인 복귀 시 자동 동기화됩니다",
        "workout_iconAI": "🤖",
        "workout_iconIdea": "💡",
        "workout_iconStats": "📊",
        "workout_setsCopied": "{count}세트 복사됨",
    },
    "zh": {
        "workout_offlineSaved": "📴 已离线保存\n恢复在线时将自动同步",
        "workout_iconAI": "🤖",
        "workout_iconIdea": "💡",
        "workout_iconStats": "📊",
        "workout_setsCopied": "已复制{count}组",
    },
    "zh_TW": {
        "workout_offlineSaved": "📴 已離線儲存\n恢復線上時將自動同步",
        "workout_iconAI": "🤖",
        "workout_iconIdea": "💡",
        "workout_iconStats": "📊",
        "workout_setsCopied": "已複製{count}組",
    },
    "de": {
        "workout_offlineSaved": "📴 Offline gespeichert\nWird automatisch synchronisiert, wenn wieder online",
        "workout_iconAI": "🤖",
        "workout_iconIdea": "💡",
        "workout_iconStats": "📊",
        "workout_setsCopied": "{count} Sätze kopiert",
    },
    "es": {
        "workout_offlineSaved": "📴 Guardado sin conexión\nSe sincronizará automáticamente al volver a conectarse",
        "workout_iconAI": "🤖",
        "workout_iconIdea": "💡",
        "workout_iconStats": "📊",
        "workout_setsCopied": "{count} series copiadas",
    }
}

def add_keys_to_arb(locale: str, keys: dict, meta: dict = None):
    """ARBファイルにキーを追加"""
    arb_file = Path(f"lib/l10n/app_{locale}.arb")
    
    with open(arb_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # 新規キー追加
    for key, value in keys.items():
        data[key] = value
    
    # メタデータ追加（日本語のみ）
    if locale == "ja" and meta:
        for meta_key, meta_value in meta.items():
            data[meta_key] = meta_value
    
    # 書き込み
    with open(arb_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"✓ {arb_file}: {len(keys)}件追加")

def main():
    print("=" * 80)
    print("Week 2 Day 3 Step 1 - ARBキー追加（最初の5件）")
    print("=" * 80)
    print()
    
    # 日本語（メタデータ含む）
    print("[1/7] 日本語（メタデータ含む）...")
    add_keys_to_arb("ja", new_keys, metadata)
    
    # 他言語
    locales = ["en", "ko", "zh", "zh_TW", "de", "es"]
    for i, locale in enumerate(locales, 2):
        print(f"[{i}/7] {locale}...")
        add_keys_to_arb(locale, translations[locale])
    
    print()
    print("=" * 80)
    print("✓ 完了!")
    print(f"  追加キー: 5個")
    print(f"  対象言語: 7言語")
    print(f"  合計: 5 × 7 = 35エントリ")
    print("=" * 80)

if __name__ == '__main__':
    main()
