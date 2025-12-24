#!/usr/bin/env python3
"""
日本語ハードコード文字列の抽出・分類スクリプト
Phase 2: 全Dartファイルから日本語文字列を検出し、既存ARBキーとマッチング
"""

import json
import re
import hashlib
from pathlib import Path
from typing import Dict, List, Tuple, Set

class JapaneseStringExtractor:
    def __init__(self):
        self.arb_dir = Path("lib/l10n")
        self.lib_dir = Path("lib")
        self.existing_arb_keys = {}
        self.load_existing_arb()
        
    def load_existing_arb(self):
        """既存のARBファイル（日本語）を読み込み"""
        ja_arb_file = self.arb_dir / "app_ja.arb"
        with open(ja_arb_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
            self.existing_arb_keys = {k: v for k, v in data.items() if not k.startswith('@')}
        print(f"✅ 既存ARBキー数: {len(self.existing_arb_keys)}")
    
    def is_debug_or_log_string(self, text: str) -> bool:
        """デバッグログやエラーメッセージかどうか判定"""
        debug_markers = ['❌', '✅', '📊', '📅', '🔄', '⚠️', '🔍', '💪', 
                        'エラー:', 'Error', 'DEBUG', 'LOG', 'INFO',
                        '開始', '完了', '失敗', '成功']
        return any(marker in text for marker in debug_markers)
    
    def extract_japanese_strings_from_file(self, dart_file: Path) -> List[Tuple[int, str]]:
        """Dartファイルから日本語文字列を抽出"""
        results = []
        try:
            content = dart_file.read_text(encoding='utf-8')
            lines = content.split('\n')
            
            # 日本語文字列のパターン（シングルクォートまたはダブルクォート）
            pattern = re.compile(r'[\'"]([^\'"]*[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]+[^\'"]*)[\'"]')
            
            for line_num, line in enumerate(lines, 1):
                # コメント行をスキップ
                if line.strip().startswith('//'):
                    continue
                
                matches = pattern.findall(line)
                for match in matches:
                    # 短すぎる文字列やデバッグログをスキップ
                    if len(match) <= 1 or self.is_debug_or_log_string(match):
                        continue
                    
                    # コード断片を除外（変数宣言など）
                    if any(x in match for x in ['_', '=', ';', '{', '}', '(', ')', '[', ']']):
                        # ただし、UIテキストに含まれる括弧などは許可
                        if not any(ui_word in match for ui_word in ['を', 'が', 'に', 'の', 'は', 'です', 'ます']):
                            continue
                    
                    results.append((line_num, match))
        except Exception as e:
            print(f"⚠️  ファイル読み込みエラー: {dart_file}: {e}")
        
        return results
    
    def find_matching_arb_key(self, japanese_text: str) -> Tuple[str, str]:
        """
        日本語テキストに一致する既存のARBキーを検索
        
        Returns:
            (key_name, match_type) - ('existing_key', 'exact') or (None, None)
        """
        # 完全一致
        for key, value in self.existing_arb_keys.items():
            if value == japanese_text:
                return (key, 'exact')
        
        # 部分一致（短い文字列のみ）
        if len(japanese_text) <= 10:
            for key, value in self.existing_arb_keys.items():
                if japanese_text in value or value in japanese_text:
                    return (key, 'partial')
        
        return (None, None)
    
    def extract_all_japanese_strings(self) -> Dict:
        """全Dartファイルから日本語文字列を抽出し分類"""
        all_strings = {}
        matched_count = 0
        new_needed_count = 0
        
        dart_files = list(self.lib_dir.rglob("*.dart"))
        print(f"\n🔍 {len(dart_files)}個のDartファイルを解析中...")
        
        for dart_file in dart_files:
            extracted = self.extract_japanese_strings_from_file(dart_file)
            
            for line_num, jp_text in extracted:
                # 既に処理済みの文字列はスキップ
                if jp_text in all_strings:
                    all_strings[jp_text]['locations'].append(f"{dart_file}:{line_num}")
                    continue
                
                # 既存ARBキーとマッチング
                existing_key, match_type = self.find_matching_arb_key(jp_text)
                
                if existing_key:
                    matched_count += 1
                    all_strings[jp_text] = {
                        'text': jp_text,
                        'existing_key': existing_key,
                        'match_type': match_type,
                        'needs_new_key': False,
                        'locations': [f"{dart_file}:{line_num}"]
                    }
                else:
                    new_needed_count += 1
                    # 新規キー名を生成
                    text_hash = hashlib.md5(jp_text.encode('utf-8')).hexdigest()[:8]
                    new_key = f"autoGen_{text_hash}"
                    
                    all_strings[jp_text] = {
                        'text': jp_text,
                        'existing_key': None,
                        'new_key': new_key,
                        'needs_new_key': True,
                        'locations': [f"{dart_file}:{line_num}"]
                    }
        
        print(f"\n📊 検出結果:")
        print(f"   総日本語文字列数: {len(all_strings)}")
        print(f"   ✅ 既存キーで対応可能: {matched_count}")
        print(f"   🆕 新規キーが必要: {new_needed_count}")
        
        return {
            'total': len(all_strings),
            'matched': matched_count,
            'new_needed': new_needed_count,
            'strings': all_strings
        }
    
    def save_analysis_result(self, result: Dict, output_file: str = "japanese_strings_analysis.json"):
        """分析結果をJSONファイルに保存"""
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(result, f, ensure_ascii=False, indent=2)
        print(f"\n✅ 分析結果を保存: {output_file}")


if __name__ == "__main__":
    print("=" * 80)
    print("Phase 2: 日本語ハードコード検出・分類")
    print("=" * 80)
    
    extractor = JapaneseStringExtractor()
    result = extractor.extract_all_japanese_strings()
    extractor.save_analysis_result(result)
    
    print("\n" + "=" * 80)
    print("Phase 2 完了！")
    print("=" * 80)
