#!/usr/bin/env python3
"""
Week 2 Day 5 Step 1a - ARB Keys Addition Script
simple_workout_detail_screen.dart の最初の6件
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
        'workout_deleteDebug': '🔍 削除デバッグ',
        'workout_deleteConfirmExercise': '「{exerciseName}」を削除しますか？',
        '@workout_deleteConfirmExercise': {
            'description': '種目削除の確認メッセージ（デバッグ用）',
            'placeholders': {
                'exerciseName': {
                    'type': 'String',
                    'example': 'ベンチプレス'
                }
            }
        },
        'workout_debugTargetInfo': '🎯 {targetInfo}',
        '@workout_debugTargetInfo': {
            'description': 'デバッグ用ターゲット情報',
            'placeholders': {
                'targetInfo': {
                    'type': 'String',
                    'example': 'Exercise index: 2'
                }
            }
        },
        'workout_debugCurrentExercises': '📊 現在の種目: {exercises}',
        '@workout_debugCurrentExercises': {
            'description': 'デバッグ用現在の種目一覧',
            'placeholders': {
                'exercises': {
                    'type': 'String',
                    'example': 'ベンチプレス, スクワット'
                }
            }
        },
        'workout_debugAfterDeleteExercises': '📊 削除後の種目: {exercises}',
        '@workout_debugAfterDeleteExercises': {
            'description': 'デバッグ用削除後の種目一覧',
            'placeholders': {
                'exercises': {
                    'type': 'String',
                    'example': 'スクワット'
                }
            }
        },
        'workout_debugCurrentSetsCount': '📊 現在のセット数: {count}',
        '@workout_debugCurrentSetsCount': {
            'description': 'デバッグ用現在のセット数',
            'placeholders': {
                'count': {
                    'type': 'int',
                    'example': '5'
                }
            }
        }
    },
    'en': {
        'workout_deleteDebug': '🔍 Delete Debug',
        'workout_deleteConfirmExercise': 'Delete "{exerciseName}"?',
        'workout_debugTargetInfo': '🎯 {targetInfo}',
        'workout_debugCurrentExercises': '📊 Current exercises: {exercises}',
        'workout_debugAfterDeleteExercises': '📊 After delete: {exercises}',
        'workout_debugCurrentSetsCount': '📊 Current sets: {count}'
    },
    'ko': {
        'workout_deleteDebug': '🔍 삭제 디버그',
        'workout_deleteConfirmExercise': '"{exerciseName}"를 삭제하시겠습니까?',
        'workout_debugTargetInfo': '🎯 {targetInfo}',
        'workout_debugCurrentExercises': '📊 현재 운동: {exercises}',
        'workout_debugAfterDeleteExercises': '📊 삭제 후: {exercises}',
        'workout_debugCurrentSetsCount': '📊 현재 세트 수: {count}'
    },
    'zh': {
        'workout_deleteDebug': '🔍 删除调试',
        'workout_deleteConfirmExercise': '删除"{exerciseName}"？',
        'workout_debugTargetInfo': '🎯 {targetInfo}',
        'workout_debugCurrentExercises': '📊 当前动作：{exercises}',
        'workout_debugAfterDeleteExercises': '📊 删除后：{exercises}',
        'workout_debugCurrentSetsCount': '📊 当前组数：{count}'
    },
    'zh_TW': {
        'workout_deleteDebug': '🔍 刪除偵錯',
        'workout_deleteConfirmExercise': '刪除「{exerciseName}」？',
        'workout_debugTargetInfo': '🎯 {targetInfo}',
        'workout_debugCurrentExercises': '📊 目前動作：{exercises}',
        'workout_debugAfterDeleteExercises': '📊 刪除後：{exercises}',
        'workout_debugCurrentSetsCount': '📊 目前組數：{count}'
    },
    'de': {
        'workout_deleteDebug': '🔍 Debug löschen',
        'workout_deleteConfirmExercise': '"{exerciseName}" löschen?',
        'workout_debugTargetInfo': '🎯 {targetInfo}',
        'workout_debugCurrentExercises': '📊 Aktuelle Übungen: {exercises}',
        'workout_debugAfterDeleteExercises': '📊 Nach Löschung: {exercises}',
        'workout_debugCurrentSetsCount': '📊 Aktuelle Sätze: {count}'
    },
    'es': {
        'workout_deleteDebug': '🔍 Debug de eliminación',
        'workout_deleteConfirmExercise': '¿Eliminar "{exerciseName}"?',
        'workout_debugTargetInfo': '🎯 {targetInfo}',
        'workout_debugCurrentExercises': '📊 Ejercicios actuales: {exercises}',
        'workout_debugAfterDeleteExercises': '📊 Después de eliminar: {exercises}',
        'workout_debugCurrentSetsCount': '📊 Series actuales: {count}'
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
    
    print(f"Week 2 Day 5 Step 1a - ARBキー追加（6件）")
    print(f"Total: {total_added} keys added (6 keys × 7 languages = 42 entries)")
    print("\nNew ARB keys:")
    print("1. workout_deleteDebug")
    print("2. workout_deleteConfirmExercise(exerciseName)")
    print("3. workout_debugTargetInfo(targetInfo)")
    print("4. workout_debugCurrentExercises(exercises)")
    print("5. workout_debugAfterDeleteExercises(exercises)")
    print("6. workout_debugCurrentSetsCount(count)")

if __name__ == '__main__':
    main()
