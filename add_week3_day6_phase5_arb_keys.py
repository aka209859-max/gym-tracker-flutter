#!/usr/bin/env python3
"""
Week 3 Day 6 Phase 5: weekly_reports & body_part_tracking のARBキー追加

対象文字列: 5件
- weekly_reports_screen.dart (2件)
- body_part_tracking_screen.dart (3件)
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
    # weekly_reports_screen.dart
    "weeklyReports_recommendation": {
        "ja": "週次レコメンデーション",
        "en": "Weekly Recommendation",
        "zh": "每周推荐",
        "ko": "주간 추천",
        "es": "Recomendación Semanal",
        "de": "Wöchentliche Empfehlung",
        "zh_TW": "每週推薦"
    },
    "weeklyReports_recommendationSubtitle": {
        "ja": "推奨曜日とメニュー提案を表示",
        "en": "Show recommended days and menu suggestions",
        "zh": "显示推荐的日期和菜单建议",
        "ko": "추천 요일 및 메뉴 제안 표시",
        "es": "Mostrar días recomendados y sugerencias de menú",
        "de": "Empfohlene Tage und Menüvorschläge anzeigen",
        "zh_TW": "顯示推薦的日期和菜單建議"
    },
    # body_part_tracking_screen.dart
    "bodyPart_days7": {
        "ja": "7日",
        "en": "7 days",
        "zh": "7天",
        "ko": "7일",
        "es": "7 días",
        "de": "7 Tage",
        "zh_TW": "7天"
    },
    "bodyPart_days30": {
        "ja": "30日",
        "en": "30 days",
        "zh": "30天",
        "ko": "30일",
        "es": "30 días",
        "de": "30 Tage",
        "zh_TW": "30天"
    },
    "bodyPart_days90": {
        "ja": "90日",
        "en": "90 days",
        "zh": "90天",
        "ko": "90일",
        "es": "90 días",
        "de": "90 Tage",
        "zh_TW": "90天"
    }
}

# メタデータ
METADATA = {
    "weeklyReports_recommendation": {
        "description": "Title for weekly recommendation feature"
    },
    "weeklyReports_recommendationSubtitle": {
        "description": "Subtitle explaining weekly recommendation feature"
    },
    "bodyPart_days7": {
        "description": "7 days period selector"
    },
    "bodyPart_days30": {
        "description": "30 days period selector"
    },
    "bodyPart_days90": {
        "description": "90 days period selector"
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
