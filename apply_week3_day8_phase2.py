#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Week 3 Day 8 Phase 2: 文字列置換スクリプト
対象: subscription_screen.dart (10件)
"""

import re

def replace_strings():
    """subscription_screen.dartの文字列を置換"""
    
    filepath = "lib/screens/subscription_screen.dart"
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Pattern 1: 'Restore'
    content = re.sub(
        r"'Restore'",
        "AppLocalizations.of(context)!.subscription_restore",
        content
    )
    
    # Pattern 2: '永年Proプラン（∞）'
    content = re.sub(
        r"'永年Proプラン（∞）'",
        "AppLocalizations.of(context)!.subscription_lifetimeProPlan",
        content
    )
    
    # Pattern 3: 'AI機能無制限 | 広告なし | すべての機能を永久利用'
    content = re.sub(
        r"'AI機能無制限 \| 広告なし \| すべての機能を永久利用'",
        "AppLocalizations.of(context)!.subscription_lifetimePlanDescription",
        content
    )
    
    # Pattern 4: '⭐ 人気No.1'
    content = re.sub(
        r"'⭐ 人気No\.1'",
        "AppLocalizations.of(context)!.subscription_popularBadge",
        content
    )
    
    # Pattern 5: 'Legal Information'
    content = re.sub(
        r"'Legal Information'",
        "AppLocalizations.of(context)!.subscription_legalInformation",
        content
    )
    
    # Pattern 6: 'Terms of Use'
    content = re.sub(
        r"'Terms of Use'",
        "AppLocalizations.of(context)!.subscription_termsOfUse",
        content
    )
    
    # Pattern 7: 'Privacy Policy'
    content = re.sub(
        r"'Privacy Policy'",
        "AppLocalizations.of(context)!.subscription_privacyPolicy",
        content
    )
    
    # Pattern 8: 'By subscribing, you agree to our Terms of Use and Privacy Policy'
    content = re.sub(
        r"'By subscribing, you agree to our Terms of Use and Privacy Policy'",
        "AppLocalizations.of(context)!.subscription_agreementText",
        content
    )
    
    # Pattern 9: '¥300 / 5回'
    content = re.sub(
        r"'¥300 / 5回'",
        "AppLocalizations.of(context)!.subscription_aiAddonPrice",
        content
    )
    
    # Pattern 10: const Text('3. 「サブスクリプション」をタップ')
    # constがある場合は削除
    content = re.sub(
        r"const Text\('3\. 「サブスクリプション」をタップ'\)",
        "Text(AppLocalizations.of(context)!.subscription_cancelInstruction3)",
        content
    )
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ {filepath}: 10/10 replacements completed")
    print(f"   - Pattern 1: 'Restore'")
    print(f"   - Pattern 2: '永年Proプラン（∞）'")
    print(f"   - Pattern 3: AI機能無制限...")
    print(f"   - Pattern 4: '⭐ 人気No.1'")
    print(f"   - Pattern 5: 'Legal Information'")
    print(f"   - Pattern 6: 'Terms of Use'")
    print(f"   - Pattern 7: 'Privacy Policy'")
    print(f"   - Pattern 8: agreement text")
    print(f"   - Pattern 9: '¥300 / 5回'")
    print(f"   - Pattern 10: '3. 「サブスクリプション」をタップ'")
    print(f"\n🎉 Week 3 Day 8 Phase 2 - 文字列置換完了")

if __name__ == "__main__":
    replace_strings()
