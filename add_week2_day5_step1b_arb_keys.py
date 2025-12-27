#!/usr/bin/env python3
"""
Week 2 Day 5 Step 1b - ARB Keys Addition Script
simple_workout_detail_screen.dart の残り6件
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

# 新しいARBキー（残り6件）
NEW_KEYS = {
    'ja': {
        'workout_debugAfterDeleteSetsCount': '📊 削除後のセット数: {count}',
        '@workout_debugAfterDeleteSetsCount': {
            'description': 'デバッグ用削除後のセット数',
            'placeholders': {
                'count': {
                    'type': 'int',
                    'example': '3'
                }
            }
        },
        'workout_debugSetDetails': '🔍 セット詳細:',
        'workout_debugExercisesField': '⚠️ exercises フィールド検出: {type}',
        '@workout_debugExercisesField': {
            'description': 'デバッグ用exercisesフィールド型情報',
            'placeholders': {
                'type': {
                    'type': 'String',
                    'example': 'List<String>'
                }
            }
        },
        'workout_preventFullDelete': '⚠️ 全削除防止',
        'workout_exerciseDeletedWithCount': '「{exerciseName}」を削除しました（残り{remainingExercises}種目）',
        '@workout_exerciseDeletedWithCount': {
            'description': '種目削除成功メッセージ（残り種目数付き）',
            'placeholders': {
                'exerciseName': {
                    'type': 'String',
                    'example': 'ベンチプレス'
                },
                'remainingExercises': {
                    'type': 'String',
                    'example': 'スクワット, デッドリフト'
                }
            }
        },
        'workout_exerciseDeletedWithCountNum': '「{exerciseName}」を削除しました（残り{count}種目）',
        '@workout_exerciseDeletedWithCountNum': {
            'description': '種目削除成功メッセージ（残り種目数）',
            'placeholders': {
                'exerciseName': {
                    'type': 'String',
                    'example': 'ベンチプレス'
                },
                'count': {
                    'type': 'int',
                    'example': '2'
                }
            }
        }
    },
    'en': {
        'workout_debugAfterDeleteSetsCount': '📊 After delete sets: {count}',
        'workout_debugSetDetails': '🔍 Set details:',
        'workout_debugExercisesField': '⚠️ exercises field detected: {type}',
        'workout_preventFullDelete': '⚠️ Prevent full delete',
        'workout_exerciseDeletedWithCount': '"{exerciseName}" deleted ({remainingExercises} remaining)',
        'workout_exerciseDeletedWithCountNum': '"{exerciseName}" deleted ({count} exercises remaining)'
    },
    'ko': {
        'workout_debugAfterDeleteSetsCount': '📊 삭제 후 세트 수: {count}',
        'workout_debugSetDetails': '🔍 세트 상세:',
        'workout_debugExercisesField': '⚠️ exercises 필드 감지: {type}',
        'workout_preventFullDelete': '⚠️ 전체 삭제 방지',
        'workout_exerciseDeletedWithCount': '"{exerciseName}" 삭제됨 (남은 운동: {remainingExercises})',
        'workout_exerciseDeletedWithCountNum': '"{exerciseName}" 삭제됨 (남은 운동: {count}개)'
    },
    'zh': {
        'workout_debugAfterDeleteSetsCount': '📊 删除后组数：{count}',
        'workout_debugSetDetails': '🔍 组详情：',
        'workout_debugExercisesField': '⚠️ 检测到exercises字段：{type}',
        'workout_preventFullDelete': '⚠️ 防止全部删除',
        'workout_exerciseDeletedWithCount': '已删除"{exerciseName}"（剩余：{remainingExercises}）',
        'workout_exerciseDeletedWithCountNum': '已删除"{exerciseName}"（剩余{count}个动作）'
    },
    'zh_TW': {
        'workout_debugAfterDeleteSetsCount': '📊 刪除後組數：{count}',
        'workout_debugSetDetails': '🔍 組詳情：',
        'workout_debugExercisesField': '⚠️ 偵測到exercises欄位：{type}',
        'workout_preventFullDelete': '⚠️ 防止全部刪除',
        'workout_exerciseDeletedWithCount': '已刪除「{exerciseName}」（剩餘：{remainingExercises}）',
        'workout_exerciseDeletedWithCountNum': '已刪除「{exerciseName}」（剩餘{count}個動作）'
    },
    'de': {
        'workout_debugAfterDeleteSetsCount': '📊 Sätze nach Löschung: {count}',
        'workout_debugSetDetails': '🔍 Satzdetails:',
        'workout_debugExercisesField': '⚠️ exercises-Feld erkannt: {type}',
        'workout_preventFullDelete': '⚠️ Vollständige Löschung verhindern',
        'workout_exerciseDeletedWithCount': '"{exerciseName}" gelöscht ({remainingExercises} verbleibend)',
        'workout_exerciseDeletedWithCountNum': '"{exerciseName}" gelöscht ({count} Übungen verbleibend)'
    },
    'es': {
        'workout_debugAfterDeleteSetsCount': '📊 Series después de eliminar: {count}',
        'workout_debugSetDetails': '🔍 Detalles de series:',
        'workout_debugExercisesField': '⚠️ Campo exercises detectado: {type}',
        'workout_preventFullDelete': '⚠️ Prevenir eliminación total',
        'workout_exerciseDeletedWithCount': '"{exerciseName}" eliminado (restantes: {remainingExercises})',
        'workout_exerciseDeletedWithCountNum': '"{exerciseName}" eliminado ({count} ejercicios restantes)'
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
    
    print(f"Week 2 Day 5 Step 1b - ARBキー追加（残り6件）")
    print(f"Total: {total_added} keys added (6 keys × 7 languages = 42 entries)")
    print("\nNew ARB keys:")
    print("1. workout_debugAfterDeleteSetsCount(count)")
    print("2. workout_debugSetDetails")
    print("3. workout_debugExercisesField(type)")
    print("4. workout_preventFullDelete")
    print("5. workout_exerciseDeletedWithCount(exerciseName, remainingExercises)")
    print("6. workout_exerciseDeletedWithCountNum(exerciseName, count)")

if __name__ == '__main__':
    main()
