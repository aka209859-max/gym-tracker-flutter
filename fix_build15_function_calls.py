#!/usr/bin/env python3
"""
Fix Build #15.1 Error: Replace .replaceAll() calls with proper function calls
for parameterized ARB keys.

Root Cause:
- ARB keys with placeholders generate functions: String Function(String)
- Cannot call .replaceAll() on a function
- Must call the function directly with arguments

Example Fix:
OLD: AppLocalizations.of(context)!.home_shareFailed.replaceAll('{error}', e.toString())
NEW: AppLocalizations.of(context)!.home_shareFailed(e.toString())
"""

import re
import os

# Mapping of ARB keys to their parameter structure
# Format: 'arb_key': (parameter_name, regex_pattern, replacement_template)
ARB_FUNCTION_FIXES = {
    # home_screen.dart errors
    'home_shareFailed': ('error', r"\.home_shareFailed\.replaceAll\('\{error\}', ([^)]+)\)", r".home_shareFailed(\1)"),
    'home_deleteError': ('error', r"\.home_deleteError\.replaceAll\('\{error\}', ([^)]+)\)", r".home_deleteError(\1)"),
    'home_weightMinutes': ('weight', r"\.home_weightMinutes\.replaceAll\('\{weight\}', ([^)]+)\)", r".home_weightMinutes(\1)"),
    'home_deleteRecordConfirm': ('exerciseName', r"\.home_deleteRecordConfirm\.replaceAll\('\{exerciseName\}', ([^)]+)\)", r".home_deleteRecordConfirm(\1)"),
    'home_deleteRecordSuccess': ('exerciseName_count', r"\.home_deleteRecordSuccess\.replaceAll\('\{exerciseName\}', ([^)]+)\)\.replaceAll\('\{count\}', ([^)]+)\)", r".home_deleteRecordSuccess(\1, \2)"),
    'home_deleteFailed': ('error', r"\.home_deleteFailed\.replaceAll\('\{error\}', ([^)]+)\)", r".home_deleteFailed(\1)"),
    'home_generalError': ('error', r"\.home_generalError\.replaceAll\('\{error\}', ([^)]+)\)", r".home_generalError(\1)"),
    
    # goals_screen.dart errors
    'goals_loadFailed': ('error', r"\.goals_loadFailed\.replaceAll\('\{error\}', ([^)]+)\)", r".goals_loadFailed(\1)"),
    'goals_deleteConfirm': ('goalName', r"\.goals_deleteConfirm\.replaceAll\('\{goalName\}', ([^)]+)\)", r".goals_deleteConfirm(\1)"),
    'goals_updateFailed': ('error', r"\.goals_updateFailed\.replaceAll\('\{error\}', ([^)]+)\)", r".goals_updateFailed(\1)"),
    'goals_editTitle': ('goalName', r"\.goals_editTitle\.replaceAll\('\{goalName\}', ([^)]+)\)", r".goals_editTitle(\1)"),
    
    # body_measurement_screen.dart errors
    'body_weightKg': ('weight', r"\.body_weightKg\.replaceAll\('\{weight\}', ([^)]+)\)", r".body_weightKg(\1)"),
    'body_bodyFatPercent': ('bodyFat', r"\.body_bodyFatPercent\.replaceAll\('\{bodyFat\}', ([^)]+)\)", r".body_bodyFatPercent(\1)"),
}

def fix_file(file_path):
    """Apply all ARB function call fixes to a file"""
    if not os.path.exists(file_path):
        print(f"⚠️  File not found: {file_path}")
        return 0
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    fix_count = 0
    
    # Apply all fixes
    for arb_key, (param_name, pattern, replacement) in ARB_FUNCTION_FIXES.items():
        matches = re.findall(pattern, content)
        if matches:
            content = re.sub(pattern, replacement, content)
            fix_count += len(matches)
            print(f"  ✓ {arb_key}: {len(matches)} fix(es)")
    
    # Write back if changes were made
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return fix_count
    
    return 0

def main():
    print("=" * 80)
    print("Build #15.1 Error Fix: ARB Function Call Corrections")
    print("=" * 80)
    
    # Files to fix
    files_to_fix = [
        'lib/screens/home_screen.dart',
        'lib/screens/goals_screen.dart',
        'lib/screens/body_measurement_screen.dart',
    ]
    
    total_fixes = 0
    
    for file_path in files_to_fix:
        print(f"\n📝 Processing: {file_path}")
        fixes = fix_file(file_path)
        total_fixes += fixes
        if fixes > 0:
            print(f"   ✅ {fixes} fix(es) applied")
        else:
            print(f"   ℹ️  No changes needed")
    
    print("\n" + "=" * 80)
    print(f"✅ Total fixes applied: {total_fixes}")
    print("=" * 80)
    
    if total_fixes > 0:
        print("\n📋 Next Steps:")
        print("1. Review changes: git diff")
        print("2. Commit: git add . && git commit -m 'fix(Week2-Day2): Fix ARB function calls'")
        print("3. Push: git push origin localization-perfect")
        print("4. Trigger Build #15.2")

if __name__ == '__main__':
    main()
