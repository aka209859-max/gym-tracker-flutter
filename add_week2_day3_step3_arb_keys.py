#!/usr/bin/env python3
"""
Week 2 Day 3 Step 3 - ARB Keys Addition Script
add_workout_screen.dart の残り3件（削除・保存メッセージ）
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

# 新しいARBキー（残り3件）
NEW_KEYS = {
    'ja': {
        'workout_deleteConfirm': '「{exerciseName}」を削除しますか？\nこの操作は取り消せません。',
        '@workout_deleteConfirm': {
            'description': '種目削除の確認メッセージ',
            'placeholders': {
                'exerciseName': {
                    'type': 'String',
                    'example': 'ベンチプレス'
                }
            }
        },
        'workout_deleteSuccess': '「{exerciseName}」を削除しました',
        '@workout_deleteSuccess': {
            'description': '種目削除成功メッセージ',
            'placeholders': {
                'exerciseName': {
                    'type': 'String',
                    'example': 'ベンチプレス'
                }
            }
        },
        'workout_customExerciseSaved': '「{exerciseName}」をカスタム種目として保存しました',
        '@workout_customExerciseSaved': {
            'description': 'カスタム種目保存成功メッセージ',
            'placeholders': {
                'exerciseName': {
                    'type': 'String',
                    'example': 'マイトレーニング'
                }
            }
        }
    },
    'en': {
        'workout_deleteConfirm': 'Delete "{exerciseName}"?\nThis action cannot be undone.',
        'workout_deleteSuccess': '"{exerciseName}" deleted',
        'workout_customExerciseSaved': '"{exerciseName}" saved as custom exercise'
    },
    'ko': {
        'workout_deleteConfirm': '"{exerciseName}"를 삭제하시겠습니까?\n이 작업은 취소할 수 없습니다.',
        'workout_deleteSuccess': '"{exerciseName}"를 삭제했습니다',
        'workout_customExerciseSaved': '"{exerciseName}"를 맞춤 운동으로 저장했습니다'
    },
    'zh': {
        'workout_deleteConfirm': '删除"{exerciseName}"？\n此操作无法撤消。',
        'workout_deleteSuccess': '已删除"{exerciseName}"',
        'workout_customExerciseSaved': '已将"{exerciseName}"保存为自定义动作'
    },
    'zh_TW': {
        'workout_deleteConfirm': '刪除「{exerciseName}」？\n此操作無法撤銷。',
        'workout_deleteSuccess': '已刪除「{exerciseName}」',
        'workout_customExerciseSaved': '已將「{exerciseName}」保存為自訂動作'
    },
    'de': {
        'workout_deleteConfirm': '"{exerciseName}" löschen?\nDiese Aktion kann nicht rückgängig gemacht werden.',
        'workout_deleteSuccess': '"{exerciseName}" gelöscht',
        'workout_customExerciseSaved': '"{exerciseName}" als benutzerdefinierte Übung gespeichert'
    },
    'es': {
        'workout_deleteConfirm': '¿Eliminar "{exerciseName}"?\nEsta acción no se puede deshacer.',
        'workout_deleteSuccess': '"{exerciseName}" eliminado',
        'workout_customExerciseSaved': '"{exerciseName}" guardado como ejercicio personalizado'
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
    
    print(f"Week 2 Day 3 Step 3 - ARBキー追加（残り3件）")
    print(f"Total: {total_added} keys added (3 keys × 7 languages = 21 entries)")
    print("\nNew ARB keys:")
    print("1. workout_deleteConfirm (exerciseName)")
    print("2. workout_deleteSuccess (exerciseName)")
    print("3. workout_customExerciseSaved (exerciseName)")

if __name__ == '__main__':
    main()
