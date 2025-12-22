#!/usr/bin/env python3
import json

# Translation data for all languages
translations = {
    "zh": {
        "workoutDetail": "训练详情",
        "addNote": "添加备忘录",
        "editNote": "编辑备忘录",
        "noteHint": "记录训练的感想和发现...",
        "noteSaved": "备忘录已保存",
        "noteUpdated": "备忘录已更新",
        "noteDeleted": "备忘录已删除",
        "noteSaveFailed": "保存备忘录失败: {error}",
        "noteDeleteFailed": "删除备忘录失败: {error}",
        "sets": "组",
        "reps": "次",
        "weight": "重量",
        "duration": "时长",
        "rest": "休息",
        "tempo": "节奏",
        "rir": "RIR",
        "seconds": "秒",
        "minutes": "分钟",
        "workoutNotes": "训练备忘录",
        "exerciseList": "动作列表",
        "totalVolume": "总负荷量",
        "totalSets": "总组数",
        "workoutDuration": "训练时长",
        "crunch": "卷腹",
        "legRaise": "举腿",
        "plank": "平板支撑",
        "abRoller": "健腹轮",
        "hangingLegRaise": "悬垂举腿",
        "sidePlank": "侧平板支撑",
        "bicycleCrunch": "单车卷腹",
        "cableCrunch": "绳索卷腹"
    },
    "zh_TW": {
        "workoutDetail": "訓練詳情",
        "addNote": "新增備忘錄",
        "editNote": "編輯備忘錄",
        "noteHint": "記錄訓練的感想和發現...",
        "noteSaved": "備忘錄已儲存",
        "noteUpdated": "備忘錄已更新",
        "noteDeleted": "備忘錄已刪除",
        "noteSaveFailed": "儲存備忘錄失敗: {error}",
        "noteDeleteFailed": "刪除備忘錄失敗: {error}",
        "sets": "組",
        "reps": "次",
        "weight": "重量",
        "duration": "時長",
        "rest": "休息",
        "tempo": "節奏",
        "rir": "RIR",
        "seconds": "秒",
        "minutes": "分鐘",
        "workoutNotes": "訓練備忘錄",
        "exerciseList": "動作清單",
        "totalVolume": "總負荷量",
        "totalSets": "總組數",
        "workoutDuration": "訓練時長",
        "crunch": "捲腹",
        "legRaise": "舉腿",
        "plank": "平板支撐",
        "abRoller": "健腹輪",
        "hangingLegRaise": "懸垂舉腿",
        "sidePlank": "側平板支撐",
        "bicycleCrunch": "單車捲腹",
        "cableCrunch": "繩索捲腹"
    },
    "de": {
        "workoutDetail": "Trainingsdetails",
        "addNote": "Notiz hinzufügen",
        "editNote": "Notiz bearbeiten",
        "noteHint": "Eindrücke und Erkenntnisse vom Training aufzeichnen...",
        "noteSaved": "Notiz gespeichert",
        "noteUpdated": "Notiz aktualisiert",
        "noteDeleted": "Notiz gelöscht",
        "noteSaveFailed": "Notiz speichern fehlgeschlagen: {error}",
        "noteDeleteFailed": "Notiz löschen fehlgeschlagen: {error}",
        "sets": "Sätze",
        "reps": "Wdh.",
        "weight": "Gewicht",
        "duration": "Dauer",
        "rest": "Pause",
        "tempo": "Tempo",
        "rir": "RIR",
        "seconds": "Sek.",
        "minutes": "Min.",
        "workoutNotes": "Trainingsnotizen",
        "exerciseList": "Übungsliste",
        "totalVolume": "Gesamtvolumen",
        "totalSets": "Gesamtsätze",
        "workoutDuration": "Trainingsdauer",
        "crunch": "Crunch",
        "legRaise": "Beinheben",
        "plank": "Plank",
        "abRoller": "Ab Roller",
        "hangingLegRaise": "Hängendes Beinheben",
        "sidePlank": "Seitliche Plank",
        "bicycleCrunch": "Fahrrad-Crunch",
        "cableCrunch": "Kabel-Crunch"
    },
    "es": {
        "workoutDetail": "Detalles del entrenamiento",
        "addNote": "Añadir nota",
        "editNote": "Editar nota",
        "noteHint": "Registra tus impresiones y descubrimientos del entrenamiento...",
        "noteSaved": "Nota guardada",
        "noteUpdated": "Nota actualizada",
        "noteDeleted": "Nota eliminada",
        "noteSaveFailed": "Error al guardar nota: {error}",
        "noteDeleteFailed": "Error al eliminar nota: {error}",
        "sets": "Series",
        "reps": "Reps",
        "weight": "Peso",
        "duration": "Duración",
        "rest": "Descanso",
        "tempo": "Tempo",
        "rir": "RIR",
        "seconds": "seg",
        "minutes": "min",
        "workoutNotes": "Notas de entrenamiento",
        "exerciseList": "Lista de ejercicios",
        "totalVolume": "Volumen total",
        "totalSets": "Series totales",
        "workoutDuration": "Duración del entrenamiento",
        "crunch": "Crunch",
        "legRaise": "Elevación de piernas",
        "plank": "Plancha",
        "abRoller": "Rueda abdominal",
        "hangingLegRaise": "Elevación de piernas colgante",
        "sidePlank": "Plancha lateral",
        "bicycleCrunch": "Crunch bicicleta",
        "cableCrunch": "Crunch con cable"
    }
}

#  placeholders for error messages
placeholders_keys = ["noteSaveFailed", "noteDeleteFailed"]

for lang, trans in translations.items():
    file_path = f"lib/l10n/app_{lang}.arb"
    
    # Read existing ARB
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Remove closing brace
    content = content.rstrip().rstrip('}').rstrip()
    
    # Add comma if needed
    if not content.endswith(','):
        content += ','
    
    # Add new keys
    for key, value in trans.items():
        content += f'\n  "{key}": "{value}"'
        
        # Add placeholders for error messages
        if key in placeholders_keys:
            content += ',\n  "@' + key + '": {\n    "placeholders": {\n      "error": {\n        "type": "String"\n      }\n    }\n  }'
        
        # Add comma for next key (except last)
        if list(trans.keys()).index(key) < len(trans) - 1:
            content += ','
    
    # Close JSON
    content += '\n}\n'
    
    # Write back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ Updated {file_path}")

print("\n🎉 All ARB files updated with workout keys!")
