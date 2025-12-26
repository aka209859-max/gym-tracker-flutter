#!/usr/bin/env python3
"""
Week 2 Day 1 - Smart Pattern A replacement using ARB mappings
Automatically finds best matching ARB keys for Japanese strings
"""

import re
import json
import sys
from difflib import SequenceMatcher

def load_arb_mappings(filepath='arb_key_mappings.json'):
    """Load ARB key mappings"""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)

def similarity(a, b):
    """Calculate similarity ratio between two strings"""
    return SequenceMatcher(None, a, b).ratio()

def find_best_arb_key(japanese_string, mappings, min_similarity=0.8):
    """Find the best matching ARB key for a Japanese string"""
    # Exact match
    if japanese_string in mappings:
        return mappings[japanese_string].get('arb_key')
    
    # Find best partial match
    best_match = None
    best_score = min_similarity
    
    for jp_str, data in mappings.items():
        score = similarity(japanese_string, jp_str)
        if score > best_score:
            best_score = score
            best_match = data.get('arb_key')
    
    return best_match

def extract_japanese_strings_from_file(file_path):
    """Extract all Japanese strings from a Dart file"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Pattern: Text('日本語文字列')
    pattern = r"Text\(['\"]([^'\"]*[ぁ-んァ-ヶ一-龯]+[^'\"]*)['\"]"
    matches = re.findall(pattern, content)
    
    return list(set(matches))  # Remove duplicates

def replace_in_file(file_path, mappings, dry_run=False):
    """Replace Japanese strings with AppLocalizations"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    replacements_made = []
    
    # Extract Japanese strings
    japanese_strings = extract_japanese_strings_from_file(file_path)
    
    print(f"\n📝 {file_path}")
    print(f"   Found {len(japanese_strings)} unique Japanese strings")
    
    for jp_str in japanese_strings:
        # Skip if already using AppLocalizations
        if 'AppLocalizations' in jp_str:
            continue
        
        # Find best ARB key
        arb_key = find_best_arb_key(jp_str, mappings)
        
        if arb_key:
            # Replace patterns
            patterns = [
                (rf"Text\(['\"]{{}}['\"]".format(re.escape(jp_str)), 
                 f"Text(AppLocalizations.of(context)!.{arb_key}"),
                (rf"content:\s*Text\(['\"]{{}}['\"]".format(re.escape(jp_str)),
                 f"content: Text(AppLocalizations.of(context)!.{arb_key}"),
                (rf"label:\s*(?:const\s+)?Text\(['\"]{{}}['\"]".format(re.escape(jp_str)),
                 f"label: Text(AppLocalizations.of(context)!.{arb_key}"),
                (rf"child:\s*(?:const\s+)?Text\(['\"]{{}}['\"]".format(re.escape(jp_str)),
                 f"child: Text(AppLocalizations.of(context)!.{arb_key}"),
            ]
            
            count = 0
            for pattern, replacement in patterns:
                content, n = re.subn(pattern, replacement, content)
                count += n
            
            if count > 0:
                replacements_made.append((jp_str, arb_key, count))
                status = "🔵 DRY-RUN" if dry_run else "✅"
                print(f"   {status} '{jp_str[:35]:35}' → {arb_key:30} ({count}x)")
        else:
            print(f"   ⚠️  No ARB key found for: '{jp_str[:50]}'")
    
    if not dry_run and content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
    
    return len(replacements_made), replacements_made

def main():
    import argparse
    parser = argparse.ArgumentParser(description='Week 2 Day 1 - Smart Pattern A Replacement')
    parser.add_argument('--dry-run', action='store_true', help='Dry run mode (no files modified)')
    parser.add_argument('--files', nargs='+', help='Specific files to process')
    args = parser.parse_args()
    
    # Default files (Top 3)
    if args.files:
        files = args.files
    else:
        files = [
            'lib/screens/workout/ai_coaching_screen_tabbed.dart',
            'lib/screens/workout/add_workout_screen.dart',
            'lib/screens/profile_screen.dart',
        ]
    
    print("🚀 Week 2 Day 1 - Smart Pattern A Replacement")
    print(f"{'🔵 DRY-RUN MODE' if args.dry_run else '✅ LIVE MODE'}\n")
    
    # Load ARB mappings
    print("📖 Loading ARB mappings...")
    mappings = load_arb_mappings()
    print(f"   Loaded {len(mappings)} mappings\n")
    
    total_replacements = 0
    all_replacements = []
    
    for file_path in files:
        try:
            count, replacements = replace_in_file(file_path, mappings, dry_run=args.dry_run)
            total_replacements += count
            all_replacements.extend(replacements)
        except FileNotFoundError:
            print(f"❌ File not found: {file_path}")
        except Exception as e:
            print(f"❌ Error processing {file_path}: {e}")
    
    print(f"\n{'='*70}")
    print(f"📊 Summary:")
    print(f"   Total files processed: {len(files)}")
    print(f"   Total replacements: {total_replacements}")
    print(f"   {'Mode: DRY-RUN (no changes made)' if args.dry_run else 'Mode: LIVE (files modified)'}")
    print(f"{'='*70}\n")
    
    if args.dry_run:
        print("💡 Run without --dry-run to apply changes")

if __name__ == "__main__":
    main()
