#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Week 4 Day 9 Phase 2: 文字列置換スクリプト
22ファイル、26個の文字列を置換
"""

import re
import os

# 置換対象ファイルと置換パターン
REPLACEMENTS = [
    # 1. admin/phase_migration_screen.dart (1件)
    {
        'file': 'lib/screens/admin/phase_migration_screen.dart',
        'patterns': [
            {
                'old': "'データ戦略フェーズ管理'",
                'new': "AppLocalizations.of(context)!.admin_phaseMigrationTitle",
            },
        ]
    },
    
    # 2. ai_addon_purchase_screen.dart (1件)
    {
        'file': 'lib/screens/ai_addon_purchase_screen.dart',
        'patterns': [
            {
                'old': "'AI追加購入'",
                'new': "AppLocalizations.of(context)!.aiAddon_purchaseTitle",
            },
        ]
    },
    
    # 3. campaign/campaign_registration_screen.dart (1件)
    {
        'file': 'lib/screens/campaign/campaign_registration_screen.dart',
        'patterns': [
            {
                'old': "'🎉 乗り換え割キャンペーン'",
                'new': "AppLocalizations.of(context)!.campaign_switchDiscountTitle",
            },
        ]
    },
    
    # 4. campaign/campaign_sns_share_screen.dart (1件)
    {
        'file': 'lib/screens/campaign/campaign_sns_share_screen.dart',
        'patterns': [
            {
                'old': "'SNSアプリで投稿'",
                'new': "AppLocalizations.of(context)!.campaign_shareOnSNS",
            },
        ]
    },
    
    # 5. crowd_report_screen.dart (1件)
    {
        'file': 'lib/screens/crowd_report_screen.dart',
        'patterns': [
            {
                'old': "'🎁 AI 1回分をプレゼント！（報告${result.reportCount}回目）'",
                'new': "AppLocalizations.of(context)!.crowdReport_aiReward(result.reportCount.toString())",
            },
        ]
    },
    
    # 6. fatigue_management_screen.dart (1件)
    {
        'file': 'lib/screens/fatigue_management_screen.dart',
        'patterns': [
            {
                'old': "'❌ エラー: $e'",
                'new': "AppLocalizations.of(context)!.fatigue_errorMessage(e.toString())",
            },
        ]
    },
    
    # 7. messages/chat_detail_screen.dart (1件)
    {
        'file': 'lib/screens/messages/chat_detail_screen.dart',
        'patterns': [
            {
                'old': "'メッセージの送信に失敗しました: $e'",
                'new': "AppLocalizations.of(context)!.messages_sendError(e.toString())",
            },
        ]
    },
    
    # 8. onboarding/onboarding_screen.dart (1件)
    {
        'file': 'lib/screens/onboarding/onboarding_screen.dart',
        'patterns': [
            {
                'old': "'🎉 紹介コードを適用しました！AI無料利用×3回を獲得！'",
                'new': "AppLocalizations.of(context)!.onboarding_referralApplied",
            },
        ]
    },
    
    # 9. partner/partner_requests_screen.dart (1件)
    {
        'file': 'lib/screens/partner/partner_requests_screen.dart',
        'patterns': [
            {
                'old': "'パートナーリクエスト'",
                'new': "AppLocalizations.of(context)!.partnerRequests_title",
            },
        ]
    },
    
    # 10. po/po_sessions_screen.dart (1件)
    {
        'file': 'lib/screens/po/po_sessions_screen.dart',
        'patterns': [
            {
                'old': "'近日公開予定'",
                'new': "AppLocalizations.of(context)!.poSessions_comingSoon",
            },
        ]
    },
    
    # 11. redeem_invite_code_screen.dart (1件)
    {
        'file': 'lib/screens/redeem_invite_code_screen.dart',
        'patterns': [
            {
                'old': "'招待コードを使用'",
                'new': "AppLocalizations.of(context)!.redeemInvite_useInviteCode",
            },
        ]
    },
    
    # 12. settings/notification_settings_screen.dart (1件)
    {
        'file': 'lib/screens/settings/notification_settings_screen.dart',
        'patterns': [
            {
                'old': "'リマインダー時刻を${_formatTime(_reminderTime)}に設定しました'",
                'new': "AppLocalizations.of(context)!.notificationSettings_reminderSet(_formatTime(_reminderTime))",
            },
        ]
    },
    
    # 13. settings/tokutei_shoutorihikihou_screen.dart (1件)
    {
        'file': 'lib/screens/settings/tokutei_shoutorihikihou_screen.dart',
        'patterns': [
            {
                'old': "'特定商取引法に基づく表記'",
                'new': "AppLocalizations.of(context)!.settings_commercialTransactionAct",
            },
        ]
    },
    
    # 14. settings/trial_progress_screen.dart (1件)
    {
        'file': 'lib/screens/settings/trial_progress_screen.dart',
        'patterns': [
            {
                'old': "'トライアル進捗'",
                'new': "AppLocalizations.of(context)!.settings_trialProgress",
            },
        ]
    },
    
    # 15. workout/add_workout_screen_complete.dart (1件)
    {
        'file': 'lib/screens/workout/add_workout_screen_complete.dart',
        'patterns': [
            {
                'old': "'💡'",
                'new': "AppLocalizations.of(context)!.workout_lightbulbIcon",
            },
        ]
    },
    
    # 16. workout/create_template_screen.dart (1件)
    {
        'file': 'lib/screens/workout/create_template_screen.dart',
        'patterns': [
            {
                'old': "'保存エラー: $e'",
                'new': "AppLocalizations.of(context)!.workoutTemplate_saveError(e.toString())",
            },
        ]
    },
    
    # 17. workout/rm_calculator_screen.dart (1件)
    {
        'file': 'lib/screens/workout/rm_calculator_screen.dart',
        'patterns': [
            {
                'old': "'バーの重量（${_barWeight}kg）より大きい値を入力してください'",
                'new': "AppLocalizations.of(context)!.rmCalculator_barWeightError(_barWeight.toString())",
            },
        ]
    },
    
    # 18. workout/statistics_dashboard_screen.dart (2件)
    {
        'file': 'lib/screens/workout/statistics_dashboard_screen.dart',
        'patterns': [
            {
                'old': "'統計ダッシュボード'",
                'new': "AppLocalizations.of(context)!.statisticsDashboard_title",
            },
        ]
    },
    
    # 19. workout/template_screen.dart (2件)
    {
        'file': 'lib/screens/workout/template_screen.dart',
        'patterns': [
            {
                'old': "'ワークアウトテンプレート'",
                'new': "AppLocalizations.of(context)!.workoutTemplate_title",
            },
            {
                'old': "'「${template.name}」を削除しますか？'",
                'new': "AppLocalizations.of(context)!.workoutTemplate_deleteConfirm(template.name)",
            },
        ]
    },
    
    # 20. workout/weekly_reports_screen.dart (1件)
    {
        'file': 'lib/screens/workout/weekly_reports_screen.dart',
        'patterns': [
            {
                'old': "'${report.totalWorkouts}回 • ${report.totalMinutes}分'",
                'new': "AppLocalizations.of(context)!.weeklyReports_workoutsSummary(report.totalWorkouts.toString(), report.totalMinutes.toString())",
            },
        ]
    },
    
    # 21. workout/workout_memo_list_screen.dart (2件)
    {
        'file': 'lib/screens/workout/workout_memo_list_screen.dart',
        'patterns': [
            {
                'old': "'メモを更新しました'",
                'new': "AppLocalizations.of(context)!.workoutMemo_updated",
            },
            {
                'old': "'メモを削除'",
                'new': "AppLocalizations.of(context)!.workoutMemo_delete",
            },
        ]
    },
    
    # 22. workout_import_preview_screen.dart (1件)
    {
        'file': 'lib/screens/workout_import_preview_screen.dart',
        'patterns': [
            {
                'old': "'📸 トレーニング記録の取り込み'",
                'new': "AppLocalizations.of(context)!.workoutImport_title",
            },
        ]
    },
]

def apply_replacements():
    """ファイルごとに文字列を置換"""
    total_replacements = 0
    
    for file_info in REPLACEMENTS:
        file_path = file_info['file']
        patterns = file_info['patterns']
        
        if not os.path.exists(file_path):
            print(f"⚠️  {file_path} が見つかりません")
            continue
        
        print(f"\n📝 {file_path}")
        
        # ファイル読み込み
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        file_replacements = 0
        for i, pattern in enumerate(patterns, 1):
            old = pattern['old']
            new = pattern['new']
            
            if old in content:
                content = content.replace(old, new)
                file_replacements += 1
                total_replacements += 1
                print(f"  ✅ Pattern {i}/{len(patterns)}: 置換完了")
            else:
                print(f"  ⚠️  Pattern {i}/{len(patterns)}: パターンが見つかりません")
        
        # ファイル書き込み
        if file_replacements > 0:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"  💾 {file_replacements}/{len(patterns)} 件を置換して保存")
    
    print(f"\n" + "="*60)
    print(f"✅ Phase 2 文字列置換完了: {total_replacements} 件")
    print("="*60)

if __name__ == '__main__':
    apply_replacements()
