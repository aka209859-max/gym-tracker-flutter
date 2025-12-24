#!/usr/bin/env python3
"""
Fix ICU MessageFormat syntax errors in ARB files.

This script fixes three critical error types:
1. Dart null-aware operators (?, ??) in variables
2. Japanese/CJK quotes around variables
3. HTML entities (&quot;, &lt;, etc.)
"""

import json
import re
import shutil
from pathlib import Path
from datetime import datetime

def backup_arb_files():
    """Create backup of current ARB files."""
    backup_dir = Path('arb_backup_before_icu_fix')
    backup_dir.mkdir(exist_ok=True)
    
    languages = ['ja', 'en', 'de', 'es', 'ko', 'zh', 'zh_TW']
    for lang in languages:
        src = Path(f'lib/l10n/app_{lang}.arb')
        if src.exists():
            dst = backup_dir / f'app_{lang}.arb'
            shutil.copy2(src, dst)
    
    print(f"✅ Backup created: {backup_dir}/")
    return backup_dir

def fix_dart_null_aware(value):
    """
    Fix Dart null-aware operators in variable references.
    
    Examples:
    - ${user?.uid ?? 'unknown'} → ${user_uid}
    - ${exercise?.name} → ${exercise_name}
    - ${gym?.id} → ${gym_id}
    """
    # Pattern: ${variable?.property ?? default}
    # Replace with simplified placeholder
    
    # First, try to extract the base variable and property
    pattern = r'\$\{(\w+)\?\.(\w+)(?:\s*\?\?\s*[^}]*)?\}'
    
    def replace_null_aware(match):
        var_name = match.group(1)
        prop_name = match.group(2)
        # Create a simple placeholder combining var and prop
        return f'${{{var_name}_{prop_name}}}'
    
    fixed = re.sub(pattern, replace_null_aware, value)
    
    # Also handle simpler cases: ${variable?.property}
    pattern2 = r'\$\{(\w+)\?\.(\w+)\}'
    fixed = re.sub(pattern2, r'${\1_\2}', fixed)
    
    # Handle ${variable?}
    pattern3 = r'\$\{(\w+)\?\}'
    fixed = re.sub(pattern3, r'${\1}', fixed)
    
    return fixed

def fix_japanese_quotes(value):
    """
    Fix Japanese/CJK quotes around or near variables.
    
    Examples:
    - 「${gym.name}」 → ${gym_name}
    - 「${template.name}」を削除 → ${template_name}を削除
    
    Strategy: Remove the quotes, keep the variable
    """
    # Pattern: 「${variable}」 or similar with any CJK quotes
    patterns = [
        (r'[「『](\$\{[^}]+\})[」』]', r'\1'),  # Remove quotes around vars
        (r'[「『]', ''),  # Remove remaining opening quotes
        (r'[」』]', ''),  # Remove remaining closing quotes
    ]
    
    fixed = value
    for pattern, replacement in patterns:
        fixed = re.sub(pattern, replacement, fixed)
    
    return fixed

def fix_html_entities(value):
    """
    Fix HTML entities in strings.
    
    Examples:
    - &quot; → "
    - &lt; → <
    - &gt; → >
    - &amp; → &
    """
    replacements = {
        '&quot;': '"',
        '&lt;': '<',
        '&gt;': '>',
        '&amp;': '&',
        '&#39;': "'",
    }
    
    fixed = value
    for entity, char in replacements.items():
        fixed = fixed.replace(entity, char)
    
    return fixed

def fix_variable_dot_notation(value):
    """
    Fix dot notation in variables (not standard ICU).
    
    Examples:
    - ${gym.name} → ${gym_name}
    - ${user.uid} → ${user_uid}
    """
    # Pattern: ${variable.property}
    pattern = r'\$\{(\w+)\.(\w+)\}'
    fixed = re.sub(pattern, r'${\1_\2}', value)
    return fixed

def fix_arb_file(arb_path):
    """Fix all ICU syntax errors in a single ARB file."""
    with open(arb_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    fixed_count = 0
    keys = [k for k in data.keys() if not k.startswith('@')]
    
    for key in keys:
        original = data[key]
        fixed = original
        
        # Apply fixes in order
        fixed = fix_dart_null_aware(fixed)
        fixed = fix_japanese_quotes(fixed)
        fixed = fix_html_entities(fixed)
        fixed = fix_variable_dot_notation(fixed)
        
        if fixed != original:
            data[key] = fixed
            fixed_count += 1
    
    # Write back to file
    with open(arb_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
    return fixed_count

def main():
    print("🔧 ICU MessageFormat Syntax Fixer")
    print("=" * 80)
    print()
    
    # Backup first
    backup_dir = backup_arb_files()
    print()
    
    # Fix all language files
    languages = ['ja', 'en', 'de', 'es', 'ko', 'zh', 'zh_TW']
    total_fixed = 0
    
    print("🔄 Fixing ARB files...")
    print("-" * 80)
    
    for lang in languages:
        arb_file = f'lib/l10n/app_{lang}.arb'
        if not Path(arb_file).exists():
            print(f"⚠️  {arb_file} not found, skipping...")
            continue
        
        fixed_count = fix_arb_file(arb_file)
        total_fixed += fixed_count
        
        status = "✅" if fixed_count > 0 else "✓"
        print(f"   {status} {lang}: {fixed_count} keys fixed")
    
    print()
    print("=" * 80)
    print(f"📊 SUMMARY")
    print("=" * 80)
    print(f"Total keys fixed: {total_fixed}")
    print(f"Backup location: {backup_dir}/")
    print()
    
    if total_fixed > 0:
        print("✅ ICU syntax errors fixed!")
        print()
        print("🎯 NEXT STEPS:")
        print("   1. Verify fixes: python3 analyze_icu_errors.py")
        print("   2. Test locally: flutter gen-l10n (if Flutter is available)")
        print("   3. Commit changes: git add lib/l10n/app_*.arb && git commit")
        print("   4. Push and trigger build: git push")
        print()
        print("⚠️  IMPORTANT: Review changes before committing!")
        print(f"   Compare: diff -u {backup_dir}/app_ja.arb lib/l10n/app_ja.arb")
    else:
        print("ℹ️  No fixes needed - files already ICU compliant")
    
    print()
    print("📝 To restore from backup if needed:")
    print(f"   cp {backup_dir}/app_*.arb lib/l10n/")

if __name__ == '__main__':
    main()
