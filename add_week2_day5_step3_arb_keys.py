#!/usr/bin/env python3
"""
Week 2 Day 5 Step 3 - ARB Keys Addition Script
gym_review_screen.dart の6件（ジムレビュー機能）
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

# 新しいARBキー（6件）
NEW_KEYS = {
    'ja': {
        'gym_reviewPostFailed': 'レビュー投稿に失敗しました: {error}',
        '@gym_reviewPostFailed': {
            'description': 'レビュー投稿失敗メッセージ',
            'placeholders': {
                'error': {
                    'type': 'String',
                    'example': 'ネットワークエラー'
                }
            }
        },
        'gym_premiumFeature': 'Premium機能',
        'gym_reviewFeature': '• ジムレビューの投稿',
        'gym_aiUsageLimit': '• AI機能を月10回使用',
        'gym_unlimitedFavorites': '• お気に入り無制限',
        'gym_detailedStats': '• 詳細な混雑度統計'
    },
    'en': {
        'gym_reviewPostFailed': 'Review post failed: {error}',
        'gym_premiumFeature': 'Premium Feature',
        'gym_reviewFeature': '• Post gym reviews',
        'gym_aiUsageLimit': '• Use AI features 10 times per month',
        'gym_unlimitedFavorites': '• Unlimited favorites',
        'gym_detailedStats': '• Detailed crowd statistics'
    },
    'ko': {
        'gym_reviewPostFailed': '리뷰 게시 실패: {error}',
        'gym_premiumFeature': '프리미엄 기능',
        'gym_reviewFeature': '• 헬스장 리뷰 게시',
        'gym_aiUsageLimit': '• AI 기능 월 10회 사용',
        'gym_unlimitedFavorites': '• 무제한 즐겨찾기',
        'gym_detailedStats': '• 상세 혼잡도 통계'
    },
    'zh': {
        'gym_reviewPostFailed': '评论发布失败：{error}',
        'gym_premiumFeature': '高级功能',
        'gym_reviewFeature': '• 发布健身房评论',
        'gym_aiUsageLimit': '• 每月使用AI功能10次',
        'gym_unlimitedFavorites': '• 无限收藏',
        'gym_detailedStats': '• 详细拥挤度统计'
    },
    'zh_TW': {
        'gym_reviewPostFailed': '評論發布失敗：{error}',
        'gym_premiumFeature': '高級功能',
        'gym_reviewFeature': '• 發布健身房評論',
        'gym_aiUsageLimit': '• 每月使用AI功能10次',
        'gym_unlimitedFavorites': '• 無限收藏',
        'gym_detailedStats': '• 詳細擁擠度統計'
    },
    'de': {
        'gym_reviewPostFailed': 'Bewertungsveröffentlichung fehlgeschlagen: {error}',
        'gym_premiumFeature': 'Premium-Funktion',
        'gym_reviewFeature': '• Fitnessstudio-Bewertungen veröffentlichen',
        'gym_aiUsageLimit': '• KI-Funktionen 10 Mal pro Monat nutzen',
        'gym_unlimitedFavorites': '• Unbegrenzte Favoriten',
        'gym_detailedStats': '• Detaillierte Auslastungsstatistiken'
    },
    'es': {
        'gym_reviewPostFailed': 'Error al publicar reseña: {error}',
        'gym_premiumFeature': 'Función Premium',
        'gym_reviewFeature': '• Publicar reseñas de gimnasios',
        'gym_aiUsageLimit': '• Usar funciones de IA 10 veces al mes',
        'gym_unlimitedFavorites': '• Favoritos ilimitados',
        'gym_detailedStats': '• Estadísticas detalladas de aforo'
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
    
    print(f"Week 2 Day 5 Step 3 - ARBキー追加（ジムレビュー機能）")
    print(f"Total: {total_added} keys added (6 keys × 7 languages = 42 entries)")
    print("\nNew ARB keys:")
    print("1. gym_reviewPostFailed(error)")
    print("2. gym_premiumFeature")
    print("3. gym_reviewFeature")
    print("4. gym_aiUsageLimit")
    print("5. gym_unlimitedFavorites")
    print("6. gym_detailedStats")

if __name__ == '__main__':
    main()
