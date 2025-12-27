#!/usr/bin/env python3
"""
Week 2 Day 3 Step 2 - ARB Keys Addition Script
add_workout_screen.dart の次の5件（変数補間あり）
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

# 新しいARBキー（変数補間あり）
NEW_KEYS = {
    'ja': {
        'workout_aiMenuLoaded': 'AIコーチの推奨メニューを読み込みました ({count}種目)',
        '@workout_aiMenuLoaded': {
            'description': 'AIコーチのメニュー読み込み成功メッセージ',
            'placeholders': {
                'count': {
                    'type': 'int',
                    'example': '5'
                }
            }
        },
        'workout_aiMenuLoadFailed': 'AIコーチデータの読み込みに失敗しました: {error}',
        '@workout_aiMenuLoadFailed': {
            'description': 'AIコーチのメニュー読み込み失敗メッセージ',
            'placeholders': {
                'error': {
                    'type': 'String',
                    'example': 'Connection timeout'
                }
            }
        },
        'workout_noHistory': '{exerciseName}の履歴がありません',
        '@workout_noHistory': {
            'description': '種目の履歴がない場合のメッセージ',
            'placeholders': {
                'exerciseName': {
                    'type': 'String',
                    'example': 'ベンチプレス'
                }
            }
        },
        'workout_pastRecords': '{exerciseName}の過去記録',
        '@workout_pastRecords': {
            'description': '種目の過去記録ダイアログタイトル',
            'placeholders': {
                'exerciseName': {
                    'type': 'String',
                    'example': 'ベンチプレス'
                }
            }
        },
        'workout_bulkInput': '{exerciseName}の一括入力',
        '@workout_bulkInput': {
            'description': '種目の一括入力ダイアログタイトル',
            'placeholders': {
                'exerciseName': {
                    'type': 'String',
                    'example': 'ベンチプレス'
                }
            }
        }
    },
    'en': {
        'workout_aiMenuLoaded': 'AI Coach menu loaded ({count} exercises)',
        'workout_aiMenuLoadFailed': 'Failed to load AI Coach data: {error}',
        'workout_noHistory': 'No history for {exerciseName}',
        'workout_pastRecords': 'Past Records for {exerciseName}',
        'workout_bulkInput': 'Bulk Input for {exerciseName}'
    },
    'ko': {
        'workout_aiMenuLoaded': 'AI 코치 메뉴를 로드했습니다 ({count}개 운동)',
        'workout_aiMenuLoadFailed': 'AI 코치 데이터 로드 실패: {error}',
        'workout_noHistory': '{exerciseName}의 기록이 없습니다',
        'workout_pastRecords': '{exerciseName}의 과거 기록',
        'workout_bulkInput': '{exerciseName}의 일괄 입력'
    },
    'zh': {
        'workout_aiMenuLoaded': '已加载AI教练菜单（{count}个动作）',
        'workout_aiMenuLoadFailed': '加载AI教练数据失败：{error}',
        'workout_noHistory': '{exerciseName}没有历史记录',
        'workout_pastRecords': '{exerciseName}的过去记录',
        'workout_bulkInput': '{exerciseName}的批量输入'
    },
    'zh_TW': {
        'workout_aiMenuLoaded': '已載入AI教練菜單（{count}個動作）',
        'workout_aiMenuLoadFailed': '載入AI教練數據失敗：{error}',
        'workout_noHistory': '{exerciseName}沒有歷史記錄',
        'workout_pastRecords': '{exerciseName}的過去記錄',
        'workout_bulkInput': '{exerciseName}的批量輸入'
    },
    'de': {
        'workout_aiMenuLoaded': 'AI-Coach-Menü geladen ({count} Übungen)',
        'workout_aiMenuLoadFailed': 'Fehler beim Laden der AI-Coach-Daten: {error}',
        'workout_noHistory': 'Keine Historie für {exerciseName}',
        'workout_pastRecords': 'Bisherige Aufzeichnungen für {exerciseName}',
        'workout_bulkInput': 'Masseneingabe für {exerciseName}'
    },
    'es': {
        'workout_aiMenuLoaded': 'Menú de AI Coach cargado ({count} ejercicios)',
        'workout_aiMenuLoadFailed': 'Error al cargar datos del AI Coach: {error}',
        'workout_noHistory': 'Sin historial para {exerciseName}',
        'workout_pastRecords': 'Registros anteriores de {exerciseName}',
        'workout_bulkInput': 'Entrada masiva para {exerciseName}'
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
    
    print(f"Week 2 Day 3 Step 2 - ARBキー追加（変数補間あり）")
    print(f"Total: {total_added} keys added (5 keys × 7 languages = 35 entries)")
    print("\nNew ARB keys:")
    print("1. workout_aiMenuLoaded (count)")
    print("2. workout_aiMenuLoadFailed (error)")
    print("3. workout_noHistory (exerciseName)")
    print("4. workout_pastRecords (exerciseName)")
    print("5. workout_bulkInput (exerciseName)")

if __name__ == '__main__':
    main()
