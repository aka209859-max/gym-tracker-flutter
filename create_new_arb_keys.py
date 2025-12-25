#!/usr/bin/env python3
"""
新規ARBキーの作成スクリプト
Phase 3: 465個の新規キーを全7言語のARBファイルに追加
"""

import json
from pathlib import Path
from typing import Dict

class NewARBKeyCreator:
    def __init__(self):
        self.arb_dir = Path("lib/l10n")
        self.languages = ['de', 'en', 'es', 'ja', 'ko', 'zh', 'zh_TW']
        self.arb_data = {}
        self.load_arb_files()
        
    def load_arb_files(self):
        """全ARBファイルを読み込み"""
        for lang in self.languages:
            arb_file = self.arb_dir / f"app_{lang}.arb"
            with open(arb_file, 'r', encoding='utf-8') as f:
                self.arb_data[lang] = json.load(f)
        print(f"✅ {len(self.languages)}言語のARBファイルを読み込みました")
    
    def save_arb_files(self):
        """全ARBファイルを保存"""
        for lang in self.languages:
            arb_file = self.arb_dir / f"app_{lang}.arb"
            with open(arb_file, 'w', encoding='utf-8') as f:
                json.dump(self.arb_data[lang], f, ensure_ascii=False, indent=2)
        print(f"✅ {len(self.languages)}言語のARBファイルを保存しました")
    
    def add_new_keys_from_analysis(self, analysis_file: str = "japanese_strings_analysis.json"):
        """分析結果から新規キーを追加"""
        with open(analysis_file, 'r', encoding='utf-8') as f:
            analysis = json.load(f)
        
        strings = analysis['strings']
        new_keys_added = 0
        
        print(f"\n🔧 新規キーを追加中...")
        
        for jp_text, info in strings.items():
            if not info['needs_new_key']:
                # 既存キーで対応可能なのでスキップ
                continue
            
            new_key = info['new_key']
            
            # 日本語ARBに追加
            self.arb_data['ja'][new_key] = jp_text
            
            # 他の言語にはプレースホルダーを追加（後でCloud Translation APIで翻訳）
            for lang in self.languages:
                if lang == 'ja':
                    continue
                # プレースホルダー（翻訳待ち）
                self.arb_data[lang][new_key] = f"[TRANSLATE]{jp_text}"
            
            new_keys_added += 1
            
            if new_keys_added % 100 == 0:
                print(f"   進捗: {new_keys_added}/{analysis['new_needed']} キー追加完了")
        
        print(f"\n✅ {new_keys_added}個の新規キーを追加しました")
        return new_keys_added


if __name__ == "__main__":
    print("=" * 80)
    print("Phase 3: 新規ARBキー作成")
    print("=" * 80)
    
    creator = NewARBKeyCreator()
    added_count = creator.add_new_keys_from_analysis()
    creator.save_arb_files()
    
    print("\n" + "=" * 80)
    print(f"Phase 3 完了！ {added_count}個の新規キーを追加しました")
    print("=" * 80)
