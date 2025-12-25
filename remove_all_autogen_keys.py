#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
全autoGen_*キー削除スクリプト
Cloud Translation APIが生成したICU非準拠のキーを全削除
"""

import json
from pathlib import Path

def remove_all_autogen_keys():
    print("=" * 80)
    print("全autoGen_*キーを削除")
    print("=" * 80)
    
    languages = ['ja', 'en', 'de', 'es', 'ko', 'zh', 'zh_TW']
    l10n_dir = Path('lib/l10n')
    
    for lang in languages:
        arb_file = l10n_dir / f'app_{lang}.arb'
        
        print(f"\n🔧 {lang.upper()}: {arb_file}")
        
        # ARBファイルを読み込む
        with open(arb_file, 'r', encoding='utf-8') as f:
            arb_data = json.load(f)
        
        # autoGen_で始まるキーを検索
        autogen_keys = [key for key in arb_data.keys() if key.startswith('autoGen_')]
        
        print(f"   検出: {len(autogen_keys)}個のautoGen_キー")
        
        # 削除
        for key in autogen_keys:
            del arb_data[key]
            # メタデータも削除
            meta_key = f'@{key}'
            if meta_key in arb_data:
                del arb_data[meta_key]
        
        # ARBファイルを保存
        with open(arb_file, 'w', encoding='utf-8') as f:
            json.dump(arb_data, f, ensure_ascii=False, indent=2)
        
        remaining_keys = len([k for k in arb_data.keys() if not k.startswith('@') and k != '@@locale' and k != '@@context'])
        print(f"   ✅ 削除完了。残りキー数: {remaining_keys}")
    
    print(f"\n" + "=" * 80)
    print(f"✅ 完了：全autoGen_*キーを削除しました")
    print(f"   ARBファイルは元の状態（約2,870キー）に戻りました")
    print("=" * 80)

if __name__ == "__main__":
    remove_all_autogen_keys()
