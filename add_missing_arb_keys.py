#!/usr/bin/env python3
import json
import sys

# 追加するキーと値（各言語）
missing_keys = {
    "ja": {
        "showDetailsSection": "詳細セクションを表示",
        "weightRatio": "ウェイトレシオ",
        "frequency1to2": "週1-2回",
        "frequency3to4": "週3-4回"
    },
    "en": {
        "showDetailsSection": "Show Details Section",
        "weightRatio": "Weight Ratio",
        "frequency1to2": "1-2 times/week",
        "frequency3to4": "3-4 times/week"
    },
    "zh": {
        "showDetailsSection": "显示详细信息",
        "weightRatio": "重量比",
        "frequency1to2": "每周1-2次",
        "frequency3to4": "每周3-4次"
    },
    "zh_TW": {
        "showDetailsSection": "顯示詳細信息",
        "weightRatio": "重量比",
        "frequency1to2": "每週1-2次",
        "frequency3to4": "每週3-4次"
    },
    "ko": {
        "showDetailsSection": "세부 정보 표시",
        "weightRatio": "웨이트 비율",
        "frequency1to2": "주 1-2회",
        "frequency3to4": "주 3-4회"
    },
    "de": {
        "showDetailsSection": "Details anzeigen",
        "weightRatio": "Gewichtsverhältnis",
        "frequency1to2": "1-2 mal/Woche",
        "frequency3to4": "3-4 mal/Woche"
    },
    "es": {
        "showDetailsSection": "Mostrar detalles",
        "weightRatio": "Relación de peso",
        "frequency1to2": "1-2 veces/semana",
        "frequency3to4": "3-4 veces/semana"
    }
}

# 各ARBファイルを処理
arb_files = [
    ("lib/l10n/app_ja.arb", "ja"),
    ("lib/l10n/app_en.arb", "en"),
    ("lib/l10n/app_zh.arb", "zh"),
    ("lib/l10n/app_zh_TW.arb", "zh_TW"),
    ("lib/l10n/app_ko.arb", "ko"),
    ("lib/l10n/app_de.arb", "de"),
    ("lib/l10n/app_es.arb", "es")
]

for arb_file, lang_code in arb_files:
    try:
        # ARBファイルを読み込み
        with open(arb_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # 欠けているキーのみ追加
        added_keys = []
        for key, value in missing_keys[lang_code].items():
            if key not in data:
                data[key] = value
                added_keys.append(key)
        
        # ファイルに書き戻し（インデント2、UTF-8、改行なし）
        with open(arb_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        if added_keys:
            print(f"✅ {arb_file}: Added {len(added_keys)} keys: {', '.join(added_keys)}")
        else:
            print(f"ℹ️  {arb_file}: No missing keys (already exists)")
            
    except Exception as e:
        print(f"❌ Error processing {arb_file}: {e}")
        sys.exit(1)

print("\n🎉 All ARB files updated successfully!")
