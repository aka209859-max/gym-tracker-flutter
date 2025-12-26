#!/usr/bin/env python3
"""
Week 2 Day 2 Phase 1: Replace static strings with existing ARB keys (v2)
Handles Text widgets with style parameters
"""
import re
import sys

FILES = {
    "lib/screens/workout/ai_coaching_screen.dart": [
        ("• AI機能を月10回まで使用可能", "workout_302d148c"),
        ("• 広告なしで快適に利用", "workout_18419fdb"),
        ("• 30日間無料トライアル", "workout_995040b8"),
        ("• AI機能を5回追加", "workout_940a74d8"),
        ("• 今月末まで有効", "workout_d9fd4ff4"),
        ("• いつでも追加購入可能", "workout_fdf1a277"),
    ],
    "lib/screens/goals_screen.dart": [
        ("目標タイプ", "general_654c46cb"),
    ],
    "lib/screens/body_measurement_screen.dart": [
        ("全て", "general_3582fe36"),
    ],
}

def replace_in_file(file_path, replacements):
    """Replace strings in a file, handling various Text() patterns"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        replacements_made = 0
        
        for old_string, arb_key in replacements:
            # Pattern: Text('string', ...)
            pattern = f"Text\\('{re.escape(old_string)}'(,\\s*style:|\\))"
            matches = list(re.finditer(pattern, content))
            
            if matches:
                for match in reversed(matches):  # Process from end to avoid offset issues
                    full_match = match.group(0)
                    if full_match.endswith(')'):
                        # Simple case: Text('string')
                        replacement = f"Text(AppLocalizations.of(context)!.{arb_key})"
                    else:
                        # With style: Text('string', style: ...)
                        replacement = f"Text(AppLocalizations.of(context)!.{arb_key},"
                    
                    start, end = match.span()
                    content = content[:start] + replacement + content[end:]
                    replacements_made += 1
                    print(f"  ✓ Replaced: '{old_string}' → {arb_key}")
            
            # Also handle const Text('string', ...)
            pattern_const = f"const Text\\('{re.escape(old_string)}'(,\\s*style:|\\))"
            matches_const = list(re.finditer(pattern_const, content))
            
            if matches_const:
                for match in reversed(matches_const):
                    full_match = match.group(0)
                    if full_match.endswith(')'):
                        replacement = f"Text(AppLocalizations.of(context)!.{arb_key})"
                    else:
                        replacement = f"Text(AppLocalizations.of(context)!.{arb_key},"
                    
                    start, end = match.span()
                    content = content[:start] + replacement + content[end:]
                    replacements_made += 1
                    print(f"  ✓ Replaced: 'const {old_string}' → {arb_key}")
        
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return replacements_made
        return 0
    
    except Exception as e:
        print(f"  ❌ Error processing {file_path}: {e}")
        return 0

def main():
    total_replacements = 0
    
    print("=" * 70)
    print("Week 2 Day 2 Phase 1: Remaining String Replacement (v2)")
    print("=" * 70)
    print()
    
    for file_path, replacements in FILES.items():
        print(f"Processing: {file_path}")
        count = replace_in_file(file_path, replacements)
        total_replacements += count
        print(f"  Replaced: {count}/{len(replacements)} strings")
        print()
    
    print("=" * 70)
    print(f"Total replacements: {total_replacements}")
    print("=" * 70)
    
    return 0 if total_replacements > 0 else 1

if __name__ == "__main__":
    sys.exit(main())
