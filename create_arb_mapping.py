#!/usr/bin/env python3
"""
ARB Key Mapping Creator
Creates a mapping from Japanese strings to ARB keys for safe localization
"""

import json
import re
import os
from pathlib import Path
from collections import defaultdict

def extract_japanese_from_dart(file_path):
    """Extract Japanese strings from a Dart file"""
    japanese_strings = []
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Pattern 1: String literals with Japanese
        # Matches: "日本語", '日本語', """日本語""", '''日本語'''
        patterns = [
            r'"([^"]*[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF]+[^"]*)"',
            r"'([^']*[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF]+[^']*)'",
        ]
        
        for pattern in patterns:
            matches = re.findall(pattern, content)
            japanese_strings.extend(matches)
            
    except Exception as e:
        print(f"⚠️  Error reading {file_path}: {e}")
        
    return list(set(japanese_strings))  # Remove duplicates

def load_arb_file(arb_path):
    """Load ARB file and return key-value pairs"""
    try:
        with open(arb_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            
        # Filter out metadata keys (starting with @)
        return {k: v for k, v in data.items() if not k.startswith('@')}
    except Exception as e:
        print(f"⚠️  Error loading ARB: {e}")
        return {}

def find_best_match(jp_string, arb_data):
    """Find the best matching ARB key for a Japanese string"""
    
    # Exact match
    for key, value in arb_data.items():
        if jp_string == value:
            return key, "exact"
            
    # Partial match (Japanese string contains ARB value or vice versa)
    for key, value in arb_data.items():
        if jp_string in value or value in jp_string:
            return key, "partial"
            
    # Contains match (at least 50% overlap)
    jp_clean = re.sub(r'\s+', '', jp_string)
    for key, value in arb_data.items():
        value_clean = re.sub(r'\s+', '', value)
        if len(jp_clean) >= 3 and len(value_clean) >= 3:
            # Check if at least 50% of characters match
            common_len = len(set(jp_clean) & set(value_clean))
            if common_len >= len(jp_clean) * 0.5 or common_len >= len(value_clean) * 0.5:
                return key, "contains"
                
    return None, "none"

def suggest_key_name(jp_string):
    """Suggest a new ARB key name based on the Japanese string"""
    # Convert to romanji-like representation (simplified)
    # This is a placeholder - in production, use a proper romanization library
    
    # For now, use a hash-based approach
    import hashlib
    hash_obj = hashlib.md5(jp_string.encode('utf-8'))
    hash_hex = hash_obj.hexdigest()[:8]
    
    # Try to extract meaning from context
    if 'ページ' in jp_string:
        prefix = 'page'
    elif 'ボタン' in jp_string:
        prefix = 'button'
    elif 'メニュー' in jp_string:
        prefix = 'menu'
    elif 'エラー' in jp_string:
        prefix = 'error'
    elif 'メッセージ' in jp_string:
        prefix = 'message'
    elif 'タイトル' in jp_string:
        prefix = 'title'
    elif 'ラベル' in jp_string:
        prefix = 'label'
    else:
        prefix = 'text'
        
    return f"NEW_{prefix}_{hash_hex}"

def create_mapping():
    """Main function to create ARB key mapping"""
    
    print("🚀 Starting ARB key mapping creation...")
    print()
    
    # Step 1: Load ARB file
    arb_path = 'lib/l10n/app_ja.arb'
    print(f"📖 Loading ARB file: {arb_path}")
    arb_data = load_arb_file(arb_path)
    print(f"✅ Loaded {len(arb_data)} ARB keys")
    print()
    
    # Step 2: Scan Dart files for Japanese strings
    print("🔍 Scanning Dart files for Japanese strings...")
    lib_path = Path('lib')
    dart_files = list(lib_path.rglob('*.dart'))
    print(f"📂 Found {len(dart_files)} Dart files")
    print()
    
    all_japanese_strings = []
    file_count = 0
    for dart_file in dart_files:
        jp_strings = extract_japanese_from_dart(dart_file)
        if jp_strings:
            all_japanese_strings.extend(jp_strings)
            file_count += 1
            
    # Remove duplicates
    all_japanese_strings = list(set(all_japanese_strings))
    print(f"✅ Found {len(all_japanese_strings)} unique Japanese strings in {file_count} files")
    print()
    
    # Step 3: Create mapping
    print("🔗 Creating mapping...")
    mapping = {}
    stats = {
        "exact": 0,
        "partial": 0,
        "contains": 0,
        "new": 0
    }
    
    for jp_string in sorted(all_japanese_strings):
        # Skip very short strings (likely not meaningful)
        if len(jp_string.strip()) < 2:
            continue
            
        # Skip strings that are mostly ASCII
        jp_char_count = len(re.findall(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF]', jp_string))
        if jp_char_count < len(jp_string) * 0.3:
            continue
            
        key, match_type = find_best_match(jp_string, arb_data)
        
        if key:
            mapping[jp_string] = {
                "key": key,
                "match_type": match_type,
                "arb_value": arb_data[key]
            }
            stats[match_type] += 1
        else:
            # Suggest new key
            new_key = suggest_key_name(jp_string)
            mapping[jp_string] = {
                "key": new_key,
                "match_type": "new",
                "arb_value": None
            }
            stats["new"] += 1
            
    print(f"✅ Created mapping for {len(mapping)} Japanese strings")
    print()
    
    # Step 4: Print statistics
    print("📊 Mapping Statistics:")
    print(f"   - Exact matches: {stats['exact']}")
    print(f"   - Partial matches: {stats['partial']}")
    print(f"   - Contains matches: {stats['contains']}")
    print(f"   - New keys needed: {stats['new']}")
    print()
    
    # Step 5: Save mapping
    output_file = 'arb_key_mappings.json'
    print(f"💾 Saving mapping to {output_file}...")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(mapping, f, ensure_ascii=False, indent=2)
        
    print(f"✅ Mapping saved ({os.path.getsize(output_file)} bytes)")
    print()
    
    # Step 6: Generate summary report
    summary_file = 'arb_mapping_summary.txt'
    with open(summary_file, 'w', encoding='utf-8') as f:
        f.write("# ARB Key Mapping Summary\n\n")
        f.write(f"Generated: 2025-12-25\n")
        f.write(f"Total Japanese strings: {len(mapping)}\n\n")
        f.write("## Statistics\n\n")
        f.write(f"- Exact matches: {stats['exact']}\n")
        f.write(f"- Partial matches: {stats['partial']}\n")
        f.write(f"- Contains matches: {stats['contains']}\n")
        f.write(f"- New keys needed: {stats['new']}\n\n")
        f.write("## Sample Mappings (First 20)\n\n")
        
        for i, (jp_str, info) in enumerate(list(mapping.items())[:20]):
            f.write(f"{i+1}. \"{jp_str}\"\n")
            f.write(f"   → {info['key']} ({info['match_type']})\n")
            if info['arb_value']:
                f.write(f"   ARB: \"{info['arb_value']}\"\n")
            f.write("\n")
            
    print(f"📄 Summary report saved to {summary_file}")
    print()
    print("🎉 ARB key mapping creation complete!")
    
    return mapping, stats

if __name__ == "__main__":
    mapping, stats = create_mapping()
