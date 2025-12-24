#!/usr/bin/env python3
"""
Analyze ICU MessageFormat syntax errors in ARB files.
Identifies problematic patterns that cause flutter gen-l10n to fail.
"""

import json
import re
from collections import defaultdict
from pathlib import Path

def analyze_icu_errors(arb_file_path):
    """Analyze a single ARB file for ICU syntax issues."""
    with open(arb_file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    errors = defaultdict(list)
    
    # Get actual keys (not metadata)
    keys = [k for k in data.keys() if not k.startswith('@')]
    
    for key in keys:
        value = data[key]
        
        # Pattern 1: Japanese quotes around variables
        if re.search(r'[「」『』].*?\$\{.*?\}.*?[「」『』]', value):
            errors['japanese_quotes_around_vars'].append({
                'key': key,
                'value': value,
                'pattern': 'Japanese quotes wrapping variables'
            })
        
        # Pattern 2: Dart null-aware operators
        if re.search(r'\$\{[^}]*\?[^}]*\}', value):
            errors['dart_null_aware'].append({
                'key': key,
                'value': value,
                'pattern': 'Dart null-aware operator (? or ??)'
            })
        
        # Pattern 3: HTML entities
        if '&quot;' in value or '&lt;' in value or '&gt;' in value or '&amp;' in value:
            errors['html_entities'].append({
                'key': key,
                'value': value,
                'pattern': 'HTML entities (&quot;, &lt;, etc.)'
            })
        
        # Pattern 4: Japanese quotes anywhere (potential issue)
        if any(char in value for char in '「」『』'):
            errors['japanese_quotes_present'].append({
                'key': key,
                'value': value,
                'pattern': 'Japanese quotes present'
            })
        
        # Pattern 5: Special symbols before/after variables
        if re.search(r'[📱🎯💪🏋️‍♀️🎉⚠️❌✅🔴🟡🟢].*?\$\{.*?\}', value):
            errors['emoji_near_vars'].append({
                'key': key,
                'value': value,
                'pattern': 'Emoji near variables (usually OK)'
            })
    
    return errors, len(keys)

def main():
    print("🔍 ICU MessageFormat Syntax Error Analysis")
    print("=" * 80)
    print()
    
    languages = ['ja', 'en', 'de', 'es', 'ko', 'zh', 'zh_TW']
    all_errors = defaultdict(lambda: defaultdict(list))
    total_keys = {}
    
    for lang in languages:
        arb_file = f'lib/l10n/app_{lang}.arb'
        if not Path(arb_file).exists():
            print(f"⚠️  {arb_file} not found, skipping...")
            continue
        
        errors, key_count = analyze_icu_errors(arb_file)
        total_keys[lang] = key_count
        
        for error_type, error_list in errors.items():
            all_errors[error_type][lang] = error_list
    
    print(f"📊 Analysis Complete!")
    print(f"   Languages analyzed: {len(total_keys)}")
    print(f"   Keys per language: {list(total_keys.values())[0] if total_keys else 0}")
    print()
    
    # Summary by error type
    print("🚨 Error Types Found:")
    print("-" * 80)
    
    error_priority = [
        ('dart_null_aware', '❌ CRITICAL: Dart null-aware operators (?, ??)'),
        ('japanese_quotes_around_vars', '❌ CRITICAL: Japanese quotes around variables'),
        ('html_entities', '⚠️  HIGH: HTML entities'),
        ('japanese_quotes_present', '⚠️  MEDIUM: Japanese quotes present'),
        ('emoji_near_vars', '✅ LOW: Emoji near variables (usually OK)')
    ]
    
    total_critical_issues = 0
    
    for error_type, description in error_priority:
        if error_type in all_errors:
            errors_by_lang = all_errors[error_type]
            total_count = sum(len(v) for v in errors_by_lang.values())
            
            print(f"\n{description}")
            print(f"   Total occurrences: {total_count}")
            
            if error_type in ['dart_null_aware', 'japanese_quotes_around_vars', 'html_entities']:
                total_critical_issues += total_count
            
            # Show breakdown by language
            for lang, error_list in sorted(errors_by_lang.items()):
                if error_list:
                    print(f"   - {lang}: {len(error_list)} cases")
            
            # Show first 3 examples
            if total_count > 0 and total_count <= 10:
                print(f"\n   Examples:")
                shown = 0
                for lang, error_list in sorted(errors_by_lang.items()):
                    for error in error_list[:3]:
                        if shown >= 3:
                            break
                        print(f"     [{lang}] {error['key']}")
                        print(f"       Value: {error['value'][:100]}{'...' if len(error['value']) > 100 else ''}")
                        shown += 1
    
    print("\n" + "=" * 80)
    print(f"📊 SUMMARY")
    print("=" * 80)
    print(f"Total CRITICAL issues: {total_critical_issues}")
    print(f"   These WILL cause flutter gen-l10n to fail!")
    print()
    
    if total_critical_issues > 0:
        print("🎯 RECOMMENDATION:")
        print("   1. Fix dart_null_aware: Remove ?, ?? operators from variables")
        print("   2. Fix japanese_quotes_around_vars: Remove quotes or escape properly")
        print("   3. Fix html_entities: Replace &quot; with \" or remove")
        print()
        print("💡 Next step: Run fix_icu_syntax.py (to be created)")
    else:
        print("✅ No critical ICU syntax errors found!")
        print("   ARB files should work with flutter gen-l10n")
    
    # Export detailed report
    report_file = 'icu_error_analysis.json'
    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump(dict(all_errors), f, indent=2, ensure_ascii=False)
    
    print(f"\n📝 Detailed report saved: {report_file}")

if __name__ == '__main__':
    main()
