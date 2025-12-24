#!/usr/bin/env python3
"""
🚨 NUCLEAR CLEANUP - Remove ALL problematic ARB keys
This script aggressively removes ALL keys with ANY Dart code patterns.
"""

import json
import re
from pathlib import Path
from typing import Dict, Any, List

def is_invalid_icu_message(text: str) -> tuple[bool, str]:
    """
    Check if text contains invalid ICU patterns.
    Returns (is_invalid, reason).
    """
    
    # Pattern 1: Dart string interpolation ${...}
    if '${' in text:
        return (True, 'Dart interpolation ${')
    
    # Pattern 2: Dart variables starting with $
    if re.search(r'\$[a-zA-Z_]', text):
        return (True, 'Dart variable $variable')
    
    # Pattern 3: Array/List access
    if re.search(r'\[[0-9]+\]', text) or '.length' in text or 'as List' in text:
        return (True, 'Array access/length')
    
    # Pattern 4: Method calls
    methods = ['.join(', '.split(', '.format(', '.clamp(', '.toInt(', '.trim(', '.contains(']
    for method in methods:
        if method in text:
            return (True, f'Method call {method}')
    
    # Pattern 5: Object properties
    props = ['.isEmpty', '.isNotEmpty']
    for prop in props:
        if prop in text:
            return (True, f'Property access {prop}')
    
    # Pattern 6: Comparison/conditional operators (but not inside valid ICU select/plural)
    # Allow '?' only if it's followed by '}' (valid ICU syntax)
    if re.search(r'\?\s*[^}]', text):
        return (True, 'Ternary operator')
    
    if '!=' in text or '==' in text or '<=' in text or '>=' in text:
        return (True, 'Comparison operator')
    
    if '||' in text or '&&' in text:
        return (True, 'Logical operator')
    
    # Pattern 7: Null coalescing ??
    if '??' in text:
        return (True, 'Null coalescing ??')
    
    # Pattern 8: Arithmetic with numbers
    if re.search(r'[\+\-\*\/]\s*\d', text):
        return (True, 'Arithmetic operation')
    
    # Pattern 9: Code blocks
    code_indicators = ['setState(', 'return;', 'print(', '=>', 'try {']
    for indicator in code_indicators:
        if indicator in text:
            return (True, f'Code block {indicator}')
    
    # Pattern 10: Regex patterns
    if r'(\d{' in text:
        return (True, 'Regex pattern')
    
    # Pattern 11: Force unwrap and optional chaining
    if ']!' in text or ')?' in text:
        return (True, 'Optional/force unwrap')
    
    # Pattern 12: Escaped braces (shouldn't be in ICU)
    if r'\{' in text or r'\}' in text:
        return (True, 'Escaped braces')
    
    # Pattern 13: Very long strings (likely code dumps)
    if len(text) > 500:
        return (True, f'Very long string ({len(text)} chars)')
    
    # Pattern 14: Square bracket followed by more complex access
    if re.search(r'\]\s*[\.\[]', text):
        return (True, 'Chained array/property access')
    
    return (False, 'Valid ICU format')

def clean_arb_file(arb_path: Path) -> Dict[str, Any]:
    """
    Remove ALL keys with invalid ICU patterns from ARB file.
    Returns dict with cleanup statistics.
    """
    print(f"\n🔍 Processing: {arb_path.name}")
    
    with open(arb_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    original_count = len([k for k in data.keys() if not k.startswith('@')])
    deleted_keys = []
    
    # Check every key
    keys_to_delete = []
    for key, value in list(data.items()):
        if key.startswith('@'):
            # Skip metadata keys
            continue
        
        if not isinstance(value, str):
            continue
        
        # Check for invalid patterns
        is_invalid, reason = is_invalid_icu_message(value)
        
        if is_invalid:
            keys_to_delete.append(key)
            deleted_keys.append({
                'key': key,
                'reason': reason,
                'preview': value[:80] + ('...' if len(value) > 80 else '')
            })
    
    # Delete all problematic keys and their metadata
    for key in keys_to_delete:
        if key in data:
            del data[key]
        # Also delete metadata
        meta_key = f'@{key}'
        if meta_key in data:
            del data[meta_key]
    
    final_count = len([k for k in data.keys() if not k.startswith('@')])
    deleted_count = len(keys_to_delete)
    
    # Write cleaned data back
    with open(arb_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"✅ {arb_path.name}:")
    print(f"   Original keys: {original_count}")
    print(f"   Deleted keys:  {deleted_count}")
    print(f"   Final keys:    {final_count}")
    
    if deleted_keys and deleted_count <= 10:
        print(f"\n   Deleted keys:")
        for item in deleted_keys:
            print(f"      - {item['key']}: {item['reason']}")
    elif deleted_keys:
        print(f"\n   Sample deleted keys:")
        for item in deleted_keys[:5]:
            print(f"      - {item['key']}: {item['reason']}")
            print(f"        Preview: {item['preview']}")
    
    return {
        'file': arb_path.name,
        'original': original_count,
        'deleted': deleted_count,
        'final': final_count,
        'deleted_keys': deleted_keys
    }

def main():
    print("=" * 80)
    print("🚨 NUCLEAR CLEANUP - Removing ALL Dart code from ARB files")
    print("=" * 80)
    
    l10n_dir = Path('lib/l10n')
    arb_files = sorted(l10n_dir.glob('app_*.arb'))
    
    print(f"\nFound {len(arb_files)} ARB files to process")
    
    results = []
    total_deleted = 0
    
    for arb_file in arb_files:
        result = clean_arb_file(arb_file)
        results.append(result)
        total_deleted += result['deleted']
    
    print("\n" + "=" * 80)
    print("📊 CLEANUP SUMMARY")
    print("=" * 80)
    
    for result in results:
        print(f"{result['file']}: {result['original']} → {result['final']} keys (deleted {result['deleted']})")
    
    print(f"\n🎯 Total keys deleted across all files: {total_deleted}")
    
    # Check if all files have same key count
    final_counts = [r['final'] for r in results]
    if len(set(final_counts)) == 1:
        print(f"✅ All files synchronized with {final_counts[0]} keys each")
    else:
        print(f"⚠️  Files have different key counts: {final_counts}")
        print("   Need to synchronize...")
    
    print("\n" + "=" * 80)
    print("🔴 CRITICAL WARNING")
    print("=" * 80)
    print(f"A total of {total_deleted} keys have been deleted.")
    print("These keys contained Dart code that MUST be reimplemented in Dart source code.")
    print("ARB files are for TRANSLATIONS ONLY, not business logic.")
    print("=" * 80)
    
    return results

if __name__ == '__main__':
    main()
