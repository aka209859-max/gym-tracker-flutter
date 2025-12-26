#!/usr/bin/env python3
"""
apply_l10n_complete_fix.py - l10n. を AppLocalizations.of(context)! に一括置換

Phase 4: l10n 完全修正スクリプト
- 全 l10n. 参照を AppLocalizations.of(context)! に置換
- コメント行はスキップ
- 変更をログ出力
"""
import re
import sys
from pathlib import Path

def fix_l10n_references(file_path):
    """l10n.key を AppLocalizations.of(context)!.key に置換（安全版）"""
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    modified = False
    modified_lines_count = 0
    new_lines = []
    
    for line_num, line in enumerate(lines, 1):
        # コメント行はスキップ
        if line.strip().startswith('//'):
            new_lines.append(line)
            continue
        
        # l10n.key のパターンにマッチ（単語境界を使用）
        pattern = r'\bl10n\.(\w+)\b'
        replacement = r'AppLocalizations.of(context)!.\1'
        
        new_line = re.sub(pattern, replacement, line)
        
        if new_line != line:
            modified = True
            modified_lines_count += 1
        
        new_lines.append(new_line)
    
    if modified:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)
        return modified_lines_count
    return 0

def main():
    # lib/screens 配下の全 .dart ファイルを処理
    screens_dir = Path('lib/screens')
    if not screens_dir.exists():
        print(f"❌ Error: {screens_dir} directory not found")
        return 1
    
    dart_files = list(screens_dir.rglob('*.dart'))
    
    total_modified_files = 0
    total_modified_lines = 0
    
    print("🔧 Phase 4: l10n 完全修正開始")
    print(f"📂 対象ディレクトリ: {screens_dir}")
    print(f"📄 対象ファイル数: {len(dart_files)}")
    print()
    
    for file_path in sorted(dart_files):
        modified_lines = fix_l10n_references(file_path)
        if modified_lines > 0:
            print(f"✅ Fixed {modified_lines} lines: {file_path}")
            total_modified_files += 1
            total_modified_lines += modified_lines
        else:
            # 詳細ログはスキップ
            pass
    
    print()
    print("=" * 60)
    print(f"📊 Summary:")
    print(f"  - Files processed: {len(dart_files)}")
    print(f"  - Files modified: {total_modified_files}")
    print(f"  - Lines modified: {total_modified_lines}")
    print("=" * 60)
    
    return 0

if __name__ == '__main__':
    sys.exit(main())
