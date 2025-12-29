#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Week 4 Day 9 Phase 1: 文字列置換スクリプト
20ファイル、46個の文字列を置換
"""

import re
import os

# 置換対象ファイルと置換パターン
REPLACEMENTS = [
    # 1. partner_campaign_editor_screen.dart (4件)
    {
        'file': 'lib/screens/partner_campaign_editor_screen.dart',
        'patterns': [
            {
                'old': "'画像の読み込みに失敗しました: $e'",
                'new': "AppLocalizations.of(context)!.partnerCampaign_imageLoadError(e.toString())",
            },
            {
                'old': "'✅ キャンペーンを保存しました！ユーザーアプリに即反映されます'",
                'new': "AppLocalizations.of(context)!.partnerCampaign_saved",
            },
            {
                'old': "'❌ 保存に失敗しました: $e'",
                'new': "AppLocalizations.of(context)!.partnerCampaign_saveError(e.toString())",
            },
            {
                'old': "'🏆 キャンペーン編集'",
                'new': "AppLocalizations.of(context)!.partnerCampaign_editorTitle",
            },
        ]
    },
    
    # 2. po/po_analytics_screen.dart (4件)
    {
        'file': 'lib/screens/po/po_analytics_screen.dart',
        'patterns': [
            {
                'old': "'休眠会員: $dormantMembers名'",
                'new': "AppLocalizations.of(context)!.poAnalytics_dormantMembers(dormantMembers.toString())",
            },
            {
                'old': "'最終セッションから2週間以上経過'",
                'new': "AppLocalizations.of(context)!.poAnalytics_dormantDescription",
            },
            {
                'old': "'一斉メッセージ機能は近日公開予定です'",
                'new': "AppLocalizations.of(context)!.poAnalytics_broadcastComingSoon",
            },
            {
                'old': "'対応する'",
                'new': "AppLocalizations.of(context)!.poAnalytics_respond",
            },
        ]
    },
    
    # 3. partner_dashboard_screen.dart (3件)
    {
        'file': 'lib/screens/partner_dashboard_screen.dart',
        'patterns': [
            {
                'old': "'パートナー管理画面'",
                'new': "AppLocalizations.of(context)!.partnerDashboard_title",
            },
            {
                'old': "'🚧 実装予定の機能です'",
                'new': "AppLocalizations.of(context)!.partnerDashboard_comingSoon",
            },
        ]
    },
    
    # 4. partner/partner_profile_detail_screen.dart (3件)
    {
        'file': 'lib/screens/partner/partner_profile_detail_screen.dart',
        'patterns': [
            {
                'old': "'•'",
                'new': "AppLocalizations.of(context)!.partnerProfile_bullet",
            },
            {
                'old': "'Pro限定機能'",
                'new': "AppLocalizations.of(context)!.partnerProfile_proOnlyFeature",
            },
            {
                'old': "'✨ Proプランの特典'",
                'new': "AppLocalizations.of(context)!.partnerProfile_proBenefits",
            },
        ]
    },
    
    # 5. personal_training_screen.dart (3件)
    {
        'file': 'lib/screens/personal_training_screen.dart',
        'patterns': [
            {
                'old': "'予約状況機能は開発中です'",
                'new': "AppLocalizations.of(context)!.personalTraining_reservationComingSoon",
            },
            {
                'old': "'新規予約機能は開発中です'",
                'new': "AppLocalizations.of(context)!.personalTraining_newReservationComingSoon",
            },
            {
                'old': "'トレーナー記録機能は開発中です'",
                'new': "AppLocalizations.of(context)!.personalTraining_trainerRecordComingSoon",
            },
        ]
    },
    
    # 6. body_measurement_screen.dart (2件)
    {
        'file': 'lib/screens/body_measurement_screen.dart',
        'patterns': [
            {
                'old': "'yyyy年MM月dd日'",
                'new': "AppLocalizations.of(context)!.bodyMeasurement_dateFormat",
            },
            {
                'old': "'  •  '",
                'new': "AppLocalizations.of(context)!.bodyMeasurement_bulletSeparator",
            },
        ]
    },
    
    # 7. calculators_screen.dart (2件)
    {
        'file': 'lib/screens/calculators_screen.dart',
        'patterns': [
            {
                'old': "'${entry.key}回'",
                'new': "AppLocalizations.of(context)!.calculators_repsCount(entry.key.toString())",
            },
            {
                'old': "'${entry.key} kg プレート'",
                'new': "AppLocalizations.of(context)!.calculators_plateWeight(entry.key.toString())",
            },
        ]
    },
    
    # 8. chat_screen.dart (2件)
    {
        'file': 'lib/screens/chat_screen.dart',
        'patterns': [
            {
                'old': "'メッセージ送信に失敗しました'",
                'new': "AppLocalizations.of(context)!.chat_sendMessageError",
            },
            {
                'old': "'メッセージの読み込みに失敗しました'",
                'new': "AppLocalizations.of(context)!.chat_loadMessageError",
            },
        ]
    },
    
    # 9. map_screen.dart (2件)
    {
        'file': 'lib/screens/map_screen.dart',
        'patterns': [
            {
                'old': "'位置情報を使用しますか？'",
                'new': "AppLocalizations.of(context)!.map_locationPermission",
            },
            {
                'old': "'${gyms.length}件のジムが見つかりました'",
                'new': "AppLocalizations.of(context)!.map_gymsFound(gyms.length.toString())",
            },
        ]
    },
    
    # 10. partner/partner_profile_edit_screen.dart (2件)
    {
        'file': 'lib/screens/partner/partner_profile_edit_screen.dart',
        'patterns': [
            {
                'old': "'中級者'",
                'new': "AppLocalizations.of(context)!.partnerProfileEdit_intermediateLevel",
            },
            {
                'old': "'好きな種目'",
                'new': "AppLocalizations.of(context)!.partnerProfileEdit_favoriteExercises",
            },
        ]
    },
    
    # 11. partner_equipment_editor_screen.dart (2件)
    {
        'file': 'lib/screens/partner_equipment_editor_screen.dart',
        'patterns': [
            {
                'old': "'✅ 設備情報を更新しました！'",
                'new': "AppLocalizations.of(context)!.partnerEquipment_updated",
            },
            {
                'old': "'❌ 保存に失敗しました: $e'",
                'new': "AppLocalizations.of(context)!.partnerEquipment_saveError(e.toString())",
            },
        ]
    },
    
    # 12. partner_reservation_settings_screen.dart (2件)
    {
        'file': 'lib/screens/partner_reservation_settings_screen.dart',
        'patterns': [
            {
                'old': "'✅ 予約設定を更新しました！'",
                'new': "AppLocalizations.of(context)!.partnerReservation_updated",
            },
            {
                'old': "'❌ 保存に失敗しました: $e'",
                'new': "AppLocalizations.of(context)!.partnerReservation_saveError(e.toString())",
            },
        ]
    },
    
    # 13. personal_training/trainer_records_screen.dart (2件)
    {
        'file': 'lib/screens/personal_training/trainer_records_screen.dart',
        'patterns': [
            {
                'old': "'✅ トレーニング記録を保存しました'",
                'new': "AppLocalizations.of(context)!.trainerRecords_saved",
            },
            {
                'old': "'再読み込み'",
                'new': "AppLocalizations.of(context)!.trainerRecords_reload",
            },
        ]
    },
    
    # 14. po/po_members_screen.dart (2件)
    {
        'file': 'lib/screens/po/po_members_screen.dart',
        'patterns': [
            {
                'old': "'全会員'",
                'new': "AppLocalizations.of(context)!.poMembers_allMembers",
            },
            {
                'old': "'休眠中'",
                'new': "AppLocalizations.of(context)!.poMembers_dormant",
            },
        ]
    },
    
    # 15. profile_edit_screen.dart (2件)
    {
        'file': 'lib/screens/profile_edit_screen.dart',
        'patterns': [
            {
                'old': "'画像の読み込みに失敗しました\\n$e'",
                'new': "AppLocalizations.of(context)!.profileEdit_imageLoadError(e.toString())",
            },
            {
                'old': "'Proプラン限定機能'",
                'new': "AppLocalizations.of(context)!.profileEdit_proOnlyFeature",
            },
        ]
    },
    
    # 16. profile_screen.dart (2件)
    {
        'file': 'lib/screens/profile_screen.dart',
        'patterns': [
            {
                'old': "'サービス利用条件・サブスクリプション'",
                'new': "AppLocalizations.of(context)!.profile_termsAndSubscription",
            },
            {
                'old': "'個人情報の取扱い'",
                'new': "AppLocalizations.of(context)!.profile_privacyPolicy",
            },
        ]
    },
    
    # 17. reservation_form_screen.dart (2件)
    {
        'file': 'lib/screens/reservation_form_screen.dart',
        'patterns': [
            {
                'old': "'✅ 予約申込を送信しました！店舗から連絡があります。'",
                'new': "AppLocalizations.of(context)!.reservation_submitted",
            },
            {
                'old': "'❌ 予約送信に失敗しました: $e'",
                'new': "AppLocalizations.of(context)!.reservation_submitError(e.toString())",
            },
        ]
    },
    
    # 18. subscription_screen.dart (2件)
    {
        'file': 'lib/screens/subscription_screen.dart',
        'patterns': [
            {
                'old': "'4. 「GYM MATCH」を選択'",
                'new': "AppLocalizations.of(context)!.subscription_step4",
            },
            {
                'old': "'5. 希望のプランを選択'",
                'new': "AppLocalizations.of(context)!.subscription_step5",
            },
        ]
    },
    
    # 19. visit_history_screen.dart (2件)
    {
        'file': 'lib/screens/visit_history_screen.dart',
        'patterns': [
            {
                'old': "'訪問履歴を削除'",
                'new': "AppLocalizations.of(context)!.visitHistory_deleteHistory",
            },
            {
                'old': "'再読み込み'",
                'new': "AppLocalizations.of(context)!.visitHistory_reload",
            },
        ]
    },
    
    # 20. workout/personal_records_screen.dart (2件)
    {
        'file': 'lib/screens/workout/personal_records_screen.dart',
        'patterns': [
            {
                'old': "'${bodyPartExercises.length}種目'",
                'new': "AppLocalizations.of(context)!.personalRecords_exerciseCount(bodyPartExercises.length.toString())",
            },
            {
                'old': "'$bodyPart - PR記録'",
                'new': "AppLocalizations.of(context)!.personalRecords_bodyPartTitle(bodyPart)",
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
    print(f"✅ Phase 1 文字列置換完了: {total_replacements} 件")
    print("="*60)

if __name__ == '__main__':
    apply_replacements()
