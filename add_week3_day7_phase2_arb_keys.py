#!/usr/bin/env python3
"""
Week 3 Day 7 Phase 2: 4ファイルのARBキー追加（16件）

対象文字列: 16件
- partner/chat_screen_partner.dart (5件)
- debug_log_screen.dart (3件)
- po/po_dashboard_screen.dart (4件)
- partner_photos_screen.dart (4件)
"""

import json
import os

# ARBファイルのパス
ARB_DIR = "lib/l10n"
LANGUAGES = {
    "ja": "app_ja.arb",
    "en": "app_en.arb",
    "zh": "app_zh.arb",
    "ko": "app_ko.arb",
    "es": "app_es.arb",
    "de": "app_de.arb",
    "zh_TW": "app_zh_TW.arb"
}

# 新しいARBキーと翻訳
NEW_KEYS = {
    # partner/chat_screen_partner.dart
    "chat_blockConfirm": {
        "ja": "{name}さんをブロックしますか？",
        "en": "Block {name}?",
        "zh": "屏蔽{name}？",
        "ko": "{name}님을 차단하시겠습니까?",
        "es": "¿Bloquear a {name}?",
        "de": "{name} blockieren?",
        "zh_TW": "封鎖{name}？"
    },
    "chat_blockButton": {
        "ja": "ブロック",
        "en": "Block",
        "zh": "屏蔽",
        "ko": "차단",
        "es": "Bloquear",
        "de": "Blockieren",
        "zh_TW": "封鎖"
    },
    "chat_blocked": {
        "ja": "ブロックしました",
        "en": "Blocked",
        "zh": "已屏蔽",
        "ko": "차단했습니다",
        "es": "Bloqueado",
        "de": "Blockiert",
        "zh_TW": "已封鎖"
    },
    "chat_reported": {
        "ja": "通報を受け付けました。ご協力ありがとうございます。",
        "en": "Report received. Thank you for your cooperation.",
        "zh": "已接受举报。感谢您的合作。",
        "ko": "신고가 접수되었습니다. 협조해 주셔서 감사합니다.",
        "es": "Reporte recibido. Gracias por su cooperación.",
        "de": "Meldung erhalten. Vielen Dank für Ihre Mitarbeit.",
        "zh_TW": "已接受檢舉。感謝您的合作。"
    },
    "chat_blockAction": {
        "ja": "ブロックする",
        "en": "Block",
        "zh": "屏蔽",
        "ko": "차단하기",
        "es": "Bloquear",
        "de": "Blockieren",
        "zh_TW": "封鎖"
    },
    # debug_log_screen.dart
    "debug_title": {
        "ja": "デバッグログ",
        "en": "Debug Log",
        "zh": "调试日志",
        "ko": "디버그 로그",
        "es": "Registro de Depuración",
        "de": "Debug-Protokoll",
        "zh_TW": "偵錯日誌"
    },
    "debug_logCopied": {
        "ja": "ログをクリップボードにコピーしました",
        "en": "Log copied to clipboard",
        "zh": "日志已复制到剪贴板",
        "ko": "로그를 클립보드에 복사했습니다",
        "es": "Registro copiado al portapapeles",
        "de": "Protokoll in Zwischenablage kopiert",
        "zh_TW": "日誌已複製到剪貼簿"
    },
    "debug_logCleared": {
        "ja": "ログをクリアしました",
        "en": "Log cleared",
        "zh": "日志已清除",
        "ko": "로그를 지웠습니다",
        "es": "Registro borrado",
        "de": "Protokoll gelöscht",
        "zh_TW": "日誌已清除"
    },
    # po/po_dashboard_screen.dart
    "po_dashboardTitle": {
        "ja": "PO管理ダッシュボード",
        "en": "PO Management Dashboard",
        "zh": "PO管理仪表板",
        "ko": "PO 관리 대시보드",
        "es": "Panel de Gestión PO",
        "de": "PO-Verwaltungs-Dashboard",
        "zh_TW": "PO管理儀表板"
    },
    "po_memberManagementComingSoon": {
        "ja": "会員管理画面は次のフェーズで実装予定",
        "en": "Member management screen coming in next phase",
        "zh": "会员管理界面将在下一阶段实现",
        "ko": "회원 관리 화면은 다음 단계에서 구현 예정",
        "es": "Pantalla de gestión de miembros próximamente",
        "de": "Mitgliederverwaltungsbildschirm in nächster Phase",
        "zh_TW": "會員管理畫面將在下一階段實現"
    },
    "po_sessionManagementComingSoon": {
        "ja": "セッション管理画面は次のフェーズで実装予定",
        "en": "Session management screen coming in next phase",
        "zh": "会话管理界面将在下一阶段实现",
        "ko": "세션 관리 화면은 다음 단계에서 구현 예정",
        "es": "Pantalla de gestión de sesiones próximamente",
        "de": "Sitzungsverwaltungsbildschirm in nächster Phase",
        "zh_TW": "會話管理畫面將在下一階段實現"
    },
    "po_analyticsComingSoon": {
        "ja": "分析画面は次のフェーズで実装予定",
        "en": "Analytics screen coming in next phase",
        "zh": "分析界面将在下一阶段实现",
        "ko": "분석 화면은 다음 단계에서 구현 예정",
        "es": "Pantalla de análisis próximamente",
        "de": "Analysebildschirm in nächster Phase",
        "zh_TW": "分析畫面將在下一階段實現"
    },
    # partner_photos_screen.dart
    "partnerPhotos_uploadSuccess": {
        "ja": "✅ {count}枚の画像をアップロードしました！",
        "en": "✅ Uploaded {count} images!",
        "zh": "✅ 已上传{count}张图片！",
        "ko": "✅ {count}개 이미지를 업로드했습니다!",
        "es": "✅ ¡Se subieron {count} imágenes!",
        "de": "✅ {count} Bilder hochgeladen!",
        "zh_TW": "✅ 已上傳{count}張圖片！"
    },
    "partnerPhotos_uploadFailed": {
        "ja": "❌ アップロード失敗: {error}",
        "en": "❌ Upload failed: {error}",
        "zh": "❌ 上传失败：{error}",
        "ko": "❌ 업로드 실패: {error}",
        "es": "❌ Error al subir: {error}",
        "de": "❌ Upload fehlgeschlagen: {error}",
        "zh_TW": "❌ 上傳失敗：{error}"
    },
    "partnerPhotos_deleteConfirm": {
        "ja": "画像を削除",
        "en": "Delete Image",
        "zh": "删除图片",
        "ko": "이미지 삭제",
        "es": "Eliminar Imagen",
        "de": "Bild löschen",
        "zh_TW": "刪除圖片"
    },
    "partnerPhotos_title": {
        "ja": "店舗画像管理",
        "en": "Store Image Management",
        "zh": "店铺图片管理",
        "ko": "매장 이미지 관리",
        "es": "Gestión de Imágenes de Tienda",
        "de": "Geschäftsbildverwaltung",
        "zh_TW": "店鋪圖片管理"
    }
}

