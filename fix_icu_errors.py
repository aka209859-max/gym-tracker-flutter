#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ICUエラー修正スクリプト - 問題のある3つのキーを削除
"""

import json
from pathlib import Path

def fix_icu_errors():
    print("=" * 80)
    print("ICUエラー修正：問題のあるキーを削除")
    print("=" * 80)
    
    # 削除するキーのリスト
    problematic_keys = [
        'autoGen_08aedbf7',  # HTMLエンティティ問題
        'autoGen_51ce78c9',  # HTMLエンティティ問題
        'autoGen_4360465c',  # ?演算子の問題
    ]
    
    languages = ['ja', 'en', 'de', 'es', 'ko', 'zh', 'zh_TW']
    l10n_dir = Path('lib/l10n')
    
    total_removed = 0
    
    for lang in languages:
        arb_file = l10n_dir / f'app_{lang}.arb'
        
        print(f"\n🔧 {lang.upper()}: {arb_file}")
        
        # ARBファイルを読み込む
        with open(arb_file, 'r', encoding='utf-8') as f:
            arb_data = json.load(f)
        
        removed_count = 0
        
        # 問題のあるキーを削除
        for key in problematic_keys:
            if key in arb_data:
                del arb_data[key]
                removed_count += 1
                print(f"   ✅ 削除: {key}")
            
            # メタデータも削除
            meta_key = f'@{key}'
            if meta_key in arb_data:
                del arb_data[meta_key]
        
        # ARBファイルを保存
        with open(arb_file, 'w', encoding='utf-8') as f:
            json.dump(arb_data, f, ensure_ascii=False, indent=2)
        
        total_removed += removed_count
        print(f"   削除数: {removed_count}キー")
    
    print(f"\n" + "=" * 80)
    print(f"✅ 完了：{total_removed}キーを削除しました（{len(problematic_keys)}キー × {len(languages)}言語）")
    print("=" * 80)

if __name__ == "__main__":
    fix_icu_errors()
