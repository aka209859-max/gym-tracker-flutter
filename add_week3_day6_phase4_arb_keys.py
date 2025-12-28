#!/usr/bin/env python3
"""
Week 3 Day 6 Phase 4: 優先度高ファイルのARBキー追加

対象ファイル:
- redeem_invite_code_screen.dart (5件)
- gym_detail_screen.dart (1件)
- ai_addon_purchase_screen.dart (4件)

合計: 10件
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
    # redeem_invite_code_screen.dart
    "invite_registrationComplete": {
        "ja": "🎉 登録完了！",
        "en": "🎉 Registration Complete!",
        "zh": "🎉 注册完成！",
        "ko": "🎉 등록 완료!",
        "es": "🎉 ¡Registro Completo!",
        "de": "🎉 Registrierung Abgeschlossen!",
        "zh_TW": "🎉 註冊完成！"
    },
    "invite_codeApplied": {
        "ja": "招待コードが正常に適用されました！",
        "en": "Invitation code applied successfully!",
        "zh": "邀请码已成功应用！",
        "ko": "초대 코드가 성공적으로 적용되었습니다!",
        "es": "¡Código de invitación aplicado con éxito!",
        "de": "Einladungscode erfolgreich angewendet!",
        "zh_TW": "邀請碼已成功套用！"
    },
    "invite_yourReward": {
        "ja": "✅ あなた: AI使用回数 +5回",
        "en": "✅ You: +5 AI uses",
        "zh": "✅ 您：AI使用次数 +5次",
        "ko": "✅ 당신: AI 사용 횟수 +5회",
        "es": "✅ Tú: +5 usos de IA",
        "de": "✅ Sie: +5 KI-Nutzungen",
        "zh_TW": "✅ 您：AI使用次數 +5次"
    },
    "invite_friendReward": {
        "ja": "✅ 友達: AI使用回数 +3回",
        "en": "✅ Friend: +3 AI uses",
        "zh": "✅ 朋友：AI使用次数 +3次",
        "ko": "✅ 친구: AI 사용 횟수 +3회",
        "es": "✅ Amigo: +3 usos de IA",
        "de": "✅ Freund: +3 KI-Nutzungen",
        "zh_TW": "✅ 朋友：AI使用次數 +3次"
    },
    "invite_benefitsApplied": {
        "ja": "特典はすぐに反映されます！",
        "en": "Benefits will be applied immediately!",
        "zh": "奖励将立即生效！",
        "ko": "혜택이 즉시 적용됩니다!",
        "es": "¡Los beneficios se aplicarán de inmediato!",
        "de": "Vorteile werden sofort angewendet!",
        "zh_TW": "獎勵將立即生效！"
    },
    # gym_detail_screen.dart
    "gym_checkedIn": {
        "ja": "{gymName}にチェックインしました",
        "en": "Checked in to {gymName}",
        "zh": "已签到{gymName}",
        "ko": "{gymName}에 체크인했습니다",
        "es": "Registrado en {gymName}",
        "de": "Bei {gymName} eingecheckt",
        "zh_TW": "已簽到{gymName}"
    },
    # ai_addon_purchase_screen.dart
    "aiAddon_purchaseConfirm": {
        "ja": "AI追加パックを購入しますか？",
        "en": "Purchase AI Add-on Pack?",
        "zh": "购买AI附加包？",
        "ko": "AI 추가 팩을 구매하시겠습니까?",
        "es": "¿Comprar Paquete Adicional de IA?",
        "de": "KI-Zusatzpaket kaufen?",
        "zh_TW": "購買AI附加包？"
    },
    "aiAddon_packDetails": {
        "ja": "AI追加パック（5回分）\n料金: ¥300",
        "en": "AI Add-on Pack (5 uses)\nPrice: ¥300",
        "zh": "AI附加包（5次）\n价格：¥300",
        "ko": "AI 추가 팩 (5회)\n가격: ¥300",
        "es": "Paquete Adicional de IA (5 usos)\nPrecio: ¥300",
        "de": "KI-Zusatzpaket (5 Nutzungen)\nPreis: ¥300",
        "zh_TW": "AI附加包（5次）\n價格：¥300"
    },
    "aiAddon_purchase": {
        "ja": "購入する",
        "en": "Purchase",
        "zh": "购买",
        "ko": "구매",
        "es": "Comprar",
        "de": "Kaufen",
        "zh_TW": "購買"
    },
    "aiAddon_purchaseFailed": {
        "ja": "購入処理に失敗しました。\nもう一度お試しください。",
        "en": "Purchase failed.\nPlease try again.",
        "zh": "购买失败。\n请重试。",
        "ko": "구매 실패.\n다시 시도해 주세요.",
        "es": "Compra fallida.\nPor favor, inténtelo de nuevo.",
        "de": "Kauf fehlgeschlagen.\nBitte versuchen Sie es erneut.",
        "zh_TW": "購買失敗。\n請重試。"
    }
}

# メタデータ
METADATA = {
    "invite_registrationComplete": {
        "description": "Success message title when invitation code is registered"
    },
    "invite_codeApplied": {
        "description": "Success message when invitation code is applied"
    },
    "invite_yourReward": {
        "description": "Your reward for using invitation code"
    },
    "invite_friendReward": {
        "description": "Friend's reward for invitation code"
    },
    "invite_benefitsApplied": {
        "description": "Message that benefits are applied immediately"
    },
    "gym_checkedIn": {
        "description": "Message shown when checked in to a gym",
        "placeholders": {
            "gymName": {
                "type": "String",
                "example": "Gold's Gym"
            }
        }
    },
    "aiAddon_purchaseConfirm": {
        "description": "Confirmation dialog title for AI addon purchase"
    },
    "aiAddon_packDetails": {
        "description": "AI addon pack details with price"
    },
    "aiAddon_purchase": {
        "description": "Purchase button label"
    },
    "aiAddon_purchaseFailed": {
        "description": "Error message when purchase fails"
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
