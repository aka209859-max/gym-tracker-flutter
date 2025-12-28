#!/usr/bin/env python3
"""
Week 3 Day 6 Phase 2: add_workout_screen_complete.dart のARBキー追加

対象文字列: 5件
- AIコーチからの読み込み通知
- 休憩時間の秒数表示
- セットコピー通知
- カスタム種目追加ラベル
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
    "workout_aiCoachLoaded": {
        "ja": "AIコーチから{count}種目を読み込みました",
        "en": "Loaded {count} exercises from AI Coach",
        "zh": "从AI教练加载了{count}个动作",
        "ko": "AI 코치에서 {count}개 운동을 불러왔습니다",
        "es": "Se cargaron {count} ejercicios del Entrenador IA",
        "de": "{count} Übungen vom KI-Trainer geladen",
        "zh_TW": "從AI教練載入了{count}個動作"
    },
    "workout_restDurationSeconds": {
        "ja": "{seconds}秒",
        "en": "{seconds} sec",
        "zh": "{seconds}秒",
        "ko": "{seconds}초",
        "es": "{seconds} seg",
        "de": "{seconds} Sek",
        "zh_TW": "{seconds}秒"
    },
    "workout_setsCopiedCount": {
        "ja": "{count}セットをコピーしました",
        "en": "Copied {count} sets",
        "zh": "已复制{count}组",
        "ko": "{count}세트를 복사했습니다",
        "es": "Se copiaron {count} series",
        "de": "{count} Sätze kopiert",
        "zh_TW": "已複製{count}組"
    },
    "workout_restSeconds": {
        "ja": "休憩 {seconds}秒",
        "en": "Rest {seconds} sec",
        "zh": "休息{seconds}秒",
        "ko": "휴식 {seconds}초",
        "es": "Descanso {seconds} seg",
        "de": "Pause {seconds} Sek",
        "zh_TW": "休息{seconds}秒"
    },
    "workout_addCustomExercise": {
        "ja": "種目を追加（カスタム）",
        "en": "Add Exercise (Custom)",
        "zh": "添加动作（自定义）",
        "ko": "운동 추가 (커스텀)",
        "es": "Agregar Ejercicio (Personalizado)",
        "de": "Übung hinzufügen (Benutzerdefiniert)",
        "zh_TW": "新增動作（自訂）"
    }
}

# メタデータ
METADATA = {
    "workout_aiCoachLoaded": {
        "description": "Message shown when exercises are loaded from AI Coach",
        "placeholders": {
            "count": {
                "type": "int",
                "example": "5"
            }
        }
    },
    "workout_restDurationSeconds": {
        "description": "Rest duration in seconds",
        "placeholders": {
            "seconds": {
                "type": "int",
                "example": "60"
            }
        }
    },
    "workout_setsCopiedCount": {
        "description": "Message shown when sets are copied",
        "placeholders": {
            "count": {
                "type": "int",
                "example": "3"
            }
        }
    },
    "workout_restSeconds": {
        "description": "Rest time display in seconds",
        "placeholders": {
            "seconds": {
                "type": "int",
                "example": "60"
            }
        }
    },
    "workout_addCustomExercise": {
        "description": "Button label to add custom exercise"
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
