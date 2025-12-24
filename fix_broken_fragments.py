#!/usr/bin/env python3
"""
Remove broken ICU fragments - keys that start/end with broken syntax
"""

import json
from pathlib import Path

def is_broken_fragment(text: str) -> tuple[bool, str]:
    """Check if text is a broken ICU fragment."""
    
    # Check for text starting with broken syntax
    broken_starts = [
        '}',    # Starts with closing brace
        ']',    # Starts with closing bracket
        ']}',   # Starts with broken array close
        ')',    # Starts with closing paren
    ]
    
    for start in broken_starts:
        if text.startswith(start):
            return (True, f'Starts with {repr(start)}')
    
    # Check for unbalanced braces/brackets
    if text.count('{') != text.count('}'):
        return (True, 'Unbalanced braces')
    
    if text.count('[') != text.count(']'):
        return (True, 'Unbalanced brackets')
    
    # Check for ]  without matching [
    if ']' in text and '[' not in text:
        return (True, 'Closing bracket without opening')
    
    # Check for } without matching {
    if '}' in text and '{' not in text:
        return (True, 'Closing brace without opening')
    
    return (False, 'OK')

def clean_broken_fragments():
    print("🔧 Removing broken ICU fragments from ARB files\n")
    
    l10n_dir = Path('lib/l10n')
    arb_files = sorted(l10n_dir.glob('app_*.arb'))
    
    total_removed = 0
    
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
            
            is_broken, reason = is_broken_fragment(value)
            if is_broken:
                keys_to_remove.append((key, reason, value[:80]))
        
        # Remove broken keys
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
            print(f"   Removed keys:")
            for key, reason, preview in keys_to_remove[:10]:
                print(f"      - {key}: {reason}")
                print(f"        '{preview}'...")
        print()
    
    print(f"🎯 Total broken fragments removed: {total_removed}\n")

if __name__ == '__main__':
    clean_broken_fragments()
