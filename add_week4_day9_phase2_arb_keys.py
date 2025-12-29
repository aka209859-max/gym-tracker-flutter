#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Week 4 Day 9 Phase 2: ARBキー追加スクリプト
残り26件を処理して100%完全翻訳達成
"""

import json
import os

# ARBファイルのパス
ARB_FILES = {
    'ja': 'lib/l10n/app_ja.arb',
    'en': 'lib/l10n/app_en.arb',
    'zh': 'lib/l10n/app_zh.arb',
    'ko': 'lib/l10n/app_ko.arb',
    'es': 'lib/l10n/app_es.arb',
    'de': 'lib/l10n/app_de.arb',
    'zh_TW': 'lib/l10n/app_zh_TW.arb',
}

# 26個のARBキーと翻訳
ARB_KEYS = {
    # 1. admin/phase_migration_screen.dart (1件)
    'admin_phaseMigrationTitle': {
        'ja': 'データ戦略フェーズ管理',
        'en': 'Data Strategy Phase Management',
        'zh': '数据策略阶段管理',
        'ko': '데이터 전략 단계 관리',
        'es': 'Gestión de Fase de Estrategia de Datos',
        'de': 'Datenstrategie-Phasenverwaltung',
        'zh_TW': '數據策略階段管理',
    },
    
    # 2. ai_addon_purchase_screen.dart (1件)
    'aiAddon_purchaseTitle': {
        'ja': 'AI追加購入',
        'en': 'AI Add-on Purchase',
        'zh': 'AI附加购买',
        'ko': 'AI 추가 구매',
        'es': 'Compra de Complemento de IA',
        'de': 'KI-Zusatzkauf',
        'zh_TW': 'AI附加購買',
    },
    
    # 3. campaign/campaign_registration_screen.dart (1件)
    'campaign_switchDiscountTitle': {
        'ja': '🎉 乗り換え割キャンペーン',
        'en': '🎉 Switch Discount Campaign',
        'zh': '🎉 转换折扣活动',
        'ko': '🎉 전환 할인 캠페인',
        'es': '🎉 Campaña de Descuento por Cambio',
        'de': '🎉 Wechselrabatt-Kampagne',
        'zh_TW': '🎉 轉換折扣活動',
    },
    
    # 4. campaign/campaign_sns_share_screen.dart (1件)
    'campaign_shareOnSNS': {
        'ja': 'SNSアプリで投稿',
        'en': 'Share on Social Media',
        'zh': '在社交媒体上发布',
        'ko': 'SNS 앱에서 게시',
        'es': 'Compartir en Redes Sociales',
        'de': 'Auf Social Media teilen',
        'zh_TW': '在社群媒體上發布',
    },
    
    # 5. crowd_report_screen.dart (1件)
    'crowdReport_aiReward': {
        'ja': '🎁 AI 1回分をプレゼント！（報告{count}回目）',
        'en': '🎁 1 AI Credit Reward! (Report #{count})',
        'zh': '🎁 赠送1次AI使用！（第{count}次报告）',
        'ko': '🎁 AI 1회분 선물！ (보고 {count}번째)',
        'es': '🎁 ¡1 Crédito de IA de Regalo! (Informe #{count})',
        'de': '🎁 1 KI-Guthaben geschenkt! (Bericht #{count})',
        'zh_TW': '🎁 贈送1次AI使用！（第{count}次報告）',
    },
    
    # 6. fatigue_management_screen.dart (1件)
    'fatigue_errorMessage': {
        'ja': '❌ エラー: {error}',
        'en': '❌ Error: {error}',
        'zh': '❌ 错误：{error}',
        'ko': '❌ 오류: {error}',
        'es': '❌ Error: {error}',
        'de': '❌ Fehler: {error}',
        'zh_TW': '❌ 錯誤：{error}',
    },
    
    # 7. messages/chat_detail_screen.dart (1件)
    'messages_sendError': {
        'ja': 'メッセージの送信に失敗しました: {error}',
        'en': 'Failed to send message: {error}',
        'zh': '消息发送失败：{error}',
        'ko': '메시지 전송 실패: {error}',
        'es': 'Error al enviar mensaje: {error}',
        'de': 'Nachricht senden fehlgeschlagen: {error}',
        'zh_TW': '訊息傳送失敗：{error}',
    },
    
    # 8. onboarding/onboarding_screen.dart (1件)
    'onboarding_referralApplied': {
        'ja': '🎉 紹介コードを適用しました！AI無料利用×3回を獲得！',
        'en': '🎉 Referral code applied! You got 3 free AI credits!',
        'zh': '🎉 已应用推荐码！获得3次免费AI使用！',
        'ko': '🎉 추천 코드 적용됨! AI 무료 이용 3회 획득!',
        'es': '🎉 ¡Código de referido aplicado! ¡Obtuviste 3 créditos de IA gratis!',
        'de': '🎉 Empfehlungscode angewendet! 3 kostenlose KI-Gutschriften erhalten!',
        'zh_TW': '🎉 已套用推薦碼！獲得3次免費AI使用！',
    },
    
    # 9. partner/partner_requests_screen.dart (1件)
    'partnerRequests_title': {
        'ja': 'パートナーリクエスト',
        'en': 'Partner Requests',
        'zh': '伙伴请求',
        'ko': '파트너 요청',
        'es': 'Solicitudes de Socios',
        'de': 'Partneranfragen',
        'zh_TW': '夥伴請求',
    },
    
    # 10. po/po_sessions_screen.dart (1件)
    'poSessions_comingSoon': {
        'ja': '近日公開予定',
        'en': 'Coming Soon',
        'zh': '即将推出',
        'ko': '곧 출시',
        'es': 'Próximamente',
        'de': 'Demnächst',
        'zh_TW': '即將推出',
    },
    
    # 11. redeem_invite_code_screen.dart (1件)
    'redeemInvite_useInviteCode': {
        'ja': '招待コードを使用',
        'en': 'Use Invite Code',
        'zh': '使用邀请码',
        'ko': '초대 코드 사용',
        'es': 'Usar Código de Invitación',
        'de': 'Einladungscode verwenden',
        'zh_TW': '使用邀請碼',
    },
    
    # 12. settings/notification_settings_screen.dart (1件)
    'notificationSettings_reminderSet': {
        'ja': 'リマインダー時刻を{time}に設定しました',
        'en': 'Reminder time set to {time}',
        'zh': '提醒时间已设置为{time}',
        'ko': '리마인더 시간을 {time}으로 설정했습니다',
        'es': 'Hora de recordatorio establecida a {time}',
        'de': 'Erinnerungszeit auf {time} eingestellt',
        'zh_TW': '提醒時間已設定為{time}',
    },
    
    # 13. settings/tokutei_shoutorihikihou_screen.dart (1件)
    'settings_commercialTransactionAct': {
        'ja': '特定商取引法に基づく表記',
        'en': 'Commercial Transaction Act',
        'zh': '基于特定商务交易法的表记',
        'ko': '특정 상거래법에 기반한 표기',
        'es': 'Ley de Transacciones Comerciales',
        'de': 'Handelsgeschäftsgesetz',
        'zh_TW': '基於特定商務交易法的表記',
    },
    
    # 14. settings/trial_progress_screen.dart (1件)
    'settings_trialProgress': {
        'ja': 'トライアル進捗',
        'en': 'Trial Progress',
        'zh': '试用进度',
        'ko': '체험 진행 상황',
        'es': 'Progreso de Prueba',
        'de': 'Testfortschritt',
        'zh_TW': '試用進度',
    },
    
    # 15. workout/add_workout_screen_complete.dart (1件)
    'workout_lightbulbIcon': {
        'ja': '💡',
        'en': '💡',
        'zh': '💡',
        'ko': '💡',
        'es': '💡',
        'de': '💡',
        'zh_TW': '💡',
    },
    
    # 16. workout/create_template_screen.dart (1件)
    'workoutTemplate_saveError': {
        'ja': '保存エラー: {error}',
        'en': 'Save Error: {error}',
        'zh': '保存错误：{error}',
        'ko': '저장 오류: {error}',
        'es': 'Error de Guardado: {error}',
        'de': 'Speicherfehler: {error}',
        'zh_TW': '儲存錯誤：{error}',
    },
    
    # 17. workout/rm_calculator_screen.dart (1件)
    'rmCalculator_barWeightError': {
        'ja': 'バーの重量（{barWeight}kg）より大きい値を入力してください',
        'en': 'Please enter a value greater than bar weight ({barWeight}kg)',
        'zh': '请输入大于杠铃重量（{barWeight}kg）的值',
        'ko': '바 무게({barWeight}kg)보다 큰 값을 입력하세요',
        'es': 'Ingrese un valor mayor que el peso de la barra ({barWeight}kg)',
        'de': 'Bitte einen Wert größer als Stangen-Gewicht ({barWeight}kg) eingeben',
        'zh_TW': '請輸入大於槓鈴重量（{barWeight}kg）的值',
    },
    
    # 18. workout/statistics_dashboard_screen.dart (2件)
    'statisticsDashboard_title': {
        'ja': '統計ダッシュボード',
        'en': 'Statistics Dashboard',
        'zh': '统计仪表板',
        'ko': '통계 대시보드',
        'es': 'Panel de Estadísticas',
        'de': 'Statistik-Dashboard',
        'zh_TW': '統計儀表板',
    },
    
    # 19. workout/template_screen.dart (2件)
    'workoutTemplate_title': {
        'ja': 'ワークアウトテンプレート',
        'en': 'Workout Templates',
        'zh': '训练模板',
        'ko': '운동 템플릿',
        'es': 'Plantillas de Entrenamiento',
        'de': 'Trainingsvorlagen',
        'zh_TW': '訓練範本',
    },
    'workoutTemplate_deleteConfirm': {
        'ja': '「{name}」を削除しますか？',
        'en': 'Delete "{name}"?',
        'zh': '是否删除"{name}"？',
        'ko': '"{name}"을(를) 삭제하시겠습니까?',
        'es': '¿Eliminar "{name}"?',
        'de': '"{name}" löschen?',
        'zh_TW': '是否刪除「{name}」？',
    },
    
    # 20. workout/weekly_reports_screen.dart (1件)
    'weeklyReports_workoutsSummary': {
        'ja': '{workouts}回 • {minutes}分',
        'en': '{workouts} workouts • {minutes} min',
        'zh': '{workouts}次 • {minutes}分钟',
        'ko': '{workouts}회 • {minutes}분',
        'es': '{workouts} entrenamientos • {minutes} min',
        'de': '{workouts} Trainings • {minutes} Min.',
        'zh_TW': '{workouts}次 • {minutes}分鐘',
    },
    
    # 21. workout/workout_memo_list_screen.dart (2件)
    'workoutMemo_updated': {
        'ja': 'メモを更新しました',
        'en': 'Memo updated',
        'zh': '备忘录已更新',
        'ko': '메모가 업데이트되었습니다',
        'es': 'Nota actualizada',
        'de': 'Notiz aktualisiert',
        'zh_TW': '備忘錄已更新',
    },
    'workoutMemo_delete': {
        'ja': 'メモを削除',
        'en': 'Delete Memo',
        'zh': '删除备忘录',
        'ko': '메모 삭제',
        'es': 'Eliminar Nota',
        'de': 'Notiz löschen',
        'zh_TW': '刪除備忘錄',
    },
    
    # 22. workout_import_preview_screen.dart (1件)
    'workoutImport_title': {
        'ja': '📸 トレーニング記録の取り込み',
        'en': '📸 Import Training Record',
        'zh': '📸 导入训练记录',
        'ko': '📸 트레이닝 기록 가져오기',
        'es': '📸 Importar Registro de Entrenamiento',
        'de': '📸 Trainingsaufzeichnung importieren',
        'zh_TW': '📸 匯入訓練記錄',
    },
}

def add_arb_keys():
    """ARBファイルにキーを追加"""
    for lang_code, arb_path in ARB_FILES.items():
        print(f"Processing {arb_path}...")
        
        # ARBファイルを読み込み
        with open(arb_path, 'r', encoding='utf-8') as f:
            arb_data = json.load(f)
        
        # 新しいキーを追加
        for key, translations in ARB_KEYS.items():
            if key not in arb_data:
                arb_data[key] = translations[lang_code]
                print(f"  Added: {key}")
        
        # ARBファイルに書き戻し
        with open(arb_path, 'w', encoding='utf-8') as f:
            json.dump(arb_data, f, ensure_ascii=False, indent=2)
    
    print(f"\n✅ Phase 2 ARBキー追加完了: {len(ARB_KEYS)}キー × 7言語 = {len(ARB_KEYS) * 7}エントリ")

if __name__ == '__main__':
    add_arb_keys()
