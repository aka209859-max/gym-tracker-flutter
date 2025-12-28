#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Week 3 Day 8 Phase 3: 文字列置換スクリプト
対象: profile_screen.dart (10件)
"""

import re

def replace_strings():
    """profile_screen.dartの文字列を置換"""
    
    filepath = "lib/screens/profile_screen.dart"
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Pattern 1: '🎁 紹介特典'
    content = re.sub(
        r"'🎁 紹介特典'",
        "AppLocalizations.of(context)!.profile_referralBonusTitle",
        content
    )
    
    # Pattern 2: '💡 友達がこのコードを入力すると、両方に特典が届きます！'
    content = re.sub(
        r"'💡 友達がこのコードを入力すると、両方に特典が届きます！'",
        "AppLocalizations.of(context)!.profile_referralBonusHint",
        content
    )
    
    # Pattern 3: 紹介コードのシェアメッセージ
    pattern3 = r"'GYM MATCHで一緒にトレーニングしませんか\?\\n\\n'\s*'紹介コード: \$referralCode\\n'\s*'AI使用回数3回がもらえます！\\n\\n'\s*'https://gym-match-e560d\.web\.app'"
    replacement3 = "AppLocalizations.of(context)!.profile_referralShareMessage(referralCode)"
    content = re.sub(pattern3, replacement3, content)
    
    # Pattern 4: '❌ エラー: ${e.toString()}'
    content = re.sub(
        r"'❌ エラー: \$\{e\.toString\(\)\}'",
        "AppLocalizations.of(context)!.profile_errorMessage(e.toString())",
        content
    )
    
    # Pattern 5: '$title: $reward'
    content = re.sub(
        r"'\$title: \$reward'",
        "AppLocalizations.of(context)!.profile_rewardItem(title, reward)",
        content
    )
    
    # Pattern 6: 'トレーニングユーザー'
    content = re.sub(
        r"'トレーニングユーザー'",
        "AppLocalizations.of(context)!.profile_defaultUsername",
        content
    )
    
    # Pattern 7: 'GYM MATCHへようこそ'
    content = re.sub(
        r"'GYM MATCHへようこそ'",
        "AppLocalizations.of(context)!.profile_defaultBio",
        content
    )
    
    # Pattern 8: 'AI x5回 + 紹介された人もAI x3回'
    content = re.sub(
        r"'AI x5回 \+ 紹介された人もAI x3回'",
        "AppLocalizations.of(context)!.profile_referralRewardDescription",
        content
    )
    
    # Pattern 9: '$featureNameは有料プラン会員限定の機能です。'
    content = re.sub(
        r"'\$featureNameは有料プラン会員限定の機能です。'",
        "AppLocalizations.of(context)!.profile_premiumOnlyFeature(featureName)",
        content
    )
    
    # Pattern 10: '$featureNameは現在開発中です。\n次回のアップデートでご利用いただけます。'
    content = re.sub(
        r"'\$featureNameは現在開発中です。\\n次回のアップデートでご利用いただけます。'",
        "AppLocalizations.of(context)!.profile_featureInDevelopment(featureName)",
        content
    )
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ {filepath}: 10/10 replacements completed")
    print(f"   - Pattern 1: '🎁 紹介特典'")
    print(f"   - Pattern 2: referral bonus hint")
    print(f"   - Pattern 3: referral share message")
    print(f"   - Pattern 4: error message")
    print(f"   - Pattern 5: reward item")
    print(f"   - Pattern 6: 'トレーニングユーザー'")
    print(f"   - Pattern 7: 'GYM MATCHへようこそ'")
    print(f"   - Pattern 8: referral reward description")
    print(f"   - Pattern 9: premium only feature")
    print(f"   - Pattern 10: feature in development")
    print(f"\n🎉 Week 3 Day 8 Phase 3 - 文字列置換完了")

if __name__ == "__main__":
    replace_strings()
