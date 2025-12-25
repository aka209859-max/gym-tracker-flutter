#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Phase 6.5: 失敗した53箇所の手動修正スクリプト
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Tuple

class ManualFixHelper:
    def __init__(self):
        self.analysis_file = Path("japanese_strings_analysis.json")
        
    def load_analysis(self) -> Dict:
        """分析結果を読み込む"""
        with open(self.analysis_file, 'r', encoding='utf-8') as f:
            return json.load(f)
    
    def find_failed_replacements(self):
        """失敗した置換を特定"""
        print("=" * 80)
        print("失敗した53箇所の分析")
        print("=" * 80)
        
        analysis = self.load_analysis()
        
        # 失敗したファイルのリスト
        failed_files = [
            'lib/screens/workout/add_workout_screen.dart',
            'lib/screens/workout/ai_coaching_screen.dart',
            'lib/screens/home_screen.dart',
            'lib/screens/map_screen.dart',
            'lib/screens/partner_dashboard_screen.dart',
            'lib/screens/search_screen.dart',
            'lib/services/admob_service.dart',
            'lib/services/campaign_service.dart',
            'lib/services/revenue_cat_service.dart',
            'lib/services/scientific_database.dart',
            'lib/widgets/referral_success_dialog.dart',
            'lib/screens/workout/ai_coaching_screen_tabbed.dart',
            'lib/screens/workout/workout_log_screen.dart'
        ]
        
        failed_strings = {}
        
        for japanese_text, item_data in analysis['strings'].items():
            locations = item_data.get('locations', [])
            
            for location in locations:
                file_str = location.split(':')[0]
                
                if file_str in failed_files:
                    if file_str not in failed_strings:
                        failed_strings[file_str] = []
                    
                    # ARBキーを取得
                    if not item_data.get('needs_new_key', True):
                        arb_key = item_data.get('existing_key', '')
                    else:
                        import hashlib
                        key_hash = hashlib.md5(japanese_text.encode()).hexdigest()[:8]
                        arb_key = f'generatedKey_{key_hash}'
                    
                    # ファイル内容を読み込んで実際に存在するか確認
                    file_path = Path(file_str)
                    if file_path.exists():
                        with open(file_path, 'r', encoding='utf-8') as f:
                            content = f.read()
                        
                        # 文字列リテラルとして存在するか確認
                        if f"'{japanese_text}'" in content or f'"{japanese_text}"' in content:
                            failed_strings[file_str].append({
                                'text': japanese_text,
                                'arb_key': arb_key,
                                'location': location,
                                'line': location.split(':')[1] if ':' in location else 'unknown'
                            })
        
        # 結果を表示
        total_failed = 0
        for file_path, strings in sorted(failed_strings.items()):
            if strings:
                print(f"\n📁 {file_path} ({len(strings)}箇所)")
                total_failed += len(strings)
                for i, item in enumerate(strings[:5], 1):  # 最初の5件のみ表示
                    print(f"   {i}. 行{item['line']}: '{item['text'][:50]}...' → {item['arb_key']}")
                if len(strings) > 5:
                    print(f"   ... 他{len(strings)-5}件")
        
        print(f"\n総失敗数: {total_failed}箇所")
        
        # 詳細レポートを保存
        with open('failed_replacements_detail.json', 'w', encoding='utf-8') as f:
            json.dump(failed_strings, f, ensure_ascii=False, indent=2)
        
        print(f"\n📄 詳細: failed_replacements_detail.json")
        
        return failed_strings

def main():
    helper = ManualFixHelper()
    helper.find_failed_replacements()

if __name__ == "__main__":
    main()
