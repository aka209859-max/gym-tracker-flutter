#!/usr/bin/env python3
"""
GYM MATCH v1.0.318 総合チェックスクリプト
全画面・全機能の7ヶ国語対応状況とビルドエラー可能性を徹底調査
"""

import json
import re
from pathlib import Path
from collections import defaultdict

print("=" * 80)
print("🔍 GYM MATCH v1.0.318 総合チェック")
print("=" * 80)

# 1. ARBファイルの状態確認
print("\n【1】ARBファイルの状態確認")
print("-" * 80)

l10n_dir = Path('lib/l10n')
arb_files = sorted(l10n_dir.glob('app_*.arb'))

arb_data = {}
for arb_file in arb_files:
    with open(arb_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    keys = [k for k in data.keys() if not k.startswith('@')]
    arb_data[arb_file.stem] = {
        'keys': set(keys),
        'count': len(keys)
    }

print(f"✅ ARBファイル数: {len(arb_files)}")
for name, info in arb_data.items():
    print(f"   {name}: {info['count']}キー")

# キー数が統一されているか確認
key_counts = [info['count'] for info in arb_data.values()]
if len(set(key_counts)) == 1:
    print(f"✅ 全ファイル統一: {key_counts[0]}キー")
else:
    print(f"❌ キー数不一致: {key_counts}")

# 共通キーの確認
common_keys = set.intersection(*[info['keys'] for info in arb_data.values()])
print(f"✅ 共通キー数: {len(common_keys)}")

# 2. Dartファイルでの AppLocalizations 使用状況
print("\n【2】AppLocalizations使用状況")
print("-" * 80)

dart_files = list(Path('lib').rglob('*.dart'))
total_localizations_calls = 0
problematic_files = []

for dart_file in dart_files:
    with open(dart_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # AppLocalizations.of(context) パターンを検索
    matches = re.findall(r'AppLocalizations\.of\(context\)!\.\w+', content)
    if matches:
        total_localizations_calls += len(matches)
        
        # constコンテキストでの使用を検出
        if 'const' in content and 'AppLocalizations.of(context)' in content:
            # より詳細なチェック
            lines = content.split('\n')
            for i, line in enumerate(lines):
                if 'const' in line and 'AppLocalizations.of(context)' in line:
                    problematic_files.append({
                        'file': str(dart_file.relative_to(Path('lib'))),
                        'line': i + 1,
                        'content': line.strip()[:100]
                    })

print(f"✅ Dartファイル総数: {len(dart_files)}")
print(f"✅ AppLocalizations使用総数: {total_localizations_calls}")

if problematic_files:
    print(f"❌ constコンテキストでの問題: {len(problematic_files)}箇所")
    for issue in problematic_files[:5]:
        print(f"   {issue['file']}:{issue['line']}")
        print(f"      {issue['content']}")
else:
    print(f"✅ constコンテキスト問題: なし")

# 3. 削除されたARBキーへの参照チェック
print("\n【3】削除されたARBキーへの参照チェック")
print("-" * 80)

# 全Dartファイルから AppLocalizations.keyName パターンを抽出
used_keys = set()
for dart_file in dart_files:
    with open(dart_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # AppLocalizations.of(context)!.keyName パターンを抽出
    key_matches = re.findall(r'AppLocalizations\.of\(context\)!\.(\w+)', content)
    used_keys.update(key_matches)

# 削除されたキーへの参照を検出
missing_keys = used_keys - common_keys
if missing_keys:
    print(f"❌ 削除されたキーへの参照: {len(missing_keys)}個")
    for key in sorted(list(missing_keys))[:20]:
        print(f"   - {key}")
        # どのファイルで使用されているか
        for dart_file in dart_files[:3]:  # 最初の3ファイルのみチェック
            with open(dart_file, 'r', encoding='utf-8') as f:
                if f'.{key}' in f.read():
                    print(f"      使用箇所: {dart_file.relative_to(Path('lib'))}")
                    break
else:
    print(f"✅ 削除されたキーへの参照: なし")

print(f"\n使用中のARBキー総数: {len(used_keys)}")
print(f"利用可能なARBキー数: {len(common_keys)}")
print(f"カバレッジ: {len(used_keys & common_keys)}/{len(used_keys)} ({len(used_keys & common_keys)/len(used_keys)*100:.1f}%)")

# 4. ハードコードされた文字列の検出
print("\n【4】ハードコードされた日本語/英語文字列")
print("-" * 80)

hardcoded_japanese = []
hardcoded_english_ui = []

for dart_file in dart_files:
    with open(dart_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    lines = content.split('\n')
    for i, line in enumerate(lines):
        # 日本語を含む文字列リテラル（コメント除外）
        if not line.strip().startswith('//') and not line.strip().startswith('*'):
            if re.search(r'[\"\'](.*?[ぁ-ん][^\"\']*)["\']', line):
                hardcoded_japanese.append({
                    'file': str(dart_file.relative_to(Path('lib'))),
                    'line': i + 1
                })
            # UIテキストと思われる英語（Text(), label:, title: など）
            if re.search(r'(Text|label:|title:|hint:)\s*["\'][A-Z][^"\']{10,}["\']', line):
                if 'AppLocalizations' not in line:
                    hardcoded_english_ui.append({
                        'file': str(dart_file.relative_to(Path('lib'))),
                        'line': i + 1
                    })

print(f"⚠️  ハードコード日本語: {len(hardcoded_japanese)}箇所")
if hardcoded_japanese:
    for issue in hardcoded_japanese[:5]:
        print(f"   {issue['file']}:{issue['line']}")

print(f"⚠️  ハードコード英語UI: {len(hardcoded_english_ui)}箇所")
if hardcoded_english_ui:
    for issue in hardcoded_english_ui[:5]:
        print(f"   {issue['file']}:{issue['line']}")

# 5. 主要画面のローカライゼーション状況
print("\n【5】主要画面のローカライゼーション状況")
print("-" * 80)

key_screens = [
    'lib/screens/home_screen.dart',
    'lib/screens/auth/login_screen.dart',
    'lib/screens/workout/add_workout_screen.dart',
    'lib/screens/profile/profile_screen.dart',
    'lib/screens/workout/workout_history_screen.dart',
]

for screen_path in key_screens:
    screen = Path(screen_path)
    if screen.exists():
        with open(screen, 'r', encoding='utf-8') as f:
            content = f.read()
        
        localizations = len(re.findall(r'AppLocalizations\.of\(context\)!', content))
        hardcoded_jp = len(re.findall(r'[\"\'](.*?[ぁ-ん].*?)["\']', content))
        
        status = "✅" if hardcoded_jp == 0 else "⚠️"
        print(f"{status} {screen.name}")
        print(f"   AppLocalizations: {localizations}回, ハードコード日本語: {hardcoded_jp}箇所")
    else:
        print(f"❌ {screen_path} - ファイルが見つかりません")

# 6. ビルドエラーの可能性チェック
print("\n【6】ビルドエラーの可能性")
print("-" * 80)

potential_issues = []

# 6.1 constコンテキスト問題
if problematic_files:
    potential_issues.append(f"constコンテキスト問題: {len(problematic_files)}箇所")

# 6.2 削除されたキーへの参照
if missing_keys:
    potential_issues.append(f"削除されたキーへの参照: {len(missing_keys)}個")

# 6.3 ICU構文エラーの可能性
arb_file_en = l10n_dir / 'app_en.arb'
with open(arb_file_en, 'r', encoding='utf-8') as f:
    arb_en_data = json.load(f)

icu_issues = []
for key, value in arb_en_data.items():
    if key.startswith('@'):
        continue
    if not isinstance(value, str):
        continue
    
    # ICU構文の簡易チェック
    if '${' in value:
        icu_issues.append(f"{key}: Dart interpolation '${{'")
    if re.search(r'\{[^}]*[\+\-\*/]', value):
        icu_issues.append(f"{key}: Arithmetic in placeholder")
    if value.count('{') != value.count('}'):
        icu_issues.append(f"{key}: Unbalanced braces")

if icu_issues:
    potential_issues.append(f"ICU構文問題: {len(icu_issues)}個")
    print("❌ ICU構文問題が検出されました:")
    for issue in icu_issues[:10]:
        print(f"   {issue}")

if potential_issues:
    print(f"\n❌ 潜在的なビルドエラー: {len(potential_issues)}種類")
    for issue in potential_issues:
        print(f"   - {issue}")
else:
    print(f"\n✅ 潜在的なビルドエラー: 検出なし")

# 7. 7ヶ国語対応の完全性評価
print("\n【7】7ヶ国語対応の完全性評価")
print("-" * 80)

languages = {
    'app_ja': '日本語',
    'app_en': '英語',
    'app_de': 'ドイツ語',
    'app_es': 'スペイン語',
    'app_ko': '韓国語',
    'app_zh': '中国語（簡体字）',
    'app_zh_TW': '中国語（繁体字）'
}

print(f"対応言語数: {len(languages)}")
for code, name in languages.items():
    if code in arb_data:
        print(f"✅ {name}: {arb_data[code]['count']}キー")
    else:
        print(f"❌ {name}: ファイルなし")

# 全画面・全機能の推定カバレッジ
total_ui_strings = len(used_keys)
localized_strings = len(used_keys & common_keys)
coverage = (localized_strings / total_ui_strings * 100) if total_ui_strings > 0 else 0

print(f"\n推定ローカライゼーションカバレッジ: {coverage:.1f}%")
print(f"   使用中のキー: {total_ui_strings}")
print(f"   ローカライズ済み: {localized_strings}")
print(f"   未ローカライズ: {total_ui_strings - localized_strings}")

# 最終判定
print("\n" + "=" * 80)
print("【最終判定】")
print("=" * 80)

if not potential_issues and coverage > 95:
    print("✅ ビルド成功の可能性: 高い（95%以上）")
    print("✅ 7ヶ国語対応: ほぼ完全")
elif len(potential_issues) <= 2 and coverage > 90:
    print("⚠️  ビルド成功の可能性: 中程度（軽微な問題あり）")
    print("⚠️  7ヶ国語対応: 概ね完全（一部未対応）")
else:
    print("❌ ビルド成功の可能性: 低い（重大な問題あり）")
    print("❌ 7ヶ国語対応: 不完全")

print("\n推奨アクション:")
if missing_keys:
    print("1. 削除されたARBキーへの参照を修正")
if problematic_files:
    print("2. constコンテキストでのAppLocalizations使用を修正")
if hardcoded_japanese:
    print("3. ハードコードされた日本語をローカライズ")
if not potential_issues:
    print("✅ 修正不要 - ビルド準備完了")

