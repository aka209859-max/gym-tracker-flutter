#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Week 3 Day 8 Phase 2: ARBキー追加スクリプト
対象: subscription_screen.dart (10件)
"""

import json
import os

def add_arb_keys():
    """7言語のARBファイルにキーを追加"""
    
    # ARBキー定義（10件）
    keys = {
        "subscription_restore": {
            "ja": "Restore",
            "en": "Restore",
            "zh": "恢复",
            "ko": "복원",
            "es": "Restaurar",
            "de": "Wiederherstellen",
            "zh_TW": "恢復"
        },
        "subscription_lifetimeProPlan": {
            "ja": "永年Proプラン（∞）",
            "en": "Lifetime Pro Plan (∞)",
            "zh": "终身Pro计划（∞）",
            "ko": "평생 Pro 플랜（∞）",
            "es": "Plan Pro de por vida (∞)",
            "de": "Lebenslanger Pro-Plan (∞)",
            "zh_TW": "終身Pro計劃（∞）"
        },
        "subscription_lifetimePlanDescription": {
            "ja": "AI機能無制限 | 広告なし | すべての機能を永久利用",
            "en": "Unlimited AI features | Ad-free | All features forever",
            "zh": "无限AI功能 | 无广告 | 永久使用所有功能",
            "ko": "무제한 AI 기능 | 광고 없음 | 모든 기능 영구 이용",
            "es": "Funciones de IA ilimitadas | Sin anuncios | Todas las funciones para siempre",
            "de": "Unbegrenzte KI-Funktionen | Werbefrei | Alle Funktionen für immer",
            "zh_TW": "無限AI功能 | 無廣告 | 永久使用所有功能"
        },
        "subscription_popularBadge": {
            "ja": "⭐ 人気No.1",
            "en": "⭐ Most Popular",
            "zh": "⭐ 最受欢迎",
            "ko": "⭐ 인기 1위",
            "es": "⭐ Más popular",
            "de": "⭐ Am beliebtesten",
            "zh_TW": "⭐ 最受歡迎"
        },
        "subscription_legalInformation": {
            "ja": "Legal Information",
            "en": "Legal Information",
            "zh": "法律信息",
            "ko": "법적 정보",
            "es": "Información legal",
            "de": "Rechtliche Informationen",
            "zh_TW": "法律資訊"
        },
        "subscription_termsOfUse": {
            "ja": "Terms of Use",
            "en": "Terms of Use",
            "zh": "使用条款",
            "ko": "이용 약관",
            "es": "Términos de uso",
            "de": "Nutzungsbedingungen",
            "zh_TW": "使用條款"
        },
        "subscription_privacyPolicy": {
            "ja": "Privacy Policy",
            "en": "Privacy Policy",
            "zh": "隐私政策",
            "ko": "개인정보 보호정책",
            "es": "Política de privacidad",
            "de": "Datenschutzrichtlinie",
            "zh_TW": "隱私政策"
        },
        "subscription_agreementText": {
            "ja": "By subscribing, you agree to our Terms of Use and Privacy Policy",
            "en": "By subscribing, you agree to our Terms of Use and Privacy Policy",
            "zh": "订阅即表示您同意我们的使用条款和隐私政策",
            "ko": "구독하면 이용 약관 및 개인정보 보호정책에 동의하는 것입니다",
            "es": "Al suscribirte, aceptas nuestros Términos de uso y Política de privacidad",
            "de": "Durch das Abonnieren stimmen Sie unseren Nutzungsbedingungen und Datenschutzrichtlinien zu",
            "zh_TW": "訂閱即表示您同意我們的使用條款和隱私政策"
        },
        "subscription_aiAddonPrice": {
            "ja": "¥300 / 5回",
            "en": "¥300 / 5 times",
            "zh": "¥300 / 5次",
            "ko": "¥300 / 5회",
            "es": "¥300 / 5 veces",
            "de": "¥300 / 5 Mal",
            "zh_TW": "¥300 / 5次"
        },
        "subscription_cancelInstruction3": {
            "ja": "3. 「サブスクリプション」をタップ",
            "en": "3. Tap \\\"Subscriptions\\\"",
            "zh": "3. 点击\\\"订阅\\\"",
            "ko": "3. \\\"구독\\\"을 탭하세요",
            "es": "3. Toca \\\"Suscripciones\\\"",
            "de": "3. Tippe auf \\\"Abonnements\\\"",
            "zh_TW": "3. 點擊「訂閱」"
        }
    }
    
    # 言語ファイルマッピング
    lang_files = {
        "ja": "lib/l10n/app_ja.arb",
        "en": "lib/l10n/app_en.arb",
        "zh": "lib/l10n/app_zh.arb",
        "ko": "lib/l10n/app_ko.arb",
        "es": "lib/l10n/app_es.arb",
        "de": "lib/l10n/app_de.arb",
        "zh_TW": "lib/l10n/app_zh_TW.arb"
    }
    
    # 各言語ファイルにキーを追加
    for lang, filepath in lang_files.items():
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # キーを追加
        for key, translations in keys.items():
            if key not in data:
                data[key] = translations[lang]
        
        # ファイルに書き込み
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        print(f"✅ {filepath}: 10 keys added")
    
    print(f"\n🎉 Phase 2 ARBキー追加完了: 70エントリ (10キー × 7言語)")

if __name__ == "__main__":
    add_arb_keys()
