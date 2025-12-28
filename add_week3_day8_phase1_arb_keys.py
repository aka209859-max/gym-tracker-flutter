#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Week 3 Day 8 Phase 1: ARBキー追加スクリプト
対象: home_screen.dart (10件)
"""

import json
import os

def add_arb_keys():
    """7言語のARBファイルにキーを追加"""
    
    # ARBキー定義（10件）
    keys = {
        "home_streakTitle": {
            "ja": "7日連続達成！",
            "en": "7-Day Streak Achieved!",
            "zh": "连续7天达成！",
            "ko": "7일 연속 달성!",
            "es": "¡7 días seguidos logrados!",
            "de": "7 Tage in Folge erreicht!",
            "zh_TW": "連續7天達成！"
        },
        "home_streakMessage": {
            "ja": "おめでとうございます！\n7日間連続でトレーニングを記録しました。\nこの調子で続けましょう！💪",
            "en": "Congratulations!\nYou've recorded training for 7 consecutive days.\nKeep up the great work! 💪",
            "zh": "恭喜！\n您已连续记录训练7天。\n继续保持！💪",
            "ko": "축하합니다!\n7일 연속으로 운동을 기록했습니다.\n계속 힘내세요! 💪",
            "es": "¡Felicidades!\nHas registrado entrenamientos durante 7 días seguidos.\n¡Sigue así! 💪",
            "de": "Herzlichen Glückwunsch!\nDu hast 7 Tage in Folge trainiert.\nMach weiter so! 💪",
            "zh_TW": "恭喜！\n您已連續記錄訓練7天。\n繼續保持！💪"
        },
        "home_milestoneMessage": {
            "ja": "すごい！マイルストーン達成です！\nこの調子で続けていきましょう！💪",
            "en": "Amazing! Milestone achieved!\nKeep going at this pace! 💪",
            "zh": "太棒了！达成里程碑！\n继续保持这个节奏！💪",
            "ko": "대단해요! 이정표 달성!\n이 페이스로 계속하세요! 💪",
            "es": "¡Increíble! ¡Hito alcanzado!\n¡Sigue a este ritmo! 💪",
            "de": "Großartig! Meilenstein erreicht!\nMach in diesem Tempo weiter! 💪",
            "zh_TW": "太棒了！達成里程碑！\n繼續保持這個節奏！💪"
        },
        "home_tapToShowStats": {
            "ja": "タップして詳細統計を表示",
            "en": "Tap to show detailed statistics",
            "zh": "点击显示详细统计",
            "ko": "탭하여 상세 통계 표시",
            "es": "Toca para mostrar estadísticas detalladas",
            "de": "Tippen, um detaillierte Statistiken anzuzeigen",
            "zh_TW": "點擊顯示詳細統計"
        },
        "home_aiSuggestionTitle": {
            "ja": "💡 今日のAI提案",
            "en": "💡 Today's AI Suggestion",
            "zh": "💡 今日AI建议",
            "ko": "💡 오늘의 AI 제안",
            "es": "💡 Sugerencia de IA de hoy",
            "de": "💡 Heutige KI-Empfehlung",
            "zh_TW": "💡 今日AI建議"
        },
        "home_aiSuggestionPrompt": {
            "ja": "あなた専用のトレーニングメニューを\nAIが科学的に分析します",
            "en": "AI scientifically analyzes\nyour personalized training menu",
            "zh": "AI科学分析\n您的专属训练菜单",
            "ko": "AI가 과학적으로 분석한\n맞춤형 운동 메뉴",
            "es": "IA analiza científicamente\ntu menú de entrenamiento personalizado",
            "de": "KI analysiert wissenschaftlich\ndein personalisiertes Trainingsmenü",
            "zh_TW": "AI科學分析\n您的專屬訓練菜單"
        },
        "home_currentStreakDays": {
            "ja": "連続 {days} 日",
            "en": "{days}-day streak",
            "zh": "连续 {days} 天",
            "ko": "연속 {days}일",
            "es": "{days} días seguidos",
            "de": "{days} Tage in Folge",
            "zh_TW": "連續 {days} 天",
            "placeholders": {
                "days": {
                    "type": "int"
                }
            }
        },
        "home_streakRecording": {
            "ja": "{days}日連続記録中！",
            "en": "Recording for {days} consecutive days!",
            "zh": "连续记录 {days} 天！",
            "ko": "{days}일 연속 기록 중!",
            "es": "¡Registrando durante {days} días seguidos!",
            "de": "{days} Tage hintereinander aufgezeichnet!",
            "zh_TW": "連續記錄 {days} 天！",
            "placeholders": {
                "days": {
                    "type": "int"
                }
            }
        },
        "home_weeklyProgressPercent": {
            "ja": "{percent}% 達成",
            "en": "{percent}% achieved",
            "zh": "完成 {percent}%",
            "ko": "{percent}% 달성",
            "es": "{percent}% logrado",
            "de": "{percent}% erreicht",
            "zh_TW": "完成 {percent}%",
            "placeholders": {
                "percent": {
                    "type": "int"
                }
            }
        },
        "home_recordPrompt": {
            "ja": "トレーニングを記録して、\n進捗を可視化しましょう",
            "en": "Record your training\nand visualize your progress",
            "zh": "记录训练\n可视化您的进度",
            "ko": "운동을 기록하고\n진척도를 시각화하세요",
            "es": "Registra tu entrenamiento\ny visualiza tu progreso",
            "de": "Zeichne dein Training auf\nund visualisiere deinen Fortschritt",
            "zh_TW": "記錄訓練\n可視化您的進度"
        }
    }
    
    # 言語ファイルマッピング
    lang_files = {
        "ja": "lib/l10n/app_ja.arb",
        "en": "lib/l10n/app_en.arb",
        "zh": "lib/l10n/app_zh.arb",
        "ko": "lib/l10n/app_ko.arb",
        "es": "lib/l10n/app_es.arb",
        "de": "lib/l10n/app_de.arb",
        "zh_TW": "lib/l10n/app_zh_TW.arb"
    }
    
    # 各言語ファイルにキーを追加
    for lang, filepath in lang_files.items():
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # キーを追加
        for key, translations in keys.items():
            if key not in data:
                data[key] = translations[lang]
                
                # placeholdersがある場合は追加
                if "placeholders" in translations:
                    placeholder_key = f"@{key}"
                    data[placeholder_key] = {
                        "placeholders": translations["placeholders"]
                    }
        
        # ファイルに書き込み
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        print(f"✅ {filepath}: 10 keys added")
    
    print(f"\n🎉 Phase 1 ARBキー追加完了: 70エントリ (10キー × 7言語)")

if __name__ == "__main__":
    add_arb_keys()
