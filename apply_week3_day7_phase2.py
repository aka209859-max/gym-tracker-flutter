#!/usr/bin/env python3
"""
Week 3 Day 7 Phase 2: 4ファイルの文字列置換（16件）
"""

import re

FILES = {
    "partner/chat_screen_partner.dart": [
        # 1. ブロック確認 (行110)
        (
            r"Text\('\$\{widget\.partner\.displayName\}さんをブロックしますか？'\)",
            r"Text(AppLocalizations.of(context)!.chat_blockConfirm(widget.partner.displayName))"
        ),
        # 2. ブロックボタン (行129)
        (
            r"const Text\('ブロック'\)",
            r"Text(AppLocalizations.of(context)!.chat_blockButton)"
        ),
        # 3. ブロック完了 (行147)
        (
            r"const SnackBar\(content: Text\('ブロックしました'\)\)",
            r"SnackBar(content: Text(AppLocalizations.of(context)!.chat_blocked))"
        ),
        # 4. 通報完了 (行239)
        (
            r"const SnackBar\(content: Text\('通報を受け付けました。ご協力ありがとうございます。'\)\)",
            r"SnackBar(content: Text(AppLocalizations.of(context)!.chat_reported))"
        ),
        # 5. ブロックする (行272)
        (
            r"Text\('ブロックする'\)",
            r"Text(AppLocalizations.of(context)!.chat_blockAction)"
        ),
    ],
    "debug_log_screen.dart": [
        # 6. タイトル (行20)
        (
            r"const Text\('デバッグログ'\)",
            r"Text(AppLocalizations.of(context)!.debug_title)"
        ),
        # 7. コピー完了 (行31)
        (
            r"Text\('ログをクリップボードにコピーしました'\)",
            r"Text(AppLocalizations.of(context)!.debug_logCopied)"
        ),
        # 8. クリア完了 (行46)
        (
            r"Text\('ログをクリアしました'\)",
            r"Text(AppLocalizations.of(context)!.debug_logCleared)"
        ),
    ],
    "po/po_dashboard_screen.dart": [
        # 9. タイトル (行139)
        (
            r"const Text\('PO管理ダッシュボード'\)",
            r"Text(AppLocalizations.of(context)!.po_dashboardTitle)"
        ),
        # 10. 会員管理 (行206)
        (
            r"const SnackBar\(content: Text\('会員管理画面は次のフェーズで実装予定'\)\)",
            r"SnackBar(content: Text(AppLocalizations.of(context)!.po_memberManagementComingSoon))"
        ),
        # 11. セッション管理 (行217)
        (
            r"const SnackBar\(content: Text\('セッション管理画面は次のフェーズで実装予定'\)\)",
            r"SnackBar(content: Text(AppLocalizations.of(context)!.po_sessionManagementComingSoon))"
        ),
        # 12. 分析 (行228)
        (
            r"const SnackBar\(content: Text\('分析画面は次のフェーズで実装予定'\)\)",
            r"SnackBar(content: Text(AppLocalizations.of(context)!.po_analyticsComingSoon))"
        ),
    ],
    "partner_photos_screen.dart": [
        # 13. アップロード成功 (行112)
        (
            r"Text\('✅ \$\{images\.length\}枚の画像をアップロードしました！'\)",
            r"Text(AppLocalizations.of(context)!.partnerPhotos_uploadSuccess(images.length))"
        ),
        # 14. アップロード失敗 (行125)
        (
            r"Text\('❌ アップロード失敗: \$e'\)",
            r"Text(AppLocalizations.of(context)!.partnerPhotos_uploadFailed(e.toString()))"
        ),
        # 15. 削除確認 (行142)
        (
            r"Text\('画像を削除'\)",
            r"Text(AppLocalizations.of(context)!.partnerPhotos_deleteConfirm)"
        ),
        # 16. タイトル (行201)
        (
            r"const Text\('店舗画像管理'\)",
            r"Text(AppLocalizations.of(context)!.partnerPhotos_title)"
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
    
    print(f"\n🎉 Week 3 Day 7 Phase 2 - 文字列置換完了")
    print(f"Total replacements: {total_replaced}/16")

if __name__ == "__main__":
    apply_replacements()
