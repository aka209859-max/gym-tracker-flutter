#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Pattern A 自動適用スクリプト v2 (Week 1 Day 2)

2段階戦略:
  Step 1: const Text() から const を削除
  Step 2: 日本語文字列を l10n.xxx に置換

使用方法:
    python3 apply_pattern_a_v2.py <target_file.dart> [--dry-run]
"""

import json
import re
import sys
import os
from typing import Dict, List, Tuple
from pathlib import Path

class PatternAApplierV2:
    def __init__(self, mapping_file: str = "arb_key_mappings.json"):
        self.mapping_file = mapping_file
        self.mappings: Dict = {}
        self.stats = {
            "const_removed": 0,
            "replacements": 0,
            "skipped": 0
        }
        self.log: List[str] = []
        
    def load_mappings(self):
        """ARB マッピングを読み込み"""
        print(f"📂 Loading mappings from {self.mapping_file}...")
        try:
            with open(self.mapping_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            self.mappings = {}
            for japanese_str, entry in data.items():
                if isinstance(entry, dict) and entry.get("match_type") == "exact" and entry.get("key"):
                    self.mappings[japanese_str] = entry["key"]
            
            print(f"✅ Loaded {len(self.mappings)} exact match mappings")
            return True
            
        except Exception as e:
            print(f"❌ Error loading mappings: {e}")
            return False
    
    def step1_remove_const(self, content: str) -> Tuple[str, int]:
        """
        Step 1: const Text() の const を削除
        
        パターン:
        - const Text( → Text(
        - const SizedBox( → SizedBox(
        - const Icon( → Icon(
        - const Padding( → Padding(
        """
        patterns = [
            (r'\bconst\s+Text\s*\(', 'Text('),
            (r'\bconst\s+SizedBox\s*\(', 'SizedBox('),
            (r'\bconst\s+Icon\s*\(', 'Icon('),
            (r'\bconst\s+Padding\s*\(', 'Padding('),
            (r'\bconst\s+Center\s*\(', 'Center('),
            (r'\bconst\s+Expanded\s*\(', 'Expanded('),
        ]
        
        modified = content
        count = 0
        
        for pattern, replacement in patterns:
            matches = re.findall(pattern, modified)
            if matches:
                modified = re.sub(pattern, replacement, modified)
                count += len(matches)
                self.log.append(f"  ✅ Removed {len(matches)} × '{pattern}' → '{replacement}'")
        
        return modified, count
    
    def step2_replace_strings(self, content: str) -> Tuple[str, int, int]:
        """
        Step 2: 日本語文字列を l10n.xxx に置換
        
        安全なコンテキスト:
        - Text("日本語")
        - label: "日本語"
        - title: "日本語"
        """
        modified = content
        replaced = 0
        skipped = 0
        
        # 各マッピングを処理
        for japanese_str, arb_key in self.mappings.items():
            # ダブルクォート/シングルクォートのパターン
            patterns = [
                (f'"{re.escape(japanese_str)}"', f'l10n.{arb_key}'),
                (f"'{re.escape(japanese_str)}'", f'l10n.{arb_key}'),
            ]
            
            for old_pattern, new_pattern in patterns:
                if old_pattern in modified:
                    # 危険なコンテキストチェック
                    # static const, final などは避ける
                    lines = modified.split('\n')
                    safe_to_replace = True
                    
                    for line in lines:
                        if old_pattern in line:
                            # 危険なパターンチェック
                            if any(keyword in line for keyword in ['static const', 'static final', 'final String']):
                                safe_to_replace = False
                                break
                    
                    if safe_to_replace:
                        modified = modified.replace(old_pattern, new_pattern)
                        replaced += 1
                        self.log.append(f"  ✅ Replaced: {japanese_str[:30]}... → l10n.{arb_key}")
                    else:
                        skipped += 1
                        self.log.append(f"  ⚠️  Skipped (unsafe): {japanese_str[:30]}...")
        
        return modified, replaced, skipped
    
    def process_file(self, file_path: str, dry_run: bool = False) -> bool:
        """ファイル全体を処理"""
        if not os.path.exists(file_path):
            print(f"❌ File not found: {file_path}")
            return False
        
        print(f"\n{'🔍 [DRY RUN]' if dry_run else '🔄'} Processing: {file_path}")
        print("=" * 80)
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                original = f.read()
            
            # Step 1: const 削除
            print("\n📍 Step 1: Removing dangerous 'const' keywords...")
            modified, const_count = self.step1_remove_const(original)
            self.stats["const_removed"] = const_count
            
            if const_count > 0:
                print(f"  ✅ Removed {const_count} 'const' keywords")
            else:
                print("  ℹ️  No 'const' keywords found")
            
            # Step 2: 文字列置換
            print("\n📍 Step 2: Replacing Japanese strings with l10n...")
            modified, replaced, skipped = self.step2_replace_strings(modified)
            self.stats["replacements"] = replaced
            self.stats["skipped"] = skipped
            
            # 結果表示
            for log_entry in self.log:
                print(log_entry)
            
            # ファイル更新
            if not dry_run and modified != original:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(modified)
                print(f"\n✅ File updated: {file_path}")
            elif dry_run:
                print(f"\n🔍 [DRY RUN] No changes written")
            else:
                print(f"\n ℹ️  No changes needed")
            
            return True
            
        except Exception as e:
            print(f"❌ Error: {e}")
            import traceback
            traceback.print_exc()
            return False
    
    def generate_report(self, output_file: str):
        """レポート生成"""
        report = [
            "=" * 80,
            "Pattern A Application Report v2",
            "=" * 80,
            "",
            f"📊 Statistics:",
            f"  const removed: {self.stats['const_removed']}",
            f"  Replacements: {self.stats['replacements']}",
            f"  Skipped (unsafe): {self.stats['skipped']}",
            "",
            "=" * 80,
            "Detailed Log:",
            "=" * 80,
            ""
        ]
        
        report.extend(self.log)
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write('\n'.join(report))
        
        print(f"\n📄 Report saved: {output_file}")

def main():
    print("=" * 80)
    print("🚀 Pattern A Auto-Applier V2 (Week 1 Day 2)")
    print("=" * 80)
    
    if len(sys.argv) < 2:
        print("\n❌ Usage: python3 apply_pattern_a_v2.py <file.dart> [--dry-run]")
        sys.exit(1)
    
    target_file = sys.argv[1]
    dry_run = "--dry-run" in sys.argv
    
    if dry_run:
        print("\n🔍 DRY RUN MODE: No files will be modified\n")
    
    applier = PatternAApplierV2()
    
    if not applier.load_mappings():
        sys.exit(1)
    
    success = applier.process_file(target_file, dry_run)
    
    # レポート生成
    report_file = f"pattern_a_v2_report_{Path(target_file).stem}.txt"
    applier.generate_report(report_file)
    
    # サマリー
    print("\n" + "=" * 80)
    print("📊 Final Summary:")
    print("=" * 80)
    print(f"  const removed: {applier.stats['const_removed']}")
    print(f"  Replacements: {applier.stats['replacements']}")
    print(f"  Skipped: {applier.stats['skipped']}")
    print(f"  Success: {'✅ YES' if success else '❌ NO'}")
    print("=" * 80)
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
