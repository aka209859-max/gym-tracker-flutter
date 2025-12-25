#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Pattern A 自動適用スクリプト (Week 1 Day 2)

目的:
- arb_key_mappings.json の Exact match を使用
- Text() や label: などの安全な箇所のみ置換
- const を避けて安全に適用
- 詳細なログとレポートを生成

使用方法:
    python3 apply_pattern_a.py <target_file.dart> [--dry-run]

例:
    python3 apply_pattern_a.py lib/screens/home_screen.dart --dry-run
    python3 apply_pattern_a.py lib/screens/home_screen.dart
"""

import json
import re
import sys
import os
from typing import Dict, List, Tuple, Set
from pathlib import Path

class PatternAApplier:
    def __init__(self, mapping_file: str = "arb_key_mappings.json"):
        self.mapping_file = mapping_file
        self.mappings: Dict = {}
        self.stats = {
            "total_replacements": 0,
            "safe_replacements": 0,
            "skipped_unsafe": 0,
            "exact_matches": 0,
            "partial_matches": 0
        }
        self.replacements_log: List[Dict] = []
        
    def load_mappings(self):
        """ARB マッピングを読み込み"""
        print(f"📂 Loading mappings from {self.mapping_file}...")
        try:
            with open(self.mapping_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # データ構造チェック: {japanese_string: {key: ..., match_type: ..., arb_value: ...}}
            self.mappings = {}
            
            for japanese_str, entry in data.items():
                if isinstance(entry, dict):
                    # Exact match のみを使用（最も安全）
                    if entry.get("match_type") == "exact" and entry.get("key"):
                        self.mappings[japanese_str] = entry["key"]
            
            print(f"✅ Loaded {len(self.mappings)} exact match mappings")
            return True
            
        except FileNotFoundError:
            print(f"❌ Error: {self.mapping_file} not found!")
            return False
        except json.JSONDecodeError as e:
            print(f"❌ Error: Invalid JSON in {self.mapping_file}: {e}")
            return False
    
    def is_safe_context(self, line: str, match_start: int, match_end: int) -> Tuple[bool, str]:
        """
        置換が安全かどうかを判定
        
        安全なパターン:
        - Text("日本語")
        - Text('日本語')
        - label: "日本語"
        - title: '日本語'
        - hint: "日本語"
        - description: "日本語"
        
        危険なパターン:
        - const Text("日本語")
        - static const String xxx = "日本語"
        - final String xxx = "日本語"
        """
        # 危険パターン: const, static, final
        dangerous_patterns = [
            r'\bconst\s+',
            r'\bstatic\s+const\s+',
            r'\bstatic\s+final\s+',
            r'\bfinal\s+String\s+'
        ]
        
        # 行全体をチェック
        for pattern in dangerous_patterns:
            if re.search(pattern, line):
                return False, "dangerous_keyword"
        
        # 安全なパターン
        safe_patterns = [
            r'Text\s*\(',           # Text(
            r'label\s*:\s*',        # label:
            r'title\s*:\s*',        # title:
            r'hint\s*:\s*',         # hint:
            r'hintText\s*:\s*',     # hintText:
            r'helperText\s*:\s*',   # helperText:
            r'description\s*:\s*',  # description:
            r'subtitle\s*:\s*',     # subtitle:
            r'message\s*:\s*',      # message:
        ]
        
        # マッチ前の50文字をチェック
        context_before = line[max(0, match_start - 50):match_start]
        
        for pattern in safe_patterns:
            if re.search(pattern, context_before):
                return True, pattern.strip()
        
        return False, "no_safe_pattern"
    
    def replace_in_file(self, file_path: str, dry_run: bool = False) -> bool:
        """ファイル内の日本語文字列を置換"""
        if not os.path.exists(file_path):
            print(f"❌ Error: File not found: {file_path}")
            return False
        
        print(f"\n{'🔍 [DRY RUN]' if dry_run else '🔄'} Processing: {file_path}")
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                original_content = f.read()
            
            modified_content = original_content
            lines = original_content.split('\n')
            
            # 各行を処理
            for line_num, line in enumerate(lines, 1):
                # 各マッピングをチェック
                for japanese_str, arb_key in self.mappings.items():
                    # エスケープされた文字列を検索
                    patterns = [
                        f'"{re.escape(japanese_str)}"',  # ダブルクォート
                        f"'{re.escape(japanese_str)}'",  # シングルクォート
                    ]
                    
                    for pattern in patterns:
                        if pattern in line:
                            # マッチ位置を取得
                            match_start = line.find(pattern)
                            match_end = match_start + len(pattern)
                            
                            # 安全性チェック
                            is_safe, reason = self.is_safe_context(line, match_start, match_end)
                            
                            if is_safe:
                                # 置換文字列を作成
                                quote = '"' if pattern.startswith('"') else "'"
                                replacement = f"l10n.{arb_key}"
                                
                                # 置換実行
                                old_pattern = pattern
                                new_line = line.replace(old_pattern, replacement, 1)
                                
                                # ログに記録
                                self.replacements_log.append({
                                    "file": file_path,
                                    "line": line_num,
                                    "japanese": japanese_str,
                                    "arb_key": arb_key,
                                    "old": old_pattern,
                                    "new": replacement,
                                    "context": reason,
                                    "safe": True
                                })
                                
                                # 統計更新
                                self.stats["total_replacements"] += 1
                                self.stats["safe_replacements"] += 1
                                self.stats["exact_matches"] += 1
                                
                                print(f"  ✅ Line {line_num}: {japanese_str[:30]}... → l10n.{arb_key}")
                                
                                # コンテンツ更新
                                modified_content = modified_content.replace(
                                    f"{line}\n" if line_num < len(lines) else line,
                                    f"{new_line}\n" if line_num < len(lines) else new_line,
                                    1
                                )
                                
                                # この行の処理を終了（同じ行の複数置換を避ける）
                                break
                            else:
                                self.stats["skipped_unsafe"] += 1
                                print(f"  ⚠️  Line {line_num}: SKIPPED (unsafe: {reason}): {japanese_str[:30]}...")
            
            # ファイル更新（dry-run でない場合）
            if not dry_run and modified_content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(modified_content)
                print(f"\n✅ File updated: {file_path}")
                return True
            elif dry_run:
                print(f"\n🔍 [DRY RUN] No changes written")
                return True
            else:
                print(f"\n ℹ️  No changes needed")
                return True
                
        except Exception as e:
            print(f"❌ Error processing {file_path}: {e}")
            import traceback
            traceback.print_exc()
            return False
    
    def generate_report(self, output_file: str = "pattern_a_report.txt"):
        """実行レポートを生成"""
        print(f"\n📊 Generating report: {output_file}")
        
        report_lines = [
            "=" * 80,
            "Pattern A Application Report",
            f"Generated: {self._get_timestamp()}",
            "=" * 80,
            "",
            "📊 Statistics:",
            f"  Total replacements attempted: {self.stats['total_replacements']}",
            f"  Safe replacements made: {self.stats['safe_replacements']}",
            f"  Unsafe contexts skipped: {self.stats['skipped_unsafe']}",
            f"  Exact matches used: {self.stats['exact_matches']}",
            "",
            "=" * 80,
            "📝 Detailed Replacement Log:",
            "=" * 80,
            ""
        ]
        
        # 詳細ログ
        for i, entry in enumerate(self.replacements_log, 1):
            report_lines.extend([
                f"{i}. File: {entry['file']}",
                f"   Line: {entry['line']}",
                f"   Japanese: {entry['japanese']}",
                f"   ARB Key: {entry['arb_key']}",
                f"   Old: {entry['old']}",
                f"   New: {entry['new']}",
                f"   Context: {entry['context']}",
                f"   Safe: {entry['safe']}",
                ""
            ])
        
        # ファイルに書き込み
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write('\n'.join(report_lines))
            print(f"✅ Report saved: {output_file}")
            return True
        except Exception as e:
            print(f"❌ Error saving report: {e}")
            return False
    
    def _get_timestamp(self):
        """現在のタイムスタンプを取得"""
        from datetime import datetime
        return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def main():
    """メイン処理"""
    print("=" * 80)
    print("🚀 Pattern A Auto-Applier (Week 1 Day 2)")
    print("=" * 80)
    
    # 引数チェック
    if len(sys.argv) < 2:
        print("\n❌ Error: Missing target file argument")
        print("\nUsage:")
        print("  python3 apply_pattern_a.py <target_file.dart> [--dry-run]")
        print("\nExample:")
        print("  python3 apply_pattern_a.py lib/screens/home_screen.dart --dry-run")
        sys.exit(1)
    
    target_file = sys.argv[1]
    dry_run = "--dry-run" in sys.argv
    
    if dry_run:
        print("\n🔍 DRY RUN MODE: No files will be modified")
    
    # スクリプト実行
    applier = PatternAApplier()
    
    # マッピング読み込み
    if not applier.load_mappings():
        sys.exit(1)
    
    # ファイル処理
    success = applier.replace_in_file(target_file, dry_run)
    
    # レポート生成
    if applier.stats["total_replacements"] > 0:
        report_file = f"pattern_a_report_{Path(target_file).stem}.txt"
        applier.generate_report(report_file)
    
    # 結果サマリー
    print("\n" + "=" * 80)
    print("📊 Final Summary:")
    print("=" * 80)
    print(f"  Safe replacements: {applier.stats['safe_replacements']}")
    print(f"  Unsafe skipped: {applier.stats['skipped_unsafe']}")
    print(f"  Success: {'✅ YES' if success else '❌ NO'}")
    print("=" * 80)
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
