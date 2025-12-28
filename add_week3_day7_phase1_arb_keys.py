#!/usr/bin/env python3
"""
Week 3 Day 7 Phase 1: 4ファイルのARBキー追加（12件）

対象文字列: 12件
- achievements_screen.dart (3件)
- personal_factors_screen.dart (3件)
- favorites_screen.dart (3件)
- gym_detail_screen.dart (3件)
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
    # achievements_screen.dart
    "achievements_loadFailed": {
        "ja": "バッジの読み込みに失敗しました: {error}",
        "en": "Failed to load badges: {error}",
        "zh": "加载徽章失败：{error}",
        "ko": "배지 로드 실패: {error}",
        "es": "Error al cargar insignias: {error}",
        "de": "Fehler beim Laden von Abzeichen: {error}",
        "zh_TW": "載入徽章失敗：{error}"
    },
    "achievements_title": {
        "ja": "達成バッジ",
        "en": "Achievement Badges",
        "zh": "成就徽章",
        "ko": "업적 배지",
        "es": "Insignias de Logro",
        "de": "Erfolgsabzeichen",
        "zh_TW": "成就徽章"
    },
    "achievements_noBadges": {
        "ja": "バッジがありません",
        "en": "No badges",
        "zh": "没有徽章",
        "ko": "배지가 없습니다",
        "es": "Sin insignias",
        "de": "Keine Abzeichen",
        "zh_TW": "沒有徽章"
    },
    # personal_factors_screen.dart
    "personalFactors_saved": {
        "ja": "✅ 保存完了！現在のPFM: {pfm}x",
        "en": "✅ Saved! Current PFM: {pfm}x",
        "zh": "✅ 保存完成！当前PFM：{pfm}x",
        "ko": "✅ 저장 완료! 현재 PFM: {pfm}x",
        "es": "✅ ¡Guardado! PFM actual: {pfm}x",
        "de": "✅ Gespeichert! Aktueller PFM: {pfm}x",
        "zh_TW": "✅ 儲存完成！目前PFM：{pfm}x"
    },
    "personalFactors_saveError": {
        "ja": "❌ 保存エラー: {error}",
        "en": "❌ Save error: {error}",
        "zh": "❌ 保存错误：{error}",
        "ko": "❌ 저장 오류: {error}",
        "es": "❌ Error al guardar: {error}",
        "de": "❌ Speicherfehler: {error}",
        "zh_TW": "❌ 儲存錯誤：{error}"
    },
    "personalFactors_title": {
        "ja": "🔬 個人要因設定",
        "en": "🔬 Personal Factors Settings",
        "zh": "🔬 个人因素设置",
        "ko": "🔬 개인 요인 설정",
        "es": "🔬 Configuración de Factores Personales",
        "de": "🔬 Persönliche Faktoreneinstellungen",
        "zh_TW": "🔬 個人因素設定"
    },
    # favorites_screen.dart
    "favorites_removeConfirm": {
        "ja": "「{gymName}」をお気に入りから削除しますか？",
        "en": "Remove \"{gymName}\" from favorites?",
        "zh": "从收藏中删除\"{gymName}\"？",
        "ko": "\"{gymName}\"을(를) 즐겨찾기에서 제거하시겠습니까?",
        "es": "¿Eliminar \"{gymName}\" de favoritos?",
        "de": "\"{gymName}\" aus Favoriten entfernen?",
        "zh_TW": "從我的最愛中移除「{gymName}」？"
    },
    "favorites_removed": {
        "ja": "{gymName} をお気に入りから削除しました",
        "en": "Removed {gymName} from favorites",
        "zh": "已从收藏中删除{gymName}",
        "ko": "{gymName}을(를) 즐겨찾기에서 제거했습니다",
        "es": "Se eliminó {gymName} de favoritos",
        "de": "{gymName} aus Favoriten entfernt",
        "zh_TW": "已從我的最愛中移除{gymName}"
    },
    "favorites_removeAll": {
        "ja": "すべて削除",
        "en": "Remove All",
        "zh": "全部删除",
        "ko": "모두 제거",
        "es": "Eliminar Todo",
        "de": "Alle entfernen",
        "zh_TW": "全部移除"
    },
    # gym_detail_screen.dart
    "gymDetail_shareFailed": {
        "ja": "シェアに失敗しました: {error}",
        "en": "Share failed: {error}",
        "zh": "分享失败：{error}",
        "ko": "공유 실패: {error}",
        "es": "Error al compartir: {error}",
        "de": "Teilen fehlgeschlagen: {error}",
        "zh_TW": "分享失敗：{error}"
    },
    "gymDetail_trophy": {
        "ja": "🏆",
        "en": "🏆",
        "zh": "🏆",
        "ko": "🏆",
        "es": "🏆",
        "de": "🏆",
        "zh_TW": "🏆"
    },
    "gymDetail_error": {
        "ja": "エラー: {error}",
        "en": "Error: {error}",
        "zh": "错误：{error}",
        "ko": "오류: {error}",
        "es": "Error: {error}",
        "de": "Fehler: {error}",
        "zh_TW": "錯誤：{error}"
    }
}

# メタデータ
METADATA = {
    "achievements_loadFailed": {
        "description": "Error message when badge loading fails",
        "placeholders": {
            "error": {"type": "String", "example": "Network error"}
        }
    },
    "achievements_title": {
        "description": "Title for achievements screen"
    },
    "achievements_noBadges": {
        "description": "Message when user has no badges"
    },
    "personalFactors_saved": {
        "description": "Success message after saving personal factors",
        "placeholders": {
            "pfm": {"type": "String", "example": "1.23"}
        }
    },
    "personalFactors_saveError": {
        "description": "Error message when saving fails",
        "placeholders": {
            "error": {"type": "String", "example": "Network error"}
        }
    },
    "personalFactors_title": {
        "description": "Title for personal factors settings screen"
    },
    "favorites_removeConfirm": {
        "description": "Confirmation dialog to remove gym from favorites",
        "placeholders": {
            "gymName": {"type": "String", "example": "Gold's Gym"}
        }
    },
    "favorites_removed": {
        "description": "Success message after removing from favorites",
        "placeholders": {
            "gymName": {"type": "String", "example": "Gold's Gym"}
        }
    },
    "favorites_removeAll": {
        "description": "Button label to remove all favorites"
    },
    "gymDetail_shareFailed": {
        "description": "Error message when sharing fails",
        "placeholders": {
            "error": {"type": "String", "example": "No share target"}
        }
    },
    "gymDetail_trophy": {
        "description": "Trophy emoji"
    },
    "gymDetail_error": {
        "description": "Generic error message",
        "placeholders": {
            "error": {"type": "String", "example": "Unknown error"}
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
