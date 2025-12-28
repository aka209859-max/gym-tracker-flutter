#!/usr/bin/env python3
"""
Week 3 Day 6 Phase 4: 優先度高ファイルの文字列置換

対象: 10件の文字列
- redeem_invite_code_screen.dart (5件)
- gym_detail_screen.dart (1件)
- ai_addon_purchase_screen.dart (4件)
"""

import re

FILES = {
    "redeem_invite_code_screen.dart": [
        # 1. 登録完了 (行67)
        (
            r"Text\('🎉 登録完了！'\)",
            r"Text(AppLocalizations.of(context)!.invite_registrationComplete)"
        ),
        # 2. コード適用 (行74-75)
        (
            r"Text\(\s*'招待コードが正常に適用されました！',",
            r"Text(\n                  AppLocalizations.of(context)!.invite_codeApplied,"
        ),
        # 3. あなたの報酬 (行79)
        (
            r"Text\('✅ あなた: AI使用回数 \+5回'\)",
            r"Text(AppLocalizations.of(context)!.invite_yourReward)"
        ),
        # 4. 友達の報酬 (行81)
        (
            r"Text\('✅ 友達: AI使用回数 \+3回'\)",
            r"Text(AppLocalizations.of(context)!.invite_friendReward)"
        ),
        # 5. 特典反映 (行83-84)
        (
            r"Text\(\s*'特典はすぐに反映されます！',",
            r"Text(\n                  AppLocalizations.of(context)!.invite_benefitsApplied,"
        ),
    ],
    "gym_detail_screen.dart": [
        # 6. チェックイン通知 (行161)
        (
            r"Text\('\$\{widget\.gym\.name\}にチェックインしました'\)",
            r"Text(AppLocalizations.of(context)!.gym_checkedIn(widget.gym.name))"
        ),
    ],
    "ai_addon_purchase_screen.dart": [
        # 7. 購入確認タイトル (行52)
        (
            r"title: Text\('AI追加パックを購入しますか？'\)",
            r"title: Text(AppLocalizations.of(context)!.aiAddon_purchaseConfirm)"
        ),
        # 8. パック詳細 (行53-55)
        (
            r"Text\(\s*'AI追加パック（5回分）\\n'\s*'料金: ¥300\\n\\n'",
            r"Text(\n          AppLocalizations.of(context)!.aiAddon_packDetails + '\\n\\n'"
        ),
        # 9. 購入ボタン (行69)
        (
            r"const Text\('購入する'\)",
            r"Text(AppLocalizations.of(context)!.aiAddon_purchase)"
        ),
        # 10. 購入失敗 (行128)
        (
            r"const Text\('購入処理に失敗しました。\\nもう一度お試しください。'\)",
            r"Text(AppLocalizations.of(context)!.aiAddon_purchaseFailed)"
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
    
    print(f"\n🎉 Week 3 Day 6 Phase 4 - 文字列置換完了")
    print(f"Total replacements: {total_replaced}/10")

if __name__ == "__main__":
    apply_replacements()
