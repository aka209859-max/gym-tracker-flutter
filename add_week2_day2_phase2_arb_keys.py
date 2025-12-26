#!/usr/bin/env python3
"""
Week 2 Day 2 Phase 2: Add new ARB keys for variable interpolation
"""
import json

# New ARB keys with placeholders
NEW_KEYS = {
    # home_screen.dart
    "home_shareFailed": "シェアに失敗しました: {error}",
    "home_deleteError": "削除エラー: {error}",
    "home_weightMinutes": "{weight} 分",
    "home_deleteRecordConfirm": "「{exerciseName}」の記録を削除しますか？\nこの操作は取り消せません。",
    "home_deleteRecordSuccess": "「{exerciseName}」を削除しました（残り{count}種目）",
    "home_deleteFailed": "削除に失敗しました: {error}",
    "home_generalError": "❌ エラー: {error}",
    
    # goals_screen.dart
    "goals_loadFailed": "目標の読み込みに失敗しました: {error}",
    "goals_deleteConfirm": "「{goalName}」を削除しますか？\nこの操作は取り消せません。",
    "goals_updateFailed": "更新に失敗しました: {error}",
    "goals_editTitle": "{goalName}を編集",
    
    # body_measurement_screen.dart
    "body_offlineSaved": "📴 オフライン保存しました\nオンライン復帰時に自動同期されます",
    "body_weightKg": "体重: {weight}kg",
    "body_bodyFatPercent": "体脂肪率: {bodyFat}%",
    
    # reward_ad_dialog.dart
    "reward_adLoadFailed": "広告の読み込みに失敗しました。もう一度お試しください。",
    "reward_adDisplayFailed": "広告の表示に失敗しました。しばらく待ってからお試しください。",
    "reward_creditEarnedTest": "✅ AIクレジット1回分を獲得しました！（テストモード）",
}

