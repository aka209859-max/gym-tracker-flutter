#!/usr/bin/env python3
"""
Week 3 Day 6 Phase 5: weekly_reports & body_part_tracking の文字列置換

対象: 5件の文字列
"""

import re

FILES = {
    "workout/weekly_reports_screen.dart": [
        # 1. 週次レコメンデーション (行175)
        (
            r"const Text\('週次レコメンデーション'\)",
            r"Text(AppLocalizations.of(context)!.weeklyReports_recommendation)"
        ),
        # 2. サブタイトル (行176)
        (
            r"const Text\('推奨曜日とメニュー提案を表示'\)",
            r"Text(AppLocalizations.of(context)!.weeklyReports_recommendationSubtitle)"
        ),
    ],
    "workout/body_part_tracking_screen.dart": [
        # 3-5. 期間選択ボタン (行156-158)
        (
            r"ButtonSegment\(value: 7, label: Text\('7日'\)\)",
            r"ButtonSegment(value: 7, label: Text(AppLocalizations.of(context)!.bodyPart_days7))"
        ),
        (
            r"ButtonSegment\(value: 30, label: Text\('30日'\)\)",
            r"ButtonSegment(value: 30, label: Text(AppLocalizations.of(context)!.bodyPart_days30))"
        ),
        (
            r"ButtonSegment\(value: 90, label: Text\('90日'\)\)",
            r"ButtonSegment(value: 90, label: Text(AppLocalizations.of(context)!.bodyPart_days90))"
        ),
    ]
}

def apply_replacements():
    """すべてのファイルに文字列置換を適用"""
    
    total_replaced = 0
    
    for filename, replacements in FILES.items():
        file_path = f"lib/screens/{filename}"
        
        print(f"\n📁 {filename}")
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        file_replaced = 0
        for i, (pattern, replacement) in enumerate(replacements, 1):
            new_content = re.sub(pattern, replacement, content)
            if new_content != content:
                file_replaced += 1
                total_replaced += 1
                print(f"  ✅ Pattern {i}: 置換成功")
            else:
                print(f"  ⚠️  Pattern {i}: マッチなし")
            content = new_content
        
        # ファイルに書き込み
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"  📊 {filename}: {file_replaced}/{len(replacements)} 置換")
    
    print(f"\n🎉 Week 3 Day 6 Phase 5 - 文字列置換完了")
    print(f"Total replacements: {total_replaced}/5")

if __name__ == "__main__":
    apply_replacements()
