#!/usr/bin/env python3
"""
🚨 NUCLEAR CLEANUP - Remove ALL problematic ARB keys
This script aggressively removes ALL keys with ANY Dart code patterns.
"""

import json
import re
from pathlib import Path
from typing import Dict, Any, List, Set

# CRITICAL: Ultra-comprehensive list of invalid ICU patterns
INVALID_PATTERNS = [
    # Dart interpolation
    r'\$\{',  # Dart string interpolation
    r'\$[a-zA-Z_]',  # Dart variables
    
    # Array/List access
    r'\[[\d\w]+\]',  # Array access [0], [i], [key]
    r'\.length',  # .length
    r'as List',  # Type casting
    
    # Method calls and properties
    r'\.join\(',
    r'\.split\(',
    r'\.format\(',
    r'\.clamp\(',
    r'\.toInt\(',
    r'\.isEmpty',
    r'\.isNotEmpty',
    r'\.contains\(',
    r'\.trim\(',
    
    # Conditional/Comparison operators
    r'\?',  # Ternary operator
    r'!=',  # Not equal
    r'==',  # Equal
    r'<=',  # Less than or equal
    r'>=',  # Greater than or equal
    r'\|\|',  # Logical OR
    r'&&',  # Logical AND
    r'??',  # Null coalescing
    
    # Arithmetic operations (outside placeholders)
    r'\+\s*\d',  # Addition with numbers
    r'-\s*\d',  # Subtraction with numbers
    r'\*\s*\d',  # Multiplication
    r'/\s*\d',  # Division
    
    # Code blocks and statements
    r'setState\(',
    r'return;',
    r'try\s*{',
    r'print\(',
    r'=>',  # Arrow function
    
    # Regular expressions
    r'\(\\d\{',  # Regex patterns
    
    # Complex nested structures
    r'\]\!',  # Force unwrap after array
    r'\)\?',  # Optional after function call
    r'\{[^}]*\[',  # Curly brace with array inside
    
    # Escaped characters that shouldn't be in ICU
    r'\\{',
    r'\\}',
    
    # Very long strings (likely Dart code dumps)
    r'.{500,}',  # Strings over 500 chars are suspicious
]

def contains_invalid_pattern(text: str) -> tuple[bool, List[str]]:
    """Check if text contains any invalid patterns."""
    found_patterns = []
    for pattern in INVALID_PATTERNS:
        if re.search(pattern, text):
            found_patterns.append(pattern)
    return (len(found_patterns) > 0, found_patterns)

def clean_arb_file(arb_path: Path) -> Dict[str, int]:
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
        is_invalid, patterns = contains_invalid_pattern(value)
        
        if is_invalid:
            keys_to_delete.append(key)
            deleted_keys.append({
                'key': key,
                'patterns': patterns,
                'preview': value[:100] + ('...' if len(value) > 100 else '')
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
    
    if deleted_keys:
        print(f"\n   Sample deleted keys:")
        for item in deleted_keys[:3]:  # Show first 3
            print(f"      - {item['key']}")
            print(f"        Patterns: {', '.join(item['patterns'][:3])}")
            print(f"        Preview: {item['preview']}")
    
    return {
        'file': arb_path.name,
        'original': original_count,
        'deleted': deleted_count,
        'final': final_count
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

if __name__ == '__main__':
    main()
