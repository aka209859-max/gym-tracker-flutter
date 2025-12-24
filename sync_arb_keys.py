#!/usr/bin/env python3
"""
Synchronize ARB keys - keep only common keys across all files
"""

import json
from pathlib import Path
from typing import Set

def get_keys(arb_path: Path) -> Set[str]:
    """Get all non-metadata keys from ARB file."""
    with open(arb_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    return {k for k in data.keys() if not k.startswith('@')}

def sync_arb_files():
    print("🔄 Synchronizing ARB files...")
    
    l10n_dir = Path('lib/l10n')
    arb_files = sorted(l10n_dir.glob('app_*.arb'))
    
    # Get keys from all files
    all_keys = []
    for arb_file in arb_files:
        keys = get_keys(arb_file)
        all_keys.append((arb_file.name, keys))
        print(f"   {arb_file.name}: {len(keys)} keys")
    
    # Find common keys
    common_keys = set.intersection(*[keys for _, keys in all_keys])
    print(f"\n✅ Common keys across all files: {len(common_keys)}")
    
    # Remove unique keys from each file
    total_removed = 0
    for arb_file in arb_files:
        with open(arb_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        original_count = len([k for k in data.keys() if not k.startswith('@')])
        
        # Remove keys not in common set
        keys_to_remove = []
        for key in list(data.keys()):
            if key.startswith('@'):
                continue
            if key not in common_keys:
                keys_to_remove.append(key)
        
        for key in keys_to_remove:
            if key in data:
                del data[key]
            meta_key = f'@{key}'
            if meta_key in data:
                del data[meta_key]
        
        final_count = len([k for k in data.keys() if not k.startswith('@')])
        removed = original_count - final_count
        total_removed += removed
        
        # Write back
        with open(arb_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        print(f"   {arb_file.name}: removed {removed} unique keys")
    
    print(f"\n🎯 Total unique keys removed: {total_removed}")
    print(f"✅ All ARB files now synchronized with {len(common_keys)} keys each")

if __name__ == '__main__':
    sync_arb_files()
