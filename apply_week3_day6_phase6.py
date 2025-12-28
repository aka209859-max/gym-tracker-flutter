#!/usr/bin/env python3
"""
Week 3 Day 6 Phase 6: campaign & partner の文字列置換

対象: 7件の文字列
"""

import re

FILES = {
    "campaign/campaign_sns_share_screen.dart": [
        # 1. テンプレートコピー (行42)
        (
            r"Text\('✅ テンプレートをコピーしました！'\)",
            r"Text(AppLocalizations.of(context)!.campaign_templateCopied)"
        ),
        # 2. タイトル (行152)
        (
            r"const Text\('📱 SNSでシェア'\)",
            r"Text(AppLocalizations.of(context)!.campaign_snsShare)"
        ),
        # 3. コピーボタン (行180)
        (
            r"const Text\('テンプレートをコピー'\)",
            r"Text(AppLocalizations.of(context)!.campaign_copyTemplate)"
        ),
    ],
    "partner/partner_detail_screen.dart": [
        # 4. 友達申請送信 (行57)
        (
            r"const SnackBar\(content: Text\('友達申請を送信しました'\)\)",
            r"SnackBar(content: Text(AppLocalizations.of(context)!.partner_friendRequestSent))"
        ),
        # 5. メッセージ送信条件 (行96)
        (
            r"Text\('友達になってからメッセージを送信できます'\)",
            r"Text(AppLocalizations.of(context)!.partner_friendRequiredForMessage)"
        ),
        # 6. タイトル (行143)
        (
            r"Text\('パートナー詳細'\)",
            r"Text(AppLocalizations.of(context)!.partner_detailTitle)"
        ),
        # 7. 友達申請ボタン (行246)
        (
            r"Text\('友達申請', style: TextStyle\(fontSize: 16\)\)",
            r"Text(AppLocalizations.of(context)!.partner_sendFriendRequest, style: TextStyle(fontSize: 16))"
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
    
    print(f"\n🎉 Week 3 Day 6 Phase 6 - 文字列置換完了")
    print(f"Total replacements: {total_replaced}/7")

if __name__ == "__main__":
    apply_replacements()
