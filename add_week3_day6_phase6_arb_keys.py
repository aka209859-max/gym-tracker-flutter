#!/usr/bin/env python3
"""
Week 3 Day 6 Phase 6: campaign & partner のARBキー追加

対象文字列: 7件
- campaign_sns_share_screen.dart (3件)
- partner_detail_screen.dart (4件)
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
    # campaign_sns_share_screen.dart
    "campaign_templateCopied": {
        "ja": "✅ テンプレートをコピーしました！",
        "en": "✅ Template copied!",
        "zh": "✅ 已复制模板！",
        "ko": "✅ 템플릿을 복사했습니다!",
        "es": "✅ ¡Plantilla copiada!",
        "de": "✅ Vorlage kopiert!",
        "zh_TW": "✅ 已複製範本！"
    },
    "campaign_snsShare": {
        "ja": "📱 SNSでシェア",
        "en": "📱 Share on SNS",
        "zh": "📱 分享到社交媒体",
        "ko": "📱 SNS에 공유",
        "es": "📱 Compartir en Redes Sociales",
        "de": "📱 Auf Social Media teilen",
        "zh_TW": "📱 分享到社群媒體"
    },
    "campaign_copyTemplate": {
        "ja": "テンプレートをコピー",
        "en": "Copy Template",
        "zh": "复制模板",
        "ko": "템플릿 복사",
        "es": "Copiar Plantilla",
        "de": "Vorlage kopieren",
        "zh_TW": "複製範本"
    },
    # partner_detail_screen.dart
    "partner_friendRequestSent": {
        "ja": "友達申請を送信しました",
        "en": "Friend request sent",
        "zh": "已发送好友申请",
        "ko": "친구 요청을 보냈습니다",
        "es": "Solicitud de amistad enviada",
        "de": "Freundschaftsanfrage gesendet",
        "zh_TW": "已發送好友申請"
    },
    "partner_friendRequiredForMessage": {
        "ja": "友達になってからメッセージを送信できます",
        "en": "You can send messages after becoming friends",
        "zh": "成为好友后才能发送消息",
        "ko": "친구가 된 후 메시지를 보낼 수 있습니다",
        "es": "Puedes enviar mensajes después de ser amigos",
        "de": "Sie können Nachrichten senden, nachdem Sie Freunde geworden sind",
        "zh_TW": "成為好友後才能傳送訊息"
    },
    "partner_detailTitle": {
        "ja": "パートナー詳細",
        "en": "Partner Details",
        "zh": "伙伴详情",
        "ko": "파트너 상세정보",
        "es": "Detalles del Compañero",
        "de": "Partnerdetails",
        "zh_TW": "夥伴詳情"
    },
    "partner_sendFriendRequest": {
        "ja": "友達申請",
        "en": "Send Friend Request",
        "zh": "发送好友申请",
        "ko": "친구 요청 보내기",
        "es": "Enviar Solicitud de Amistad",
        "de": "Freundschaftsanfrage senden",
        "zh_TW": "發送好友申請"
    }
}

# メタデータ
METADATA = {
    "campaign_templateCopied": {
        "description": "Success message when campaign template is copied"
    },
    "campaign_snsShare": {
        "description": "Title for SNS share screen"
    },
    "campaign_copyTemplate": {
        "description": "Button label to copy template"
    },
    "partner_friendRequestSent": {
        "description": "Success message when friend request is sent"
    },
    "partner_friendRequiredForMessage": {
        "description": "Message explaining that friendship is required to send messages"
    },
    "partner_detailTitle": {
        "description": "Title for partner detail screen"
    },
    "partner_sendFriendRequest": {
        "description": "Button label to send friend request"
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