# メタデータ
METADATA = {
    "chat_blockConfirm": {
        "description": "Confirmation dialog to block a user",
        "placeholders": {
            "name": {"type": "String", "example": "田中太郎"}
        }
    },
    "chat_blockButton": {
        "description": "Block button label"
    },
    "chat_blocked": {
        "description": "Success message after blocking"
    },
    "chat_reported": {
        "description": "Success message after reporting"
    },
    "chat_blockAction": {
        "description": "Block action label"
    },
    "debug_title": {
        "description": "Debug log screen title"
    },
    "debug_logCopied": {
        "description": "Success message when log is copied"
    },
    "debug_logCleared": {
        "description": "Success message when log is cleared"
    },
    "po_dashboardTitle": {
        "description": "PO management dashboard title"
    },
    "po_memberManagementComingSoon": {
        "description": "Coming soon message for member management"
    },
    "po_sessionManagementComingSoon": {
        "description": "Coming soon message for session management"
    },
    "po_analyticsComingSoon": {
        "description": "Coming soon message for analytics"
    },
    "partnerPhotos_uploadSuccess": {
        "description": "Success message after uploading photos",
        "placeholders": {
            "count": {"type": "int", "example": "5"}
        }
    },
    "partnerPhotos_uploadFailed": {
        "description": "Error message when upload fails",
        "placeholders": {
            "error": {"type": "String", "example": "Network error"}
        }
    },
    "partnerPhotos_deleteConfirm": {
        "description": "Delete image confirmation title"
    },
    "partnerPhotos_title": {
        "description": "Store photo management screen title"
    }
}

def add_arb_keys():
    """ARBファイルに新しいキーを追加"""
    
    for lang_code, arb_file in LANGUAGES.items():
        arb_path = os.path.join(ARB_DIR, arb_file)
        
        # 既存のARBファイルを読み込み
        with open(arb_path, 'r', encoding='utf-8') as f:
            arb_data = json.load(f)
        
        # 新しいキーを追加
        for key, translations in NEW_KEYS.items():
            if key not in arb_data:
                arb_data[key] = translations[lang_code]
                
                # メタデータを追加（日本語のみ）
                if lang_code == "ja" and key in METADATA:
                    arb_data[f"@{key}"] = METADATA[key]
        
        # ARBファイルに書き込み
        with open(arb_path, 'w', encoding='utf-8') as f:
            json.dump(arb_data, f, ensure_ascii=False, indent=2)
        
        print(f"✅ {arb_file}: {len(NEW_KEYS)}キー追加")
    
    total_entries = len(NEW_KEYS) * len(LANGUAGES)
    print(f"\n🎉 合計 {total_entries}エントリ追加完了！")
    print(f"   ({len(NEW_KEYS)}キー × {len(LANGUAGES)}言語)")

if __name__ == "__main__":
    add_arb_keys()
