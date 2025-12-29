#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Week 4 Day 9 Phase 1: ARBキー追加スクリプト
残り72件のうち42件を処理
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

# 42個のARBキーと翻訳
ARB_KEYS = {
    # 1. partner_campaign_editor_screen.dart (4件)
    'partnerCampaign_imageLoadError': {
        'ja': '画像の読み込みに失敗しました: {error}',
        'en': 'Failed to load image: {error}',
        'zh': '图片加载失败：{error}',
        'ko': '이미지 로드 실패: {error}',
        'es': 'Error al cargar imagen: {error}',
        'de': 'Bild konnte nicht geladen werden: {error}',
        'zh_TW': '圖片載入失敗：{error}',
    },
    'partnerCampaign_saved': {
        'ja': '✅ キャンペーンを保存しました！ユーザーアプリに即反映されます',
        'en': '✅ Campaign saved! Changes reflected immediately in user app',
        'zh': '✅ 活动已保存！立即反映到用户应用',
        'ko': '✅ 캠페인이 저장되었습니다! 사용자 앱에 즉시 반영됩니다',
        'es': '✅ ¡Campaña guardada! Cambios reflejados inmediatamente',
        'de': '✅ Kampagne gespeichert! Änderungen sofort sichtbar',
        'zh_TW': '✅ 活動已儲存！立即反映到使用者應用程式',
    },
    'partnerCampaign_saveError': {
        'ja': '❌ 保存に失敗しました: {error}',
        'en': '❌ Failed to save: {error}',
        'zh': '❌ 保存失败：{error}',
        'ko': '❌ 저장 실패: {error}',
        'es': '❌ Error al guardar: {error}',
        'de': '❌ Speichern fehlgeschlagen: {error}',
        'zh_TW': '❌ 儲存失敗：{error}',
    },
    'partnerCampaign_editorTitle': {
        'ja': '🏆 キャンペーン編集',
        'en': '🏆 Campaign Editor',
        'zh': '🏆 活动编辑',
        'ko': '🏆 캠페인 편집',
        'es': '🏆 Editor de Campaña',
        'de': '🏆 Kampagnen-Editor',
        'zh_TW': '🏆 活動編輯',
    },
    
    # 2. po/po_analytics_screen.dart (4件)
    'poAnalytics_dormantMembers': {
        'ja': '休眠会員: {count}名',
        'en': 'Dormant Members: {count}',
        'zh': '休眠会员：{count}人',
        'ko': '휴면 회원: {count}명',
        'es': 'Miembros inactivos: {count}',
        'de': 'Inaktive Mitglieder: {count}',
        'zh_TW': '休眠會員：{count}人',
    },
    'poAnalytics_dormantDescription': {
        'ja': '最終セッションから2週間以上経過',
        'en': 'More than 2 weeks since last session',
        'zh': '距上次训练已超过2周',
        'ko': '마지막 세션 이후 2주 이상 경과',
        'es': 'Más de 2 semanas desde la última sesión',
        'de': 'Mehr als 2 Wochen seit letzter Sitzung',
        'zh_TW': '距上次訓練已超過2週',
    },
    'poAnalytics_broadcastComingSoon': {
        'ja': '一斉メッセージ機能は近日公開予定です',
        'en': 'Broadcast message feature coming soon',
        'zh': '群发消息功能即将推出',
        'ko': '일괄 메시지 기능 곧 출시',
        'es': 'Función de mensaje masivo próximamente',
        'de': 'Broadcast-Nachrichtenfunktion demnächst',
        'zh_TW': '群發訊息功能即將推出',
    },
    'poAnalytics_respond': {
        'ja': '対応する',
        'en': 'Respond',
        'zh': '回应',
        'ko': '응답',
        'es': 'Responder',
        'de': 'Antworten',
        'zh_TW': '回應',
    },
    
    # 3. partner_dashboard_screen.dart (3件)
    'partnerDashboard_title': {
        'ja': 'パートナー管理画面',
        'en': 'Partner Management',
        'zh': '合作伙伴管理',
        'ko': '파트너 관리',
        'es': 'Gestión de Socios',
        'de': 'Partner-Verwaltung',
        'zh_TW': '合作夥伴管理',
    },
    'partnerDashboard_comingSoon': {
        'ja': '🚧 実装予定の機能です',
        'en': '🚧 Feature coming soon',
        'zh': '🚧 功能即将推出',
        'ko': '🚧 기능 준비 중',
        'es': '🚧 Función próximamente',
        'de': '🚧 Funktion demnächst',
        'zh_TW': '🚧 功能即將推出',
    },
    
    # 4. partner/partner_profile_detail_screen.dart (3件)
    'partnerProfile_bullet': {
        'ja': '•',
        'en': '•',
        'zh': '•',
        'ko': '•',
        'es': '•',
        'de': '•',
        'zh_TW': '•',
    },
    'partnerProfile_proOnlyFeature': {
        'ja': 'Pro限定機能',
        'en': 'Pro-only Feature',
        'zh': 'Pro专属功能',
        'ko': 'Pro 전용 기능',
        'es': 'Función exclusiva Pro',
        'de': 'Nur Pro-Funktion',
        'zh_TW': 'Pro專屬功能',
    },
    'partnerProfile_proBenefits': {
        'ja': '✨ Proプランの特典',
        'en': '✨ Pro Plan Benefits',
        'zh': '✨ Pro计划福利',
        'ko': '✨ Pro 플랜 혜택',
        'es': '✨ Beneficios del Plan Pro',
        'de': '✨ Pro-Plan-Vorteile',
        'zh_TW': '✨ Pro方案福利',
    },
    
    # 5. personal_training_screen.dart (3件)
    'personalTraining_reservationComingSoon': {
        'ja': '予約状況機能は開発中です',
        'en': 'Reservation status feature under development',
        'zh': '预约状态功能开发中',
        'ko': '예약 상태 기능 개발 중',
        'es': 'Función de estado de reserva en desarrollo',
        'de': 'Reservierungsstatus-Funktion in Entwicklung',
        'zh_TW': '預約狀態功能開發中',
    },
    'personalTraining_newReservationComingSoon': {
        'ja': '新規予約機能は開発中です',
        'en': 'New reservation feature under development',
        'zh': '新预约功能开发中',
        'ko': '신규 예약 기능 개발 중',
        'es': 'Nueva función de reserva en desarrollo',
        'de': 'Neue Reservierungsfunktion in Entwicklung',
        'zh_TW': '新預約功能開發中',
    },
    'personalTraining_trainerRecordComingSoon': {
        'ja': 'トレーナー記録機能は開発中です',
        'en': 'Trainer record feature under development',
        'zh': '教练记录功能开发中',
        'ko': '트레이너 기록 기능 개발 중',
        'es': 'Función de registro de entrenador en desarrollo',
        'de': 'Trainer-Aufzeichnungsfunktion in Entwicklung',
        'zh_TW': '教練記錄功能開發中',
    },
    
    # 6. body_measurement_screen.dart (2件)
    'bodyMeasurement_dateFormat': {
        'ja': 'yyyy年MM月dd日',
        'en': 'yyyy/MM/dd',
        'zh': 'yyyy年MM月dd日',
        'ko': 'yyyy년 MM월 dd일',
        'es': 'dd/MM/yyyy',
        'de': 'dd.MM.yyyy',
        'zh_TW': 'yyyy年MM月dd日',
    },
    'bodyMeasurement_bulletSeparator': {
        'ja': '  •  ',
        'en': '  •  ',
        'zh': '  •  ',
        'ko': '  •  ',
        'es': '  •  ',
        'de': '  •  ',
        'zh_TW': '  •  ',
    },
    
    # 7. calculators_screen.dart (2件)
    'calculators_repsCount': {
        'ja': '{count}回',
        'en': '{count} reps',
        'zh': '{count}次',
        'ko': '{count}회',
        'es': '{count} repeticiones',
        'de': '{count} Wiederholungen',
        'zh_TW': '{count}次',
    },
    'calculators_plateWeight': {
        'ja': '{weight} kg プレート',
        'en': '{weight} kg plate',
        'zh': '{weight} kg 杠铃片',
        'ko': '{weight} kg 플레이트',
        'es': 'Plato de {weight} kg',
        'de': '{weight} kg Gewichtsscheibe',
        'zh_TW': '{weight} kg 槓鈴片',
    },
    
    # 8. chat_screen.dart (2件)
    'chat_sendMessageError': {
        'ja': 'メッセージ送信に失敗しました',
        'en': 'Failed to send message',
        'zh': '消息发送失败',
        'ko': '메시지 전송 실패',
        'es': 'Error al enviar mensaje',
        'de': 'Nachricht senden fehlgeschlagen',
        'zh_TW': '訊息傳送失敗',
    },
    'chat_loadMessageError': {
        'ja': 'メッセージの読み込みに失敗しました',
        'en': 'Failed to load messages',
        'zh': '消息加载失败',
        'ko': '메시지 로드 실패',
        'es': 'Error al cargar mensajes',
        'de': 'Nachrichten laden fehlgeschlagen',
        'zh_TW': '訊息載入失敗',
    },
    
    # 9. map_screen.dart (2件)
    'map_locationPermission': {
        'ja': '位置情報を使用しますか？',
        'en': 'Use location services?',
        'zh': '使用位置信息吗？',
        'ko': '위치 정보를 사용하시겠습니까?',
        'es': '¿Usar servicios de ubicación?',
        'de': 'Standortdienste verwenden?',
        'zh_TW': '使用位置資訊嗎？',
    },
    'map_gymsFound': {
        'ja': '{count}件のジムが見つかりました',
        'en': '{count} gyms found',
        'zh': '找到{count}个健身房',
        'ko': '{count}개의 체육관을 찾았습니다',
        'es': '{count} gimnasios encontrados',
        'de': '{count} Fitnessstudios gefunden',
        'zh_TW': '找到{count}個健身房',
    },
    
    # 10. partner/partner_profile_edit_screen.dart (2件)
    'partnerProfileEdit_intermediateLevel': {
        'ja': '中級者',
        'en': 'Intermediate',
        'zh': '中级',
        'ko': '중급자',
        'es': 'Intermedio',
        'de': 'Fortgeschritten',
        'zh_TW': '中級',
    },
    'partnerProfileEdit_favoriteExercises': {
        'ja': '好きな種目',
        'en': 'Favorite Exercises',
        'zh': '喜欢的项目',
        'ko': '좋아하는 종목',
        'es': 'Ejercicios Favoritos',
        'de': 'Lieblingsübungen',
        'zh_TW': '喜歡的項目',
    },
    
    # 11. partner_equipment_editor_screen.dart (2件)
    'partnerEquipment_updated': {
        'ja': '✅ 設備情報を更新しました！',
        'en': '✅ Equipment information updated!',
        'zh': '✅ 设备信息已更新！',
        'ko': '✅ 장비 정보가 업데이트되었습니다!',
        'es': '✅ ¡Información de equipo actualizada!',
        'de': '✅ Geräteinformationen aktualisiert!',
        'zh_TW': '✅ 設備資訊已更新！',
    },
    'partnerEquipment_saveError': {
        'ja': '❌ 保存に失敗しました: {error}',
        'en': '❌ Failed to save: {error}',
        'zh': '❌ 保存失败：{error}',
        'ko': '❌ 저장 실패: {error}',
        'es': '❌ Error al guardar: {error}',
        'de': '❌ Speichern fehlgeschlagen: {error}',
        'zh_TW': '❌ 儲存失敗：{error}',
    },
    
    # 12. partner_reservation_settings_screen.dart (2件)
    'partnerReservation_updated': {
        'ja': '✅ 予約設定を更新しました！',
        'en': '✅ Reservation settings updated!',
        'zh': '✅ 预约设置已更新！',
        'ko': '✅ 예약 설정이 업데이트되었습니다!',
        'es': '✅ ¡Configuración de reserva actualizada!',
        'de': '✅ Reservierungseinstellungen aktualisiert!',
        'zh_TW': '✅ 預約設定已更新！',
    },
    'partnerReservation_saveError': {
        'ja': '❌ 保存に失敗しました: {error}',
        'en': '❌ Failed to save: {error}',
        'zh': '❌ 保存失败：{error}',
        'ko': '❌ 저장 실패: {error}',
        'es': '❌ Error al guardar: {error}',
        'de': '❌ Speichern fehlgeschlagen: {error}',
        'zh_TW': '❌ 儲存失敗：{error}',
    },
    
    # 13. personal_training/trainer_records_screen.dart (2件)
    'trainerRecords_saved': {
        'ja': '✅ トレーニング記録を保存しました',
        'en': '✅ Training record saved',
        'zh': '✅ 训练记录已保存',
        'ko': '✅ 트레이닝 기록 저장됨',
        'es': '✅ Registro de entrenamiento guardado',
        'de': '✅ Trainingsaufzeichnung gespeichert',
        'zh_TW': '✅ 訓練記錄已儲存',
    },
    'trainerRecords_reload': {
        'ja': '再読み込み',
        'en': 'Reload',
        'zh': '重新加载',
        'ko': '새로고침',
        'es': 'Recargar',
        'de': 'Neu laden',
        'zh_TW': '重新載入',
    },
    
    # 14. po/po_members_screen.dart (2件)
    'poMembers_allMembers': {
        'ja': '全会員',
        'en': 'All Members',
        'zh': '全部会员',
        'ko': '전체 회원',
        'es': 'Todos los Miembros',
        'de': 'Alle Mitglieder',
        'zh_TW': '全部會員',
    },
    'poMembers_dormant': {
        'ja': '休眠中',
        'en': 'Dormant',
        'zh': '休眠中',
        'ko': '휴면',
        'es': 'Inactivo',
        'de': 'Inaktiv',
        'zh_TW': '休眠中',
    },
    
    # 15. profile_edit_screen.dart (2件)
    'profileEdit_imageLoadError': {
        'ja': '画像の読み込みに失敗しました\n{error}',
        'en': 'Failed to load image\n{error}',
        'zh': '图片加载失败\n{error}',
        'ko': '이미지 로드 실패\n{error}',
        'es': 'Error al cargar imagen\n{error}',
        'de': 'Bild konnte nicht geladen werden\n{error}',
        'zh_TW': '圖片載入失敗\n{error}',
    },
    'profileEdit_proOnlyFeature': {
        'ja': 'Proプラン限定機能',
        'en': 'Pro Plan Exclusive Feature',
        'zh': 'Pro计划专属功能',
        'ko': 'Pro 플랜 전용 기능',
        'es': 'Función Exclusiva del Plan Pro',
        'de': 'Exklusive Pro-Plan-Funktion',
        'zh_TW': 'Pro方案專屬功能',
    },
    
    # 16. profile_screen.dart (2件)
    'profile_termsAndSubscription': {
        'ja': 'サービス利用条件・サブスクリプション',
        'en': 'Terms of Service & Subscription',
        'zh': '服务条款·订阅',
        'ko': '서비스 이용약관·구독',
        'es': 'Términos de Servicio y Suscripción',
        'de': 'Nutzungsbedingungen & Abonnement',
        'zh_TW': '服務條款·訂閱',
    },
    'profile_privacyPolicy': {
        'ja': '個人情報の取扱い',
        'en': 'Privacy Policy',
        'zh': '个人信息处理',
        'ko': '개인정보 처리방침',
        'es': 'Política de Privacidad',
        'de': 'Datenschutzrichtlinie',
        'zh_TW': '個人資訊處理',
    },
    
    # 17. reservation_form_screen.dart (2件)
    'reservation_submitted': {
        'ja': '✅ 予約申込を送信しました！店舗から連絡があります。',
        'en': '✅ Reservation submitted! The gym will contact you.',
        'zh': '✅ 预约申请已发送！店铺将与您联系。',
        'ko': '✅ 예약 신청이 전송되었습니다! 매장에서 연락드립니다.',
        'es': '✅ ¡Reserva enviada! El gimnasio se pondrá en contacto.',
        'de': '✅ Reservierung gesendet! Das Fitnessstudio wird Sie kontaktieren.',
        'zh_TW': '✅ 預約申請已送出！店鋪將與您聯絡。',
    },
    'reservation_submitError': {
        'ja': '❌ 予約送信に失敗しました: {error}',
        'en': '❌ Failed to submit reservation: {error}',
        'zh': '❌ 预约发送失败：{error}',
        'ko': '❌ 예약 전송 실패: {error}',
        'es': '❌ Error al enviar reserva: {error}',
        'de': '❌ Reservierung senden fehlgeschlagen: {error}',
        'zh_TW': '❌ 預約傳送失敗：{error}',
    },
    
    # 18. subscription_screen.dart (2件)
    'subscription_step4': {
        'ja': '4. 「GYM MATCH」を選択',
        'en': '4. Select "GYM MATCH"',
        'zh': '4. 选择"GYM MATCH"',
        'ko': '4. "GYM MATCH" 선택',
        'es': '4. Seleccione "GYM MATCH"',
        'de': '4. Wählen Sie "GYM MATCH"',
        'zh_TW': '4. 選擇「GYM MATCH」',
    },
    'subscription_step5': {
        'ja': '5. 希望のプランを選択',
        'en': '5. Select desired plan',
        'zh': '5. 选择希望的计划',
        'ko': '5. 원하는 플랜 선택',
        'es': '5. Seleccione el plan deseado',
        'de': '5. Wählen Sie den gewünschten Plan',
        'zh_TW': '5. 選擇希望的方案',
    },
    
    # 19. visit_history_screen.dart (2件)
    'visitHistory_deleteHistory': {
        'ja': '訪問履歴を削除',
        'en': 'Delete Visit History',
        'zh': '删除访问历史',
        'ko': '방문 기록 삭제',
        'es': 'Eliminar Historial de Visitas',
        'de': 'Besuchsverlauf löschen',
        'zh_TW': '刪除造訪記錄',
    },
    'visitHistory_reload': {
        'ja': '再読み込み',
        'en': 'Reload',
        'zh': '重新加载',
        'ko': '새로고침',
        'es': 'Recargar',
        'de': 'Neu laden',
        'zh_TW': '重新載入',
    },
    
    # 20. workout/personal_records_screen.dart (2件)
    'personalRecords_exerciseCount': {
        'ja': '{count}種目',
        'en': '{count} exercises',
        'zh': '{count}个项目',
        'ko': '{count}개 종목',
        'es': '{count} ejercicios',
        'de': '{count} Übungen',
        'zh_TW': '{count}個項目',
    },
    'personalRecords_bodyPartTitle': {
        'ja': '{bodyPart} - PR記録',
        'en': '{bodyPart} - PR Records',
        'zh': '{bodyPart} - PR记录',
        'ko': '{bodyPart} - PR 기록',
        'es': '{bodyPart} - Registros PR',
        'de': '{bodyPart} - PR-Aufzeichnungen',
        'zh_TW': '{bodyPart} - PR記錄',
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
    
    print(f"\n✅ Phase 1 ARBキー追加完了: {len(ARB_KEYS)}キー × 7言語 = {len(ARB_KEYS) * 7}エントリ")

if __name__ == '__main__':
    add_arb_keys()
