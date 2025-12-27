#!/usr/bin/env python3
"""
Week 2 Day 4 Step 3 - ARB Keys Addition Script
subscription_screen.dart の10件
"""

import json

# 7言語のファイルパス
LOCALES = {
    'ja': 'lib/l10n/app_ja.arb',
    'en': 'lib/l10n/app_en.arb',
    'ko': 'lib/l10n/app_ko.arb',
    'zh': 'lib/l10n/app_zh.arb',
    'zh_TW': 'lib/l10n/app_zh_TW.arb',
    'de': 'lib/l10n/app_de.arb',
    'es': 'lib/l10n/app_es.arb'
}

# 新しいARBキー（10件）
NEW_KEYS = {
    'ja': {
        'subscription_planManagement': 'プラン管理',
        'subscription_termsOpenFailed': '利用規約を開けませんでした',
        'subscription_cancelInAppStore': '無料プランへの変更は、App Store設定でサブスクリプションをキャンセルしてください',
        'subscription_purchaseFailed': '購入に失敗しました: {error}',
        '@subscription_purchaseFailed': {
            'description': 'サブスクリプション購入失敗メッセージ',
            'placeholders': {
                'error': {
                    'type': 'String',
                    'example': 'Payment declined'
                }
            }
        },
        'subscription_restoreFailed': '復元に失敗しました: {error}',
        '@subscription_restoreFailed': {
            'description': 'サブスクリプション復元失敗メッセージ',
            'placeholders': {
                'error': {
                    'type': 'String',
                    'example': 'No purchases found'
                }
            }
        },
        'subscription_changeTo': '{planName} に変更',
        '@subscription_changeTo': {
            'description': 'プラン変更ボタンラベル',
            'placeholders': {
                'planName': {
                    'type': 'String',
                    'example': 'プレミアムプラン'
                }
            }
        },
        'subscription_changeWarning': '{planName} に変更すると、以下の機能が制限されます：',
        '@subscription_changeWarning': {
            'description': 'プラン変更時の警告メッセージ',
            'placeholders': {
                'planName': {
                    'type': 'String',
                    'example': '無料プラン'
                }
            }
        },
        'subscription_changeInAppStore': 'App Store設定から{planName}へ変更してください',
        '@subscription_changeInAppStore': {
            'description': 'App Storeでのプラン変更案内',
            'placeholders': {
                'planName': {
                    'type': 'String',
                    'example': '無料プラン'
                }
            }
        },
        'subscription_step1': '1. iPhoneの「設定」アプリを開く',
        'subscription_step2': '2. 一番上の[Apple ID]をタップ'
    },
    'en': {
        'subscription_planManagement': 'Plan Management',
        'subscription_termsOpenFailed': 'Failed to open terms of service',
        'subscription_cancelInAppStore': 'To switch to the free plan, cancel your subscription in App Store settings',
        'subscription_purchaseFailed': 'Purchase failed: {error}',
        'subscription_restoreFailed': 'Restore failed: {error}',
        'subscription_changeTo': 'Change to {planName}',
        'subscription_changeWarning': 'Changing to {planName} will restrict the following features:',
        'subscription_changeInAppStore': 'Please change to {planName} in App Store settings',
        'subscription_step1': '1. Open iPhone Settings app',
        'subscription_step2': '2. Tap [Apple ID] at the top'
    },
    'ko': {
        'subscription_planManagement': '플랜 관리',
        'subscription_termsOpenFailed': '이용약관을 열 수 없습니다',
        'subscription_cancelInAppStore': '무료 플랜으로 변경하려면 App Store 설정에서 구독을 취소하세요',
        'subscription_purchaseFailed': '구매 실패: {error}',
        'subscription_restoreFailed': '복원 실패: {error}',
        'subscription_changeTo': '{planName}으로 변경',
        'subscription_changeWarning': '{planName}으로 변경하면 다음 기능이 제한됩니다:',
        'subscription_changeInAppStore': 'App Store 설정에서 {planName}으로 변경하세요',
        'subscription_step1': '1. iPhone 설정 앱 열기',
        'subscription_step2': '2. 맨 위의 [Apple ID] 탭하기'
    },
    'zh': {
        'subscription_planManagement': '套餐管理',
        'subscription_termsOpenFailed': '无法打开服务条款',
        'subscription_cancelInAppStore': '要切换到免费套餐，请在App Store设置中取消订阅',
        'subscription_purchaseFailed': '购买失败：{error}',
        'subscription_restoreFailed': '恢复失败：{error}',
        'subscription_changeTo': '更改为{planName}',
        'subscription_changeWarning': '更改为{planName}将限制以下功能：',
        'subscription_changeInAppStore': '请在App Store设置中更改为{planName}',
        'subscription_step1': '1. 打开iPhone设置应用',
        'subscription_step2': '2. 点击顶部的[Apple ID]'
    },
    'zh_TW': {
        'subscription_planManagement': '方案管理',
        'subscription_termsOpenFailed': '無法開啟服務條款',
        'subscription_cancelInAppStore': '要切換到免費方案，請在App Store設定中取消訂閱',
        'subscription_purchaseFailed': '購買失敗：{error}',
        'subscription_restoreFailed': '恢復失敗：{error}',
        'subscription_changeTo': '更改為{planName}',
        'subscription_changeWarning': '更改為{planName}將限制以下功能：',
        'subscription_changeInAppStore': '請在App Store設定中更改為{planName}',
        'subscription_step1': '1. 開啟iPhone設定應用程式',
        'subscription_step2': '2. 點擊頂部的[Apple ID]'
    },
    'de': {
        'subscription_planManagement': 'Planverwaltung',
        'subscription_termsOpenFailed': 'Nutzungsbedingungen konnten nicht geöffnet werden',
        'subscription_cancelInAppStore': 'Um zum kostenlosen Plan zu wechseln, kündigen Sie Ihr Abonnement in den App Store-Einstellungen',
        'subscription_purchaseFailed': 'Kauf fehlgeschlagen: {error}',
        'subscription_restoreFailed': 'Wiederherstellung fehlgeschlagen: {error}',
        'subscription_changeTo': 'Zu {planName} wechseln',
        'subscription_changeWarning': 'Der Wechsel zu {planName} schränkt die folgenden Funktionen ein:',
        'subscription_changeInAppStore': 'Bitte wechseln Sie in den App Store-Einstellungen zu {planName}',
        'subscription_step1': '1. Öffnen Sie die iPhone-Einstellungen',
        'subscription_step2': '2. Tippen Sie oben auf [Apple ID]'
    },
    'es': {
        'subscription_planManagement': 'Gestión de planes',
        'subscription_termsOpenFailed': 'No se pudieron abrir los términos de servicio',
        'subscription_cancelInAppStore': 'Para cambiar al plan gratuito, cancele su suscripción en la configuración de App Store',
        'subscription_purchaseFailed': 'Error en la compra: {error}',
        'subscription_restoreFailed': 'Error en la restauración: {error}',
        'subscription_changeTo': 'Cambiar a {planName}',
        'subscription_changeWarning': 'Cambiar a {planName} restringirá las siguientes funciones:',
        'subscription_changeInAppStore': 'Por favor, cambie a {planName} en la configuración de App Store',
        'subscription_step1': '1. Abra la aplicación Ajustes de iPhone',
        'subscription_step2': '2. Toque [Apple ID] en la parte superior'
    }
}

def main():
    total_added = 0
    
    for locale, filepath in LOCALES.items():
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # 新しいキーを追加
        keys_to_add = NEW_KEYS[locale]
        for key, value in keys_to_add.items():
            if key not in data:
                data[key] = value
                if not key.startswith('@'):
                    total_added += 1
        
        # ファイルに書き戻し
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"Week 2 Day 4 Step 3 - ARBキー追加（subscription_screen.dart）")
    print(f"Total: {total_added} keys added (10 keys × 7 languages = 70 entries)")
    print("\nNew ARB keys:")
    print("1. subscription_planManagement")
    print("2. subscription_termsOpenFailed")
    print("3. subscription_cancelInAppStore")
    print("4. subscription_purchaseFailed(error)")
    print("5. subscription_restoreFailed(error)")
    print("6. subscription_changeTo(planName)")
    print("7. subscription_changeWarning(planName)")
    print("8. subscription_changeInAppStore(planName)")
    print("9. subscription_step1")
    print("10. subscription_step2")

if __name__ == '__main__':
    main()
