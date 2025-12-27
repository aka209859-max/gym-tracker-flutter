#!/usr/bin/env python3
"""
Week 3 Day 6 Phase 1 - ARB Keys Addition Script
developer_menu_screen.dart の10件
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
        'dev_uidCopied': '✅ UIDをコピーしました\n{uid}',
        '@dev_uidCopied': {
            'description': '開発者メニュー: UID コピー成功',
            'placeholders': {
                'uid': {
                    'type': 'String',
                    'example': 'abc123xyz'
                }
            }
        },
        'dev_aiUsageReset': '✅ AI使用回数をリセットしました',
        'dev_resetFailed': '❌ リセット失敗: {error}',
        '@dev_resetFailed': {
            'description': '開発者メニュー: リセット失敗',
            'placeholders': {
                'error': {
                    'type': 'String',
                    'example': 'Network error'
                }
            }
        },
        'dev_onboardingReset': '✅ オンボーディングをリセットしました\nアプリを再起動してください',
        'dev_phase1Reset': '✅ Phase 1機能をすべてリセットしました\nアプリを再起動してください',
        'dev_resetAiUsage': 'AI使用回数をリセット',
        'dev_resetOnboarding': 'オンボーディングをリセット',
        'dev_resetPhase1': 'Phase 1機能をすべてリセット'
    },
    'en': {
        'dev_uidCopied': '✅ UID copied\n{uid}',
        'dev_aiUsageReset': '✅ AI usage count reset',
        'dev_resetFailed': '❌ Reset failed: {error}',
        'dev_onboardingReset': '✅ Onboarding reset\nPlease restart the app',
        'dev_phase1Reset': '✅ All Phase 1 features reset\nPlease restart the app',
        'dev_resetAiUsage': 'Reset AI usage count',
        'dev_resetOnboarding': 'Reset onboarding',
        'dev_resetPhase1': 'Reset all Phase 1 features'
    },
    'ko': {
        'dev_uidCopied': '✅ UID 복사됨\n{uid}',
        'dev_aiUsageReset': '✅ AI 사용 횟수 초기화됨',
        'dev_resetFailed': '❌ 초기화 실패: {error}',
        'dev_onboardingReset': '✅ 온보딩 초기화됨\n앱을 재시작하세요',
        'dev_phase1Reset': '✅ Phase 1 기능 모두 초기화됨\n앱을 재시작하세요',
        'dev_resetAiUsage': 'AI 사용 횟수 초기화',
        'dev_resetOnboarding': '온보딩 초기화',
        'dev_resetPhase1': 'Phase 1 기능 모두 초기화'
    },
    'zh': {
        'dev_uidCopied': '✅ 已复制UID\n{uid}',
        'dev_aiUsageReset': '✅ AI使用次数已重置',
        'dev_resetFailed': '❌ 重置失败：{error}',
        'dev_onboardingReset': '✅ 引导流程已重置\n请重启应用',
        'dev_phase1Reset': '✅ Phase 1功能已全部重置\n请重启应用',
        'dev_resetAiUsage': '重置AI使用次数',
        'dev_resetOnboarding': '重置引导流程',
        'dev_resetPhase1': '重置所有Phase 1功能'
    },
    'zh_TW': {
        'dev_uidCopied': '✅ 已複製UID\n{uid}',
        'dev_aiUsageReset': '✅ AI使用次數已重設',
        'dev_resetFailed': '❌ 重設失敗：{error}',
        'dev_onboardingReset': '✅ 引導流程已重設\n請重啟應用程式',
        'dev_phase1Reset': '✅ Phase 1功能已全部重設\n請重啟應用程式',
        'dev_resetAiUsage': '重設AI使用次數',
        'dev_resetOnboarding': '重設引導流程',
        'dev_resetPhase1': '重設所有Phase 1功能'
    },
    'de': {
        'dev_uidCopied': '✅ UID kopiert\n{uid}',
        'dev_aiUsageReset': '✅ KI-Nutzungszähler zurückgesetzt',
        'dev_resetFailed': '❌ Zurücksetzen fehlgeschlagen: {error}',
        'dev_onboardingReset': '✅ Onboarding zurückgesetzt\nBitte App neu starten',
        'dev_phase1Reset': '✅ Alle Phase 1 Funktionen zurückgesetzt\nBitte App neu starten',
        'dev_resetAiUsage': 'KI-Nutzungszähler zurücksetzen',
        'dev_resetOnboarding': 'Onboarding zurücksetzen',
        'dev_resetPhase1': 'Alle Phase 1 Funktionen zurücksetzen'
    },
    'es': {
        'dev_uidCopied': '✅ UID copiado\n{uid}',
        'dev_aiUsageReset': '✅ Contador de uso de IA restablecido',
        'dev_resetFailed': '❌ Error al restablecer: {error}',
        'dev_onboardingReset': '✅ Onboarding restablecido\nPor favor, reinicie la app',
        'dev_phase1Reset': '✅ Todas las funciones de Phase 1 restablecidas\nPor favor, reinicie la app',
        'dev_resetAiUsage': 'Restablecer contador de uso de IA',
        'dev_resetOnboarding': 'Restablecer onboarding',
        'dev_resetPhase1': 'Restablecer todas las funciones de Phase 1'
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
    
    print(f"Week 3 Day 6 Phase 1 - ARBキー追加（developer_menu）")
    print(f"Total: {total_added} keys added (8 keys × 7 languages = 56 entries)")
    print("\nNew ARB keys:")
    print("1. dev_uidCopied(uid)")
    print("2. dev_aiUsageReset")
    print("3. dev_resetFailed(error) - used 3 times")
    print("4. dev_onboardingReset")
    print("5. dev_phase1Reset")
    print("6. dev_resetAiUsage")
    print("7. dev_resetOnboarding")
    print("8. dev_resetPhase1")
    print("\nTotal replacements: 10 (some keys used multiple times)")

if __name__ == '__main__':
    main()
