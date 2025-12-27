#!/usr/bin/env python3
"""
Week 2 Day 5 Step 2 - ARB Keys Addition Script
ai_coaching_screen_tabbed.dart の6件（AI機能通知）
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
        'ai_generationComplete': 'AI生成完了! ({status})',
        '@ai_generationComplete': {
            'description': 'AI生成完了通知',
            'placeholders': {
                'status': {
                    'type': 'String',
                    'example': 'メニュー生成成功'
                }
            }
        },
        'ai_rewardEarned': '🎁 AI機能1回分を獲得しました!',
        'ai_predictionComplete': 'AI予測完了! ({status})',
        '@ai_predictionComplete': {
            'description': 'AI予測完了通知',
            'placeholders': {
                'status': {
                    'type': 'String',
                    'example': '予測成功'
                }
            }
        },
        'ai_analysisComplete': 'AI分析完了! ({status})',
        '@ai_analysisComplete': {
            'description': 'AI分析完了通知',
            'placeholders': {
                'status': {
                    'type': 'String',
                    'example': '分析成功'
                }
            }
        }
    },
    'en': {
        'ai_generationComplete': 'AI generation complete! ({status})',
        'ai_rewardEarned': '🎁 Earned 1 AI usage credit!',
        'ai_predictionComplete': 'AI prediction complete! ({status})',
        'ai_analysisComplete': 'AI analysis complete! ({status})'
    },
    'ko': {
        'ai_generationComplete': 'AI 생성 완료! ({status})',
        'ai_rewardEarned': '🎁 AI 기능 1회 획득!',
        'ai_predictionComplete': 'AI 예측 완료! ({status})',
        'ai_analysisComplete': 'AI 분석 완료! ({status})'
    },
    'zh': {
        'ai_generationComplete': 'AI生成完成！（{status}）',
        'ai_rewardEarned': '🎁 获得AI功能使用1次！',
        'ai_predictionComplete': 'AI预测完成！（{status}）',
        'ai_analysisComplete': 'AI分析完成！（{status}）'
    },
    'zh_TW': {
        'ai_generationComplete': 'AI生成完成！（{status}）',
        'ai_rewardEarned': '🎁 獲得AI功能使用1次！',
        'ai_predictionComplete': 'AI預測完成！（{status}）',
        'ai_analysisComplete': 'AI分析完成！（{status}）'
    },
    'de': {
        'ai_generationComplete': 'KI-Generierung abgeschlossen! ({status})',
        'ai_rewardEarned': '🎁 1 KI-Nutzung erhalten!',
        'ai_predictionComplete': 'KI-Vorhersage abgeschlossen! ({status})',
        'ai_analysisComplete': 'KI-Analyse abgeschlossen! ({status})'
    },
    'es': {
        'ai_generationComplete': '¡Generación de IA completa! ({status})',
        'ai_rewardEarned': '🎁 ¡1 uso de IA obtenido!',
        'ai_predictionComplete': '¡Predicción de IA completa! ({status})',
        'ai_analysisComplete': '¡Análisis de IA completo! ({status})'
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
    
    print(f"Week 2 Day 5 Step 2 - ARBキー追加（AI機能通知）")
    print(f"Total: {total_added} keys added (4 keys × 7 languages = 28 entries)")
    print("\nNew ARB keys:")
    print("1. ai_generationComplete(status) - used 2 times")
    print("2. ai_rewardEarned - used 3 times")
    print("3. ai_predictionComplete(status) - used 2 times")
    print("4. ai_analysisComplete(status) - used 2 times")
    print("\nTotal replacements: 6 (some keys used multiple times)")

if __name__ == '__main__':
    main()
