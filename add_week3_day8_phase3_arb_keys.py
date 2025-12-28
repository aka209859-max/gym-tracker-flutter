#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Week 3 Day 8 Phase 3: ARBキー追加スクリプト
対象: profile_screen.dart (10件)
"""

import json
import os

def add_arb_keys():
    """7言語のARBファイルにキーを追加"""
    
    # ARBキー定義（10件）
    keys = {
        "profile_referralBonusTitle": {
            "ja": "🎁 紹介特典",
            "en": "🎁 Referral Bonus",
            "zh": "🎁 推荐奖励",
            "ko": "🎁 추천 보너스",
            "es": "🎁 Bono de referencia",
            "de": "🎁 Empfehlungsbonus",
            "zh_TW": "🎁 推薦獎勵"
        },
        "profile_referralBonusHint": {
            "ja": "💡 友達がこのコードを入力すると、両方に特典が届きます！",
            "en": "💡 When your friend enters this code, both of you will receive rewards!",
            "zh": "💡 当您的朋友输入此代码时，双方都将获得奖励！",
            "ko": "💡 친구가 이 코드를 입력하면 둘 다 보상을 받습니다!",
            "es": "💡 Cuando tu amigo ingrese este código, ¡ambos recibirán recompensas!",
            "de": "💡 Wenn dein Freund diesen Code eingibt, erhalten beide Belohnungen!",
            "zh_TW": "💡 當您的朋友輸入此代碼時，雙方都將獲得獎勵！"
        },
        "profile_referralShareMessage": {
            "ja": "GYM MATCHで一緒にトレーニングしませんか？\\n\\n紹介コード: {referralCode}\\nAI使用回数3回がもらえます！\\n\\nhttps://gym-match-e560d.web.app",
            "en": "Let's train together on GYM MATCH!\\n\\nReferral code: {referralCode}\\nGet 3 AI uses!\\n\\nhttps://gym-match-e560d.web.app",
            "zh": "一起在GYM MATCH上训练吧！\\n\\n推荐码：{referralCode}\\n获得3次AI使用！\\n\\nhttps://gym-match-e560d.web.app",
            "ko": "GYM MATCH에서 함께 운동해요!\\n\\n추천 코드: {referralCode}\\nAI 사용 3회 받기!\\n\\nhttps://gym-match-e560d.web.app",
            "es": "¡Entrenemos juntos en GYM MATCH!\\n\\nCódigo de referencia: {referralCode}\\n¡Obtén 3 usos de IA!\\n\\nhttps://gym-match-e560d.web.app",
            "de": "Lass uns zusammen auf GYM MATCH trainieren!\\n\\nEmpfehlungscode: {referralCode}\\nErhalte 3 KI-Nutzungen!\\n\\nhttps://gym-match-e560d.web.app",
            "zh_TW": "一起在GYM MATCH上訓練吧！\\n\\n推薦碼：{referralCode}\\n獲得3次AI使用！\\n\\nhttps://gym-match-e560d.web.app",
            "placeholders": {
                "referralCode": {
                    "type": "String"
                }
            }
        },
        "profile_errorMessage": {
            "ja": "❌ エラー: {error}",
            "en": "❌ Error: {error}",
            "zh": "❌ 错误：{error}",
            "ko": "❌ 오류: {error}",
            "es": "❌ Error: {error}",
            "de": "❌ Fehler: {error}",
            "zh_TW": "❌ 錯誤：{error}",
            "placeholders": {
                "error": {
                    "type": "String"
                }
            }
        },
        "profile_rewardItem": {
            "ja": "{title}: {reward}",
            "en": "{title}: {reward}",
            "zh": "{title}：{reward}",
            "ko": "{title}: {reward}",
            "es": "{title}: {reward}",
            "de": "{title}: {reward}",
            "zh_TW": "{title}：{reward}",
            "placeholders": {
                "title": {
                    "type": "String"
                },
                "reward": {
                    "type": "String"
                }
            }
        },
        "profile_defaultUsername": {
            "ja": "トレーニングユーザー",
            "en": "Training User",
            "zh": "训练用户",
            "ko": "트레이닝 사용자",
            "es": "Usuario de entrenamiento",
            "de": "Trainingsbenutzer",
            "zh_TW": "訓練用戶"
        },
        "profile_defaultBio": {
            "ja": "GYM MATCHへようこそ",
            "en": "Welcome to GYM MATCH",
            "zh": "欢迎来到GYM MATCH",
            "ko": "GYM MATCH에 오신 것을 환영합니다",
            "es": "Bienvenido a GYM MATCH",
            "de": "Willkommen bei GYM MATCH",
            "zh_TW": "歡迎來到GYM MATCH"
        },
        "profile_referralRewardDescription": {
            "ja": "AI x5回 + 紹介された人もAI x3回",
            "en": "AI x5 times + Referred person also gets AI x3 times",
            "zh": "AI x5次 + 被推荐人也获得AI x3次",
            "ko": "AI x5회 + 추천받은 사람도 AI x3회",
            "es": "AI x5 veces + La persona referida también obtiene AI x3 veces",
            "de": "KI x5 Mal + Geworbene Person erhält auch KI x3 Mal",
            "zh_TW": "AI x5次 + 被推薦人也獲得AI x3次"
        },
        "profile_premiumOnlyFeature": {
            "ja": "{featureName}は有料プラン会員限定の機能です。",
            "en": "{featureName} is a feature exclusive to premium plan members.",
            "zh": "{featureName}是高级计划会员专属功能。",
            "ko": "{featureName}은(는) 프리미엄 플랜 회원 전용 기능입니다.",
            "es": "{featureName} es una función exclusiva para miembros del plan premium.",
            "de": "{featureName} ist eine Funktion exklusiv für Premium-Plan-Mitglieder.",
            "zh_TW": "{featureName}是高級計劃會員專屬功能。",
            "placeholders": {
                "featureName": {
                    "type": "String"
                }
            }
        },
        "profile_featureInDevelopment": {
            "ja": "{featureName}は現在開発中です。\\n次回のアップデートでご利用いただけます。",
            "en": "{featureName} is currently under development.\\nIt will be available in the next update.",
            "zh": "{featureName}目前正在开发中。\\n下次更新时即可使用。",
            "ko": "{featureName}은(는) 현재 개발 중입니다.\\n다음 업데이트에서 사용할 수 있습니다.",
            "es": "{featureName} está actualmente en desarrollo.\\nEstará disponible en la próxima actualización.",
            "de": "{featureName} befindet sich derzeit in der Entwicklung.\\nEs wird im nächsten Update verfügbar sein.",
            "zh_TW": "{featureName}目前正在開發中。\\n下次更新時即可使用。",
            "placeholders": {
                "featureName": {
                    "type": "String"
                }
            }
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
                
                # placeholdersがある場合は追加
                if "placeholders" in translations:
                    placeholder_key = f"@{key}"
                    data[placeholder_key] = {
                        "placeholders": translations["placeholders"]
                    }
        
        # ファイルに書き込み
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        print(f"✅ {filepath}: 10 keys added")
    
    print(f"\n🎉 Phase 3 ARBキー追加完了: 70エントリ (10キー × 7言語)")

if __name__ == "__main__":
    add_arb_keys()
