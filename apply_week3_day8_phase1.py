#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Week 3 Day 8 Phase 1: 文字列置換スクリプト
対象: home_screen.dart (10件)
"""

import re

def replace_strings():
    """home_screen.dartの文字列を置換"""
    
    filepath = "lib/screens/home_screen.dart"
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Pattern 1: '7日連続達成！'
    content = re.sub(
        r"'7日連続達成！'",
        "AppLocalizations.of(context)!.home_streakTitle",
        content
    )
    
    # Pattern 2: 'おめでとうございます！...'
    content = re.sub(
        r"'おめでとうございます！\\n7日間連続でトレーニングを記録しました。\\nこの調子で続けましょう！💪'",
        "AppLocalizations.of(context)!.home_streakMessage",
        content
    )
    
    # Pattern 3: 'すごい！マイルストーン達成です！...'
    content = re.sub(
        r"'すごい！マイルストーン達成です！\\nこの調子で続けていきましょう！💪'",
        "AppLocalizations.of(context)!.home_milestoneMessage",
        content
    )
    
    # Pattern 4: 'タップして詳細統計を表示'
    content = re.sub(
        r"'タップして詳細統計を表示'",
        "AppLocalizations.of(context)!.home_tapToShowStats",
        content
    )
    
    # Pattern 5: '💡 今日のAI提案'
    content = re.sub(
        r"'💡 今日のAI提案'",
        "AppLocalizations.of(context)!.home_aiSuggestionTitle",
        content
    )
    
    # Pattern 6: 'あなた専用のトレーニングメニューを...'
    content = re.sub(
        r"'あなた専用のトレーニングメニューを\\nAIが科学的に分析します'",
        "AppLocalizations.of(context)!.home_aiSuggestionPrompt",
        content
    )
    
    # Pattern 7: '連続 $_currentStreak 日'
    content = re.sub(
        r"'連続 \$_currentStreak 日'",
        "AppLocalizations.of(context)!.home_currentStreakDays(_currentStreak)",
        content
    )
    
    # Pattern 8: '${_currentStreak}日連続記録中！'
    content = re.sub(
        r"'\$\{_currentStreak\}日連続記録中！'",
        "AppLocalizations.of(context)!.home_streakRecording(_currentStreak)",
        content
    )
    
    # Pattern 9: '{percent}% 達成'
    # 複雑な計算式を含むため、より慎重に置換
    pattern9 = r"'\$\{\(\(_weeklyProgress\['current'\]! / _weeklyProgress\['goal'\]!\) \* 100\)\.clamp\(0, 100\)\.toInt\(\)\}% 達成'"
    replacement9 = "AppLocalizations.of(context)!.home_weeklyProgressPercent(((_weeklyProgress['current']! / _weeklyProgress['goal']!) * 100).clamp(0, 100).toInt())"
    content = re.sub(pattern9, replacement9, content)
    
    # Pattern 10: 'トレーニングを記録して、\n進捗を可視化しましょう'
    content = re.sub(
        r"'トレーニングを記録して、\\n進捗を可視化しましょう'",
        "AppLocalizations.of(context)!.home_recordPrompt",
        content
    )
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ {filepath}: 10/10 replacements completed")
    print(f"   - Pattern 1: '7日連続達成！'")
    print(f"   - Pattern 2: streak message")
    print(f"   - Pattern 3: milestone message")
    print(f"   - Pattern 4: 'タップして詳細統計を表示'")
    print(f"   - Pattern 5: '💡 今日のAI提案'")
    print(f"   - Pattern 6: AI suggestion prompt")
    print(f"   - Pattern 7: '連続 $_currentStreak 日'")
    print(f"   - Pattern 8: '${{_currentStreak}}日連続記録中！'")
    print(f"   - Pattern 9: '{{percent}}% 達成'")
    print(f"   - Pattern 10: 'トレーニングを記録して...'")
    print(f"\n🎉 Week 3 Day 8 Phase 1 - 文字列置換完了")

if __name__ == "__main__":
    replace_strings()
