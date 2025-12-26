#!/usr/bin/env python3
"""
Fix Build #15 Error 2: Remove const from AppLocalizations
"""
import re

files_to_fix = {
    "lib/screens/goals_screen.dart": [
        (r"label: const Text\(AppLocalizations\.of\(context\)!\.general_6b0cabf8\)", 
         "label: Text(AppLocalizations.of(context)!.general_6b0cabf8)"),
        (r"title: const Text\(AppLocalizations\.of\(context\)!\.general_fbfd31d9\)",
         "title: Text(AppLocalizations.of(context)!.general_fbfd31d9)"),
        (r"const Text\(AppLocalizations\.of\(context\)!\.general_654c46cb, TextStyle",
         "Text(AppLocalizations.of(context)!.general_654c46cb, style: TextStyle"),
        (r"child: Text\(AppLocalizations\.of\(context\)!\.general_e9b451c8\)",
         "child: Text(AppLocalizations.of(context)!.general_e9b451c8)"),
        (r"child: Text\(AppLocalizations\.of\(context\)!\.general_12bffb53\)",
         "child: Text(AppLocalizations.of(context)!.general_12bffb53)"),
        (r"const SnackBar\(content: Text\(AppLocalizations\.of\(context\)!\.general_583ed93e\)\)",
         "SnackBar(content: Text(AppLocalizations.of(context)!.general_583ed93e))"),
    ],
    "lib/screens/body_measurement_screen.dart": [
        (r"const SnackBar\(content: Text\(AppLocalizations\.of\(context\)!\.general_6d12fd22\)\)",
         "SnackBar(content: Text(AppLocalizations.of(context)!.general_6d12fd22))"),
        (r"title: const Text\(AppLocalizations\.of\(context\)!\.profileBodyWeight\)",
         "title: Text(AppLocalizations.of(context)!.profileBodyWeight)"),
        (r"Text\(AppLocalizations\.of\(context\)!\.general_3582fe36, TextStyle",
         "Text(AppLocalizations.of(context)!.general_3582fe36, style: TextStyle"),
    ],
}

def fix_file(file_path, replacements):
    """Apply regex replacements to a file"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    replacements_made = 0
    
    for pattern, replacement in replacements:
        if re.search(pattern, content):
            content = re.sub(pattern, replacement, content)
            replacements_made += 1
            print(f"  ✓ Fixed: {pattern[:50]}...")
    
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return replacements_made
    return 0

def main():
    print("=" * 70)
    print("Fix Build #15: Remove const from AppLocalizations")
    print("=" * 70)
    print()
    
    total = 0
    for file_path, replacements in files_to_fix.items():
        print(f"Processing: {file_path}")
        count = fix_file(file_path, replacements)
        total += count
        print(f"  Fixed: {count}/{len(replacements)} patterns")
        print()
    
    print("=" * 70)
    print(f"Total fixes: {total}")
    print("=" * 70)

if __name__ == "__main__":
    main()
