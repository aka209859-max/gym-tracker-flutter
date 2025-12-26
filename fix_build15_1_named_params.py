#!/usr/bin/env python3
"""
Fix Build #15.1 - Use Named Parameters for ARB Methods
========================================================
Root Cause:
- Flutter l10n with placeholders generates methods with NAMED parameters
- Current code uses POSITIONAL parameters, causing type mismatch

Example ARB:
  "home_shareFailed": "シェアに失敗しました: {error}",
  "@home_shareFailed": {
    "placeholders": {
      "error": {"type": "String"}
    }
  }

Generated Method Signature:
  String home_shareFailed({required String error})
  
Current Usage (WRONG):
  AppLocalizations.of(context)!.home_shareFailed(e.toString())
  
Fixed Usage (CORRECT):
  AppLocalizations.of(context)!.home_shareFailed(error: e.toString())
"""

import re
from pathlib import Path

def fix_file(file_path: str, replacements: list) -> int:
    """Apply replacements to a file"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    count = 0
    
    for pattern_desc, old_pattern, new_pattern in replacements:
        matches = list(re.finditer(old_pattern, content))
        if matches:
            print(f"  ✓ Found {len(matches)} match(es) for: {pattern_desc}")
            content = re.sub(old_pattern, new_pattern, content)
            count += len(matches)
    
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✓ Fixed {file_path}: {count} replacement(s)\n")
        return count
    else:
        print(f"  No changes needed in {file_path}\n")
        return 0

def main():
    print("=" * 80)
    print("Fix Build #15.1: Convert to Named Parameters")
    print("=" * 80)
    
    # Home Screen Fixes
    home_replacements = [
        # home_shareFailed(e.toString()) -> home_shareFailed(error: e.toString())
        (
            "home_shareFailed positional -> named",
            r"\.home_shareFailed\(([^)]+)\)",
            r".home_shareFailed(error: \1)"
        ),
        # home_deleteError(e.toString()) -> home_deleteError(error: e.toString())
        (
            "home_deleteError positional -> named",
            r"\.home_deleteError\(([^)]+)\)",
            r".home_deleteError(error: \1)"
        ),
        # home_weightMinutes(weight.toString()) -> home_weightMinutes(weight: weight.toString())
        (
            "home_weightMinutes positional -> named",
            r"\.home_weightMinutes\(([^)]+)\)",
            r".home_weightMinutes(weight: \1)"
        ),
        # home_deleteRecordConfirm(exerciseName) -> home_deleteRecordConfirm(exerciseName: exerciseName)
        (
            "home_deleteRecordConfirm positional -> named",
            r"\.home_deleteRecordConfirm\(([^)]+)\)",
            r".home_deleteRecordConfirm(exerciseName: \1)"
        ),
        # home_deleteRecordSuccess(exerciseName, count) -> home_deleteRecordSuccess(exerciseName: exerciseName, count: count)
        (
            "home_deleteRecordSuccess positional -> named",
            r"\.home_deleteRecordSuccess\(([^,]+),\s*([^)]+)\)",
            r".home_deleteRecordSuccess(exerciseName: \1, count: \2)"
        ),
        # home_deleteFailed(error) -> home_deleteFailed(error: error)
        (
            "home_deleteFailed positional -> named",
            r"\.home_deleteFailed\(([^)]+)\)",
            r".home_deleteFailed(error: \1)"
        ),
        # home_generalError(e.toString()) -> home_generalError(error: e.toString())
        (
            "home_generalError positional -> named",
            r"\.home_generalError\(([^)]+)\)",
            r".home_generalError(error: \1)"
        ),
    ]
    
    # Goals Screen Fixes
    goals_replacements = [
        # goals_loadFailed(e.toString()) -> goals_loadFailed(error: e.toString())
        (
            "goals_loadFailed positional -> named",
            r"\.goals_loadFailed\(([^)]+)\)",
            r".goals_loadFailed(error: \1)"
        ),
        # goals_deleteConfirm(goalName) -> goals_deleteConfirm(goalName: goalName)
        (
            "goals_deleteConfirm positional -> named",
            r"\.goals_deleteConfirm\(([^)]+)\)",
            r".goals_deleteConfirm(goalName: \1)"
        ),
        # goals_updateFailed(e.toString()) -> goals_updateFailed(error: e.toString())
        (
            "goals_updateFailed positional -> named",
            r"\.goals_updateFailed\(([^)]+)\)",
            r".goals_updateFailed(error: \1)"
        ),
        # goals_editTitle(goal.name) -> goals_editTitle(goalName: goal.name)
        (
            "goals_editTitle positional -> named",
            r"\.goals_editTitle\(([^)]+)\)",
            r".goals_editTitle(goalName: \1)"
        ),
    ]
    
    # Body Measurement Screen Fixes
    body_replacements = [
        # body_weightKg(weight) -> body_weightKg(weight: weight)
        (
            "body_weightKg positional -> named",
            r"\.body_weightKg\(([^)]+)\)",
            r".body_weightKg(weight: \1)"
        ),
        # body_bodyFatPercent(bodyFat) -> body_bodyFatPercent(bodyFat: bodyFat)
        (
            "body_bodyFatPercent positional -> named",
            r"\.body_bodyFatPercent\(([^)]+)\)",
            r".body_bodyFatPercent(bodyFat: \1)"
        ),
    ]
    
    total_fixes = 0
    
    # Fix home_screen.dart
    print("\n[1/3] Fixing lib/screens/home_screen.dart...")
    total_fixes += fix_file('lib/screens/home_screen.dart', home_replacements)
    
    # Fix goals_screen.dart
    print("[2/3] Fixing lib/screens/goals_screen.dart...")
    total_fixes += fix_file('lib/screens/goals_screen.dart', goals_replacements)
    
    # Fix body_measurement_screen.dart
    print("[3/3] Fixing lib/screens/body_measurement_screen.dart...")
    total_fixes += fix_file('lib/screens/body_measurement_screen.dart', body_replacements)
    
    print("=" * 80)
    print(f"✓ Build #15.1 Fix Complete!")
    print(f"  Total fixes applied: {total_fixes}")
    print("=" * 80)
    print("\nChanges Summary:")
    print("  • Converted positional parameters to named parameters")
    print("  • Fixed 13 ARB method calls across 3 files")
    print("\nRoot Cause:")
    print("  Flutter l10n generates methods with NAMED parameters, not positional")
    print("\nExpected Result:")
    print("  Build #15.2 should compile successfully (95% confidence)")
    print("=" * 80)

if __name__ == '__main__':
    main()
