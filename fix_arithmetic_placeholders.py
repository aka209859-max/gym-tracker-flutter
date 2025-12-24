#!/usr/bin/env python3
"""
Remove keys with arithmetic operations in ICU placeholders
"""

import json
from pathlib import Path
import re

def has_arithmetic_in_placeholder(text: str) -> tuple[bool, str]:
    """Check if text has arithmetic operations inside ICU placeholders."""
    
    # Pattern 1: {variable - variable} or {variable + variable}
    if re.search(r'\{[^}]*[\+\-\*/]\s*[a-zA-Z_]', text):
        return (True, 'Arithmetic in placeholder')
    
    # Pattern 2: {-variable} (negative number placeholder)
    if re.search(r'\{-[a-zA-Z_]', text):
        return (True, 'Negative variable in placeholder')
    
    # Pattern 3: Placeholder with non-ASCII identifier
    # ICU allows non-ASCII in messages but variable names should be ASCII
    if re.search(r'\{[^}]*[äöüÄÖÜßàáâãåçèéêëìíîïñòóôõøùúûýÿ]', text):
        return (True, 'Non-ASCII in placeholder identifier')
    
    return (False, 'OK')

def clean_arithmetic_placeholders():
    print("🔧 Removing keys with arithmetic operations in placeholders\n")
    
    l10n_dir = Path('lib/l10n')
    arb_files = sorted(l10n_dir.glob('app_*.arb'))
    
    total_removed = 0
    removed_keys_set = set()
    
    for arb_file in arb_files:
        with open(arb_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        original_count = len([k for k in data.keys() if not k.startswith('@')])
        
        keys_to_remove = []
        for key, value in list(data.items()):
            if key.startswith('@'):
                continue
            if not isinstance(value, str):
                continue
            
            has_arithmetic, reason = has_arithmetic_in_placeholder(value)
            if has_arithmetic:
                keys_to_remove.append((key, reason, value[:80]))
                removed_keys_set.add(key)
        
        # Remove problematic keys
        for key, reason, preview in keys_to_remove:
            if key in data:
                del data[key]
            meta_key = f'@{key}'
            if meta_key in data:
                del data[meta_key]
        
        final_count = len([k for k in data.keys() if not k.startswith('@')])
        removed = len(keys_to_remove)
        total_removed += removed
        
        # Write back
        with open(arb_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        print(f"✅ {arb_file.name}: {original_count} → {final_count} (removed {removed})")
        if keys_to_remove:
            for key, reason, preview in keys_to_remove:
                print(f"   - {key}: {reason}")
                print(f"     '{preview}'")
        print()
    
    print(f"🎯 Total keys removed: {total_removed}")
    print(f"📋 Unique keys removed: {len(removed_keys_set)}\n")
    
    if removed_keys_set:
        print("Removed keys list:")
        for key in sorted(removed_keys_set):
            print(f"  - {key}")

if __name__ == '__main__':
    clean_arithmetic_placeholders()
