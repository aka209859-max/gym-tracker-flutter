#!/usr/bin/env python3
"""
Week 3 Day 6 Phase 3: calculators_screen.dart のARBキー追加

対象文字列: 5件
- 計算ツールのタイトル
- エラーメッセージ
- 1RM計算機の説明
"""

import json
import os

# ARBファイルのパス
ARB_DIR = "lib/l10n"
LANGUAGES = {
    "ja": "app_ja.arb",
    "en": "app_en.arb",
    "zh": "app_zh.arb",
    "ko": "app_ko.arb",
    "es": "app_es.arb",
    "de": "app_de.arb",
    "zh_TW": "app_zh_TW.arb"
}

# 新しいARBキーと翻訳
NEW_KEYS = {
    "calculators_title": {
        "ja": "計算ツール",
        "en": "Calculators",
        "zh": "计算工具",
        "ko": "계산 도구",
        "es": "Calculadoras",
        "de": "Rechner",
        "zh_TW": "計算工具"
    },
    "calculators_invalidInput": {
        "ja": "有効な重量と回数を入力してください",
        "en": "Please enter valid weight and reps",
        "zh": "请输入有效的重量和次数",
        "ko": "유효한 무게와 횟수를 입력하세요",
        "es": "Por favor ingrese peso y repeticiones válidos",
        "de": "Bitte geben Sie gültiges Gewicht und Wiederholungen ein",
        "zh_TW": "請輸入有效的重量和次數"
    },
    "calculators_oneRMCalculator": {
        "ja": "1RM計算機",
        "en": "1RM Calculator",
        "zh": "1RM计算器",
        "ko": "1RM 계산기",
        "es": "Calculadora 1RM",
        "de": "1RM-Rechner",
        "zh_TW": "1RM計算機"
    },
    "calculators_oneRMDescription": {
        "ja": "1RM (1 Rep Max) は、1回だけ持ち上げられる最大重量です。\nEpley式を使用して推定1RMを計算します。",
        "en": "1RM (1 Rep Max) is the maximum weight you can lift for one repetition.\nCalculates estimated 1RM using the Epley formula.",
        "zh": "1RM（1次最大重复）是您可以举起一次的最大重量。\n使用Epley公式计算估计的1RM。",
        "ko": "1RM (1 Rep Max)은 1회 들어올릴 수 있는 최대 무게입니다.\nEpley 공식을 사용하여 추정 1RM을 계산합니다.",
        "es": "1RM (1 Rep Max) es el peso máximo que puedes levantar una vez.\nCalcula el 1RM estimado usando la fórmula de Epley.",
        "de": "1RM (1 Rep Max) ist das maximale Gewicht, das Sie einmal heben können.\nBerechnet geschätztes 1RM mit der Epley-Formel.",
        "zh_TW": "1RM（1次最大重複）是您可以舉起一次的最大重量。\n使用Epley公式計算估計的1RM。"
    },
    "calculators_barWeightError": {
        "ja": "バー重量 ({barWeight}kg) より大きい重量を入力してください",
        "en": "Please enter a weight greater than the bar weight ({barWeight}kg)",
        "zh": "请输入大于杠铃重量（{barWeight}kg）的重量",
        "ko": "바 무게 ({barWeight}kg)보다 큰 무게를 입력하세요",
        "es": "Por favor ingrese un peso mayor que el peso de la barra ({barWeight}kg)",
        "de": "Bitte geben Sie ein Gewicht größer als das Stangengewicht ({barWeight}kg) ein",
        "zh_TW": "請輸入大於槓鈴重量（{barWeight}kg）的重量"
    }
}

# メタデータ
METADATA = {
    "calculators_title": {
        "description": "Title for calculators screen"
    },
    "calculators_invalidInput": {
        "description": "Error message for invalid weight and reps input"
    },
    "calculators_oneRMCalculator": {
        "description": "Title for 1RM calculator section"
    },
    "calculators_oneRMDescription": {
        "description": "Description of 1RM calculator using Epley formula"
    },
    "calculators_barWeightError": {
        "description": "Error message when entered weight is less than bar weight",
        "placeholders": {
            "barWeight": {
                "type": "double",
                "format": "decimalPattern",
                "example": "20.0"
            }
        }
    }
}

def add_arb_keys():
    """ARBファイルに新しいキーを追加"""
    
    for lang_code, arb_file in LANGUAGES.items():
        arb_path = os.path.join(ARB_DIR, arb_file)
        
        # 既存のARBファイルを読み込み
        with open(arb_path, 'r', encoding='utf-8') as f:
            arb_data = json.load(f)
        
        # 新しいキーを追加
        for key, translations in NEW_KEYS.items():
            if key not in arb_data:
                arb_data[key] = translations[lang_code]
                
                # メタデータを追加（日本語のみ）
                if lang_code == "ja" and key in METADATA:
                    arb_data[f"@{key}"] = METADATA[key]
        
        # ARBファイルに書き込み
        with open(arb_path, 'w', encoding='utf-8') as f:
            json.dump(arb_data, f, ensure_ascii=False, indent=2)
        
        print(f"✅ {arb_file}: {len(NEW_KEYS)}キー追加")
    
    total_entries = len(NEW_KEYS) * len(LANGUAGES)
    print(f"\n🎉 合計 {total_entries}エントリ追加完了！")
    print(f"   ({len(NEW_KEYS)}キー × {len(LANGUAGES)}言語)")

if __name__ == "__main__":
    add_arb_keys()