# Translations for other languages
TRANSLATIONS = {
    "en": {
        "home_shareFailed": "Failed to share: {error}",
        "home_deleteError": "Delete error: {error}",
        "home_weightMinutes": "{weight} min",
        "home_deleteRecordConfirm": "Delete record for \"{exerciseName}\"?\nThis action cannot be undone.",
        "home_deleteRecordSuccess": "Deleted \"{exerciseName}\" ({count} exercises remaining)",
        "home_deleteFailed": "Failed to delete: {error}",
        "home_generalError": "❌ Error: {error}",
        "goals_loadFailed": "Failed to load goals: {error}",
        "goals_deleteConfirm": "Delete \"{goalName}\"?\nThis action cannot be undone.",
        "goals_updateFailed": "Failed to update: {error}",
        "goals_editTitle": "Edit {goalName}",
        "body_offlineSaved": "📴 Saved offline\nWill sync when online",
        "body_weightKg": "Weight: {weight}kg",
        "body_bodyFatPercent": "Body fat: {bodyFat}%",
        "reward_adLoadFailed": "Failed to load ad. Please try again.",
        "reward_adDisplayFailed": "Failed to display ad. Please try again later.",
        "reward_creditEarnedTest": "✅ Earned 1 AI credit! (Test mode)",
    },
    "ko": {
        "home_shareFailed": "공유 실패: {error}",
        "home_deleteError": "삭제 오류: {error}",
        "home_weightMinutes": "{weight} 분",
        "home_deleteRecordConfirm": "\"{exerciseName}\" 기록을 삭제하시겠습니까?\n이 작업은 취소할 수 없습니다.",
        "home_deleteRecordSuccess": "\"{exerciseName}\"을(를) 삭제했습니다 (남은 운동 {count}개)",
        "home_deleteFailed": "삭제 실패: {error}",
        "home_generalError": "❌ 오류: {error}",
        "goals_loadFailed": "목표 로드 실패: {error}",
        "goals_deleteConfirm": "\"{goalName}\"을(를) 삭제하시겠습니까?\n이 작업은 취소할 수 없습니다.",
        "goals_updateFailed": "업데이트 실패: {error}",
        "goals_editTitle": "{goalName} 편집",
        "body_offlineSaved": "📴 오프라인 저장됨\n온라인 복구 시 자동 동기화",
        "body_weightKg": "체중: {weight}kg",
        "body_bodyFatPercent": "체지방률: {bodyFat}%",
        "reward_adLoadFailed": "광고 로드 실패. 다시 시도해주세요.",
        "reward_adDisplayFailed": "광고 표시 실패. 잠시 후 다시 시도해주세요.",
        "reward_creditEarnedTest": "✅ AI 크레딧 1회분 획득! (테스트 모드)",
    },
    "zh": {
        "home_shareFailed": "分享失败: {error}",
        "home_deleteError": "删除错误: {error}",
        "home_weightMinutes": "{weight} 分钟",
        "home_deleteRecordConfirm": "删除\"{exerciseName}\"的记录？\n此操作无法撤消。",
        "home_deleteRecordSuccess": "已删除\"{exerciseName}\"（剩余{count}个项目）",
        "home_deleteFailed": "删除失败: {error}",
        "home_generalError": "❌ 错误: {error}",
        "goals_loadFailed": "加载目标失败: {error}",
        "goals_deleteConfirm": "删除\"{goalName}\"？\n此操作无法撤消。",
        "goals_updateFailed": "更新失败: {error}",
        "goals_editTitle": "编辑 {goalName}",
        "body_offlineSaved": "📴 已离线保存\n在线恢复时自动同步",
        "body_weightKg": "体重: {weight}kg",
        "body_bodyFatPercent": "体脂率: {bodyFat}%",
        "reward_adLoadFailed": "加载广告失败。请重试。",
        "reward_adDisplayFailed": "显示广告失败。请稍后重试。",
        "reward_creditEarnedTest": "✅ 获得1次AI积分！（测试模式）",
    },
    "zh_TW": {
        "home_shareFailed": "分享失敗: {error}",
        "home_deleteError": "刪除錯誤: {error}",
        "home_weightMinutes": "{weight} 分鐘",
        "home_deleteRecordConfirm": "刪除\"{exerciseName}\"的記錄？\n此操作無法撤銷。",
        "home_deleteRecordSuccess": "已刪除\"{exerciseName}\"（剩餘{count}個項目）",
        "home_deleteFailed": "刪除失敗: {error}",
        "home_generalError": "❌ 錯誤: {error}",
        "goals_loadFailed": "載入目標失敗: {error}",
        "goals_deleteConfirm": "刪除\"{goalName}\"？\n此操作無法撤銷。",
        "goals_updateFailed": "更新失敗: {error}",
        "goals_editTitle": "編輯 {goalName}",
        "body_offlineSaved": "📴 已離線儲存\n線上恢復時自動同步",
        "body_weightKg": "體重: {weight}kg",
        "body_bodyFatPercent": "體脂率: {bodyFat}%",
        "reward_adLoadFailed": "載入廣告失敗。請重試。",
        "reward_adDisplayFailed": "顯示廣告失敗。請稍後重試。",
        "reward_creditEarnedTest": "✅ 獲得1次AI積分！（測試模式）",
    },
    "de": {
        "home_shareFailed": "Teilen fehlgeschlagen: {error}",
        "home_deleteError": "Löschfehler: {error}",
        "home_weightMinutes": "{weight} Min.",
        "home_deleteRecordConfirm": "Aufzeichnung für \"{exerciseName}\" löschen?\nDiese Aktion kann nicht rückgängig gemacht werden.",
        "home_deleteRecordSuccess": "\"{exerciseName}\" gelöscht ({count} Übungen verbleibend)",
        "home_deleteFailed": "Löschen fehlgeschlagen: {error}",
        "home_generalError": "❌ Fehler: {error}",
        "goals_loadFailed": "Ziele laden fehlgeschlagen: {error}",
        "goals_deleteConfirm": "\"{goalName}\" löschen?\nDiese Aktion kann nicht rückgängig gemacht werden.",
        "goals_updateFailed": "Aktualisierung fehlgeschlagen: {error}",
        "goals_editTitle": "{goalName} bearbeiten",
        "body_offlineSaved": "📴 Offline gespeichert\nWird bei Online-Verbindung synchronisiert",
        "body_weightKg": "Gewicht: {weight}kg",
        "body_bodyFatPercent": "Körperfett: {bodyFat}%",
        "reward_adLoadFailed": "Anzeige konnte nicht geladen werden. Bitte versuchen Sie es erneut.",
        "reward_adDisplayFailed": "Anzeige konnte nicht angezeigt werden. Bitte versuchen Sie es später erneut.",
        "reward_creditEarnedTest": "✅ 1 AI-Guthaben verdient! (Testmodus)",
    },
    "es": {
        "home_shareFailed": "Error al compartir: {error}",
        "home_deleteError": "Error al eliminar: {error}",
        "home_weightMinutes": "{weight} min",
        "home_deleteRecordConfirm": "¿Eliminar registro de \"{exerciseName}\"?\nEsta acción no se puede deshacer.",
        "home_deleteRecordSuccess": "\"{exerciseName}\" eliminado ({count} ejercicios restantes)",
        "home_deleteFailed": "Error al eliminar: {error}",
        "home_generalError": "❌ Error: {error}",
        "goals_loadFailed": "Error al cargar objetivos: {error}",
        "goals_deleteConfirm": "¿Eliminar \"{goalName}\"?\nEsta acción no se puede deshacer.",
        "goals_updateFailed": "Error al actualizar: {error}",
        "goals_editTitle": "Editar {goalName}",
        "body_offlineSaved": "📴 Guardado sin conexión\nSe sincronizará cuando esté en línea",
        "body_weightKg": "Peso: {weight}kg",
        "body_bodyFatPercent": "Grasa corporal: {bodyFat}%",
        "reward_adLoadFailed": "Error al cargar anuncio. Por favor, inténtelo de nuevo.",
        "reward_adDisplayFailed": "Error al mostrar anuncio. Por favor, inténtelo más tarde.",
        "reward_creditEarnedTest": "✅ ¡Ganaste 1 crédito de IA! (Modo de prueba)",
    },
}

def add_arb_keys():
    """Add new ARB keys to all language files"""
    languages = {
        "ja": "lib/l10n/app_ja.arb",
        "en": "lib/l10n/app_en.arb",
        "ko": "lib/l10n/app_ko.arb",
        "zh": "lib/l10n/app_zh.arb",
        "zh_TW": "lib/l10n/app_zh_TW.arb",
        "de": "lib/l10n/app_de.arb",
        "es": "lib/l10n/app_es.arb",
    }
    
    total_added = 0
    
    for lang, file_path in languages.items():
        print(f"Processing: {file_path}")
        
        with open(file_path, 'r', encoding='utf-8') as f:
            arb_data = json.load(f)
        
        if lang == "ja":
            keys_to_add = NEW_KEYS
        else:
            keys_to_add = TRANSLATIONS[lang]
        
        added_count = 0
        for key, value in keys_to_add.items():
            if key not in arb_data:
                arb_data[key] = value
                added_count += 1
                print(f"  + Added: {key}")
        
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(arb_data, f, ensure_ascii=False, indent=2)
        
        print(f"  Added {added_count} keys")
        total_added += added_count
        print()
    
    print("=" * 70)
    print(f"Total keys added: {total_added}")
    print("=" * 70)

if __name__ == "__main__":
    add_arb_keys()
