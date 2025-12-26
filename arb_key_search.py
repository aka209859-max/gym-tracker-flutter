#!/usr/bin/env python3
import json
import sys

# Load ARB file
with open('lib/l10n/app_ja.arb', 'r', encoding='utf-8') as f:
    arb = json.load(f)

# Search strings
search_strings = [
    "動画でAI機能解放",
    "広告を読み込んでいます...",
    "画面遷移に失敗しました",
    "保存に失敗しました",
    "有効な1RMを入力してください",
    "アップグレード",
    "設定する",
    "分析結果がありません",
]

print("🔍 Searching ARB keys for ai_coaching_screen_tabbed.dart\n")

found = {}
not_found = []

for search in search_strings:
    key_found = None
    exact_match = False
    
    # Search for exact or partial match
    for key, value in arb.items():
        if key.startswith('@'):
            continue
        
        if value == search:
            key_found = key
            exact_match = True
            break
        elif search in value or value in search:
            if not key_found:  # Keep first partial match
                key_found = (key, value)
    
    if exact_match:
        found[search] = key_found
        print(f"✅ '{search[:40]:40}' → {key_found}")
    elif key_found:
        found[search] = key_found[0]
        print(f"🟡 '{search[:40]:40}' → {key_found[0]}")
        print(f"   (ARB value: '{key_found[1][:50]}')")
    else:
        not_found.append(search)
        print(f"❌ '{search[:40]:40}' → NOT FOUND")

print(f"\n📊 Summary: {len(found)} found, {len(not_found)} not found")

# Generate mapping for replacement script
if found:
    print("\n📝 Mapping for replacement script:")
    print("MAPPINGS = {")
    for jp, key in found.items():
        if isinstance(key, tuple):
            key = key[0]
        print(f"    \"'{jp}'\": \"AppLocalizations.of(context)!.{key}\",")
    print("}")

