#!/usr/bin/env python3
"""
Week 3 Day 6 Phase 3: calculators_screen.dart の文字列置換

対象: 5件の文字列
"""

import re

FILE_PATH = "lib/screens/calculators_screen.dart"

def apply_replacements():
    """文字列置換を適用"""
    
    with open(FILE_PATH, 'r', encoding='utf-8') as f:
        content = f.read()
    
    replacements = [
        # 1. タイトル (行17)
        (
            r"title: Text\('計算ツール'\)",
            r"title: Text(AppLocalizations.of(context)!.calculators_title)"
        ),
        # 2. エラーメッセージ (行56)
        (
            r"const SnackBar\(content: Text\('有効な重量と回数を入力してください'\)\)",
            r"SnackBar(content: Text(AppLocalizations.of(context)!.calculators_invalidInput))"
        ),
        # 3. 1RM計算機タイトル (行111-112)
        (
            r"Text\(\s*'1RM計算機',",
            r"Text(\n                        AppLocalizations.of(context)!.calculators_oneRMCalculator,"
        ),
        # 4. 1RM説明 (行122-124)
        (
            r"const Text\(\s*'1RM \(1 Rep Max\) は、1回だけ持ち上げられる最大重量です。\\n'\s*'Epley式を使用して推定1RMを計算します。',",
            r"Text(\n                    AppLocalizations.of(context)!.calculators_oneRMDescription,"
        ),
        # 5. バー重量エラー (行281)
        (
            r"SnackBar\(content: Text\('バー重量 \(\$\{_barWeight\}kg\) より大きい重量を入力してください'\)\)",
            r"SnackBar(content: Text(AppLocalizations.of(context)!.calculators_barWeightError(_barWeight)))"
        ),
    ]
    
    replaced_count = 0
    for i, (pattern, replacement) in enumerate(replacements, 1):
        new_content = re.sub(pattern, replacement, content)
        if new_content != content:
            replaced_count += 1
            print(f"✅ Pattern {i}: 置換成功")
        else:
            print(f"⚠️  Pattern {i}: マッチなし")
        content = new_content
    
    # ファイルに書き込み
    with open(FILE_PATH, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"\n🎉 Week 3 Day 6 Phase 3 - 文字列置換")
    print(f"File: {FILE_PATH}")
    print(f"Total replacements: {replaced_count}/{len(replacements)}")

if __name__ == "__main__":
    apply_replacements()
