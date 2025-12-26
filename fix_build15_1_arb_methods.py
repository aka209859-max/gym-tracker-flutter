#!/usr/bin/env python3
"""
Fix Build #15.1 Errors - ARB Method Calls
==========================================
Root Cause:
- ARB keys with placeholder metadata generate METHODS, not String properties
- Calling .replaceAll() on a method signature fails

Solution:
- Replace .replaceAll() calls with direct method invocation
- ARB methods accept named parameters matching placeholder names

Example:
  Before: AppLocalizations.of(context)!.home_shareFailed.replaceAll('{error}', e.toString())
  After:  AppLocalizations.of(context)!.home_shareFailed(e.toString())
"""

import re
from pathlib import Path

def fix_file(file_path: str, replacements: list) -> int:
    """Apply replacements to a file"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    count = 0
    
    for old_pattern, new_pattern in replacements:
        new_content, n = re.subn(old_pattern, new_pattern, content, flags=re.DOTALL)
        if n > 0:
            print(f"  ✓ Pattern matched {n} time(s): {old_pattern[:80]}...")
            content = new_content
            count += n
    
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✓ Fixed {file_path}: {count} replacement(s)")
        return count
    else:
        print(f"  No changes needed in {file_path}")
        return 0

def main():
    print("=" * 80)
    print("Fix Build #15.1: ARB Method Calls Fix")
    print("=" * 80)
    
    # Home Screen Fixes (7 patterns)
    home_replacements = [
        # home_shareFailed: single parameter 'error'
        (
            r"AppLocalizations\.of\(context\)!\.home_shareFailed\.replaceAll\('{error}',\s*([^)]+)\)",
            r"AppLocalizations.of(context)!.home_shareFailed(\1)"
        ),
        # home_deleteError: single parameter 'error'
        (
            r"AppLocalizations\.of\(context\)!\.home_deleteError\.replaceAll\('{error}',\s*([^)]+)\)",
            r"AppLocalizations.of(context)!.home_deleteError(\1)"
        ),
        # home_weightMinutes: single parameter 'weight'
        (
            r"AppLocalizations\.of\(context\)!\.home_weightMinutes\.replaceAll\('{weight}',\s*([^)]+)\)",
            r"AppLocalizations.of(context)!.home_weightMinutes(\1)"
        ),
        # home_deleteRecordConfirm: single parameter 'exerciseName'
        (
            r"AppLocalizations\.of\(context\)!\.home_deleteRecordConfirm\.replaceAll\('{exerciseName}',\s*([^)]+)\)",
            r"AppLocalizations.of(context)!.home_deleteRecordConfirm(\1)"
        ),
        # home_deleteRecordSuccess: two parameters 'exerciseName' and 'count'
        (
            r"AppLocalizations\.of\(context\)!\.home_deleteRecordSuccess\.replaceAll\('{exerciseName}',\s*([^)]+)\)\.replaceAll\('{count}',\s*([^)]+)\)",
            r"AppLocalizations.of(context)!.home_deleteRecordSuccess(\1, \2)"
        ),
        # home_deleteFailed: single parameter 'error'
        (
            r"AppLocalizations\.of\(context\)!\.home_deleteFailed\.replaceAll\('{error}',\s*([^)]+)\)",
            r"AppLocalizations.of(context)!.home_deleteFailed(\1)"
        ),
        # home_generalError: single parameter 'error'
        (
            r"AppLocalizations\.of\(context\)!\.home_generalError\.replaceAll\('{error}',\s*([^)]+)\)",
            r"AppLocalizations.of(context)!.home_generalError(\1)"
        ),
    ]
    
    # Goals Screen Fixes (4 patterns)
    goals_replacements = [
        # goals_loadFailed: single parameter 'error'
        (
            r"AppLocalizations\.of\(context\)!\.goals_loadFailed\.replaceAll\('{error}',\s*([^)]+)\)",
            r"AppLocalizations.of(context)!.goals_loadFailed(\1)"
        ),
        # goals_deleteConfirm: single parameter 'goalName'
        (
            r"AppLocalizations\.of\(context\)!\.goals_deleteConfirm\.replaceAll\('{goalName}',\s*([^)]+)\)",
            r"AppLocalizations.of(context)!.goals_deleteConfirm(\1)"
        ),
        # goals_updateFailed: single parameter 'error'
        (
            r"AppLocalizations\.of\(context\)!\.goals_updateFailed\.replaceAll\('{error}',\s*([^)]+)\)",
            r"AppLocalizations.of(context)!.goals_updateFailed(\1)"
        ),
        # goals_editTitle: single parameter 'goalName'
        (
            r"AppLocalizations\.of\(context\)!\.goals_editTitle\.replaceAll\('{goalName}',\s*([^)]+)\)",
            r"AppLocalizations.of(context)!.goals_editTitle(\1)"
        ),
    ]
    
    # Body Measurement Screen Fixes (2 patterns)
    body_replacements = [
        # body_weightKg: single parameter 'weight'
        (
            r"AppLocalizations\.of\(context\)!\.body_weightKg\.replaceAll\('{weight}',\s*([^)]+)\)",
            r"AppLocalizations.of(context)!.body_weightKg(\1)"
        ),
        # body_bodyFatPercent: single parameter 'bodyFat'
        (
            r"AppLocalizations\.of\(context\)!\.body_bodyFatPercent\.replaceAll\('{bodyFat}',\s*([^)]+)\)",
            r"AppLocalizations.of(context)!.body_bodyFatPercent(\1)"
        ),
    ]
    
    total_fixes = 0
    
    # Fix home_screen.dart
    print("\n[1/3] Fixing lib/screens/home_screen.dart...")
    total_fixes += fix_file('lib/screens/home_screen.dart', home_replacements)
    
    # Fix goals_screen.dart
    print("\n[2/3] Fixing lib/screens/goals_screen.dart...")
    total_fixes += fix_file('lib/screens/goals_screen.dart', goals_replacements)
    
    # Fix body_measurement_screen.dart
    print("\n[3/3] Fixing lib/screens/body_measurement_screen.dart...")
    total_fixes += fix_file('lib/screens/body_measurement_screen.dart', body_replacements)
    
    print("\n" + "=" * 80)
    print(f"✓ Build #15.1 Fix Complete!")
    print(f"  Total fixes applied: {total_fixes}")
    print("=" * 80)
    print("\nRoot Cause:")
    print("  ARB keys with placeholders generate METHODS, not String properties")
    print("  Methods accept named parameters matching placeholder names")
    print("\nSolution Applied:")
    print("  Replaced .replaceAll() calls with direct method invocation")
    print("\nExpected Result:")
    print("  Build #15.2 should compile successfully")
    print("=" * 80)

if __name__ == '__main__':
    main()
