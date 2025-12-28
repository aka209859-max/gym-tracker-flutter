#!/usr/bin/env python3
"""
Week 3 Day 7 Phase 1: 4ファイルの文字列置換（12件）
"""

import re

FILES = {
    "achievements_screen.dart": [
        # 1. バッジ読み込み失敗 (行84)
        (
            r"Text\('バッジの読み込みに失敗しました: \$e'\)",
            r"Text(AppLocalizations.of(context)!.achievements_loadFailed(e.toString()))"
        ),
        # 2. タイトル (行99)
        (
            r"Text\('達成バッジ'\)",
            r"Text(AppLocalizations.of(context)!.achievements_title)"
        ),
        # 3. バッジなし (行229)
        (
            r"Text\('バッジがありません'\)",
            r"Text(AppLocalizations.of(context)!.achievements_noBadges)"
        ),
    ],
    "personal_factors_screen.dart": [
        # 4. 保存完了 (行100)
        (
            r"Text\('✅ 保存完了！現在のPFM: \$\{newPFM\.toStringAsFixed\(2\)\}x'\)",
            r"Text(AppLocalizations.of(context)!.personalFactors_saved(newPFM.toStringAsFixed(2)))"
        ),
        # 5. 保存エラー (行109)
        (
            r"Text\('❌ 保存エラー: \$e'\)",
            r"Text(AppLocalizations.of(context)!.personalFactors_saveError(e.toString()))"
        ),
        # 6. タイトル (行136)
        (
            r"Text\('🔬 個人要因設定'\)",
            r"Text(AppLocalizations.of(context)!.personalFactors_title)"
        ),
    ],
    "favorites_screen.dart": [
        # 7. 削除確認 (行95)
        (
            r"Text\('「\$\{gym\.name\}」をお気に入りから削除しますか？'\)",
            r"Text(AppLocalizations.of(context)!.favorites_removeConfirm(gym.name))"
        ),
        # 8. 削除完了 (行119)
        (
            r"Text\('\$\{gym\.name\} をお気に入りから削除しました'\)",
            r"Text(AppLocalizations.of(context)!.favorites_removed(gym.name))"
        ),
        # 9. すべて削除 (行356)
        (
            r"Text\('すべて削除'\)",
            r"Text(AppLocalizations.of(context)!.favorites_removeAll)"
        ),
    ],
    "gym_detail_screen.dart": [
        # 10. シェア失敗 (行915)
        (
            r"Text\('シェアに失敗しました: \$e'\)",
            r"Text(AppLocalizations.of(context)!.gymDetail_shareFailed(e.toString()))"
        ),
        # 11. トロフィー (行1130)
        (
            r"Text\('🏆', style: TextStyle\(fontSize: 14\)\)",
            r"Text(AppLocalizations.of(context)!.gymDetail_trophy, style: TextStyle(fontSize: 14))"
        ),
        # 12. エラー (行1632)
        (
            r"Text\('エラー: \$e'\)",
            r"Text(AppLocalizations.of(context)!.gymDetail_error(e.toString()))"
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
    
    print(f"\n🎉 Week 3 Day 7 Phase 1 - 文字列置換完了")
    print(f"Total replacements: {total_replaced}/12")

if __name__ == "__main__":
    apply_replacements()
