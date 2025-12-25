#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Phase 6: Dartコード自動修正スクリプト
日本語ハードコードをARBキーで置換
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Tuple

class DartCodeReplacer:
    def __init__(self):
        self.analysis_file = Path("japanese_strings_analysis.json")
        self.backup_dir = Path("dart_backup")
        
    def load_analysis(self) -> Dict:
        """分析結果を読み込む"""
        with open(self.analysis_file, 'r', encoding='utf-8') as f:
            return json.load(f)
    
    def backup_file(self, file_path: Path):
        """ファイルをバックアップ"""
        # 相対パスまたは絶対パスを処理
        if file_path.is_absolute():
            rel_path = file_path.relative_to(Path.cwd())
        else:
            rel_path = file_path
        
        backup_path = self.backup_dir / rel_path
        backup_path.parent.mkdir(parents=True, exist_ok=True)
        
        if file_path.exists():
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(content)
    
    def escape_regex(self, text: str) -> str:
        """正規表現特殊文字をエスケープ"""
        return re.escape(text)
    
    def generate_localization_call(self, key: str, file_content: str) -> str:
        """ローカライゼーション呼び出しコードを生成"""
        # AppLocalizationsの使用状況を確認
        if 'AppLocalizations.of(context)' in file_content:
            return f"AppLocalizations.of(context)!.{key}"
        elif 'final l10n = AppLocalizations.of(context)' in file_content:
            return f"l10n!.{key}"
        else:
            # デフォルトは標準的な呼び出し
            return f"AppLocalizations.of(context)!.{key}"
    
    def replace_in_file(self, file_path: Path, replacements: List[Tuple[str, str]]) -> Tuple[int, int]:
        """ファイル内の文字列を置換"""
        if not file_path.exists():
            return 0, 0
        
        # バックアップ
        self.backup_file(file_path)
        
        # ファイル読み込み
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        replaced_count = 0
        failed_count = 0
        
        for japanese_text, arb_key in replacements:
            # 文字列リテラルのパターンを検索
            patterns = [
                f"'{self.escape_regex(japanese_text)}'",  # シングルクォート
                f'"{self.escape_regex(japanese_text)}"',  # ダブルクォート
            ]
            
            replacement = self.generate_localization_call(arb_key, content)
            
            replaced_this = False
            for pattern in patterns:
                if re.search(pattern, content):
                    content = re.sub(pattern, replacement, content)
                    replaced_this = True
                    break
            
            if replaced_this:
                replaced_count += 1
            else:
                failed_count += 1
        
        # 変更があれば保存
        if content != original_content:
            # AppLocalizationsのimportを確認・追加
            if 'AppLocalizations.of(context)' in content and \
               'package:gym_match/gen/app_localizations.dart' not in content:
                # importセクションを探す
                import_match = re.search(r"(import\s+['\"].*?['\"];?\s*\n)+", content)
                if import_match:
                    last_import_pos = import_match.end()
                    import_statement = "import 'package:gym_match/gen/app_localizations.dart';\n"
                    content = content[:last_import_pos] + import_statement + content[last_import_pos:]
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
        
        return replaced_count, failed_count
    
    def process_all(self):
        """全ファイルを処理"""
        print("=" * 80)
        print("Phase 6: Dartコード自動修正")
        print("=" * 80)
        
        # 分析結果を読み込み
        analysis = self.load_analysis()
        
        # ファイル別に置換対象をグループ化
        file_replacements = {}
        
        for japanese_text, item_data in analysis['strings'].items():
            # locations から全ファイルを取得
            locations = item_data.get('locations', [])
            
            # ARBキーを決定
            if not item_data.get('needs_new_key', True):
                arb_key = item_data.get('existing_key', '')
            else:
                # 新規キーを生成（簡易版）
                import hashlib
                key_hash = hashlib.md5(japanese_text.encode()).hexdigest()[:8]
                arb_key = f'generatedKey_{key_hash}'
            
            if not arb_key:
                continue
            
            # 各ロケーションを処理
            for location in locations:
                # location形式: "lib/xxx.dart:123"
                file_str = location.split(':')[0]
                file_path = Path(file_str)
                
                if file_path not in file_replacements:
                    file_replacements[file_path] = []
                
                file_replacements[file_path].append((japanese_text, arb_key))
        
        print(f"\n📊 処理対象:")
        print(f"   ファイル数: {len(file_replacements)}")
        print(f"   置換箇所: {analysis['total']}")
        
        # バックアップディレクトリ作成
        self.backup_dir.mkdir(exist_ok=True)
        
        # ファイルごとに処理
        total_replaced = 0
        total_failed = 0
        processed_files = 0
        
        for file_path, replacements in file_replacements.items():
            print(f"\n📝 処理中: {file_path} ({len(replacements)}箇所)")
            
            replaced, failed = self.replace_in_file(file_path, replacements)
            total_replaced += replaced
            total_failed += failed
            processed_files += 1
            
            if replaced > 0:
                print(f"   ✅ 置換成功: {replaced}箇所")
            if failed > 0:
                print(f"   ⚠️ 置換失敗: {failed}箇所")
        
        # 結果サマリー
        print("\n" + "=" * 80)
        print("Phase 6 完了！Dartコード修正結果")
        print("=" * 80)
        print(f"📊 処理ファイル数: {processed_files}")
        print(f"✅ 置換成功: {total_replaced}箇所")
        print(f"⚠️ 置換失敗: {total_failed}箇所")
        print(f"📁 バックアップ: {self.backup_dir}/")
        
        success_rate = 100 * total_replaced / (total_replaced + total_failed) if (total_replaced + total_failed) > 0 else 0
        print(f"\n成功率: {success_rate:.1f}%")
        
        # 結果を保存
        result = {
            'processed_files': processed_files,
            'total_replaced': total_replaced,
            'total_failed': total_failed,
            'success_rate': success_rate
        }
        
        with open('dart_replacement_report.json', 'w', encoding='utf-8') as f:
            json.dump(result, f, ensure_ascii=False, indent=2)
        
        print(f"\n📄 詳細レポート: dart_replacement_report.json")
        
        return result

def main():
    replacer = DartCodeReplacer()
    replacer.process_all()

if __name__ == "__main__":
    main()
