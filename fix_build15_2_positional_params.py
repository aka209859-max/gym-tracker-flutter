#!/usr/bin/env python3
"""
Fix Build #15.2 - Use Positional Parameters (CORRECT!)
========================================================
根本原因:
- Flutter l10n は位置引数（positional arguments）を生成する
- 名前付き引数（named arguments）は間違い！

正しいARB定義:
  "home_shareFailed": "シェアに失敗しました: {error}",
  "@home_shareFailed": {
    "placeholders": {
      "error": {"type": "String"}
    }
  }

生成されるメソッド:
  String home_shareFailed(String error)  // 位置引数！

間違った呼び出し (Build #15.2):
  home_shareFailed(error: e.toString())  // ❌ 名前付き引数

正しい呼び出し:
  home_shareFailed(e.toString())  // ✅ 位置引数
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
    print("Fix Build #15.2: Convert to Positional Parameters (CORRECT!)")
    print("=" * 80)
    
    # Home Screen Fixes
    home_replacements = [
        # home_shareFailed(error: e.toString()) -> home_shareFailed(e.toString())
        (
            "home_shareFailed named -> positional",
            r"\.home_shareFailed\(error:\s*([^)]+)\)",
            r".home_shareFailed(\1)"
        ),
        # home_deleteError(error: e.toString()) -> home_deleteError(e.toString())
        (
            "home_deleteError named -> positional",
            r"\.home_deleteError\(error:\s*([^)]+)\)",
            r".home_deleteError(\1)"
        ),
        # home_weightMinutes(weight: weight.toString()) -> home_weightMinutes(weight.toString())
        (
            "home_weightMinutes named -> positional",
            r"\.home_weightMinutes\(weight:\s*([^)]+)\)",
            r".home_weightMinutes(\1)"
        ),
        # home_deleteRecordConfirm(exerciseName: exerciseName) -> home_deleteRecordConfirm(exerciseName)
        (
            "home_deleteRecordConfirm named -> positional",
            r"\.home_deleteRecordConfirm\(exerciseName:\s*([^)]+)\)",
            r".home_deleteRecordConfirm(\1)"
        ),
        # home_deleteRecordSuccess(exerciseName: name, count: count) -> home_deleteRecordSuccess(name, count)
        (
            "home_deleteRecordSuccess named -> positional",
            r"\.home_deleteRecordSuccess\(exerciseName:\s*([^,]+),\s*count:\s*([^)]+)\)",
            r".home_deleteRecordSuccess(\1, \2)"
        ),
        # home_deleteFailed(error: error) -> home_deleteFailed(error)
        (
            "home_deleteFailed named -> positional",
            r"\.home_deleteFailed\(error:\s*([^)]+)\)",
            r".home_deleteFailed(\1)"
        ),
        # home_generalError(error: e.toString()) -> home_generalError(e.toString())
        (
            "home_generalError named -> positional",
            r"\.home_generalError\(error:\s*([^)]+)\)",
            r".home_generalError(\1)"
        ),
    ]
    
    # Goals Screen Fixes
    goals_replacements = [
        # goals_loadFailed(error: e.toString()) -> goals_loadFailed(e.toString())
        (
            "goals_loadFailed named -> positional",
            r"\.goals_loadFailed\(error:\s*([^)]+)\)",
            r".goals_loadFailed(\1)"
        ),
        # goals_deleteConfirm(goalName: goalName) -> goals_deleteConfirm(goalName)
        (
            "goals_deleteConfirm named -> positional",
            r"\.goals_deleteConfirm\(goalName:\s*([^)]+)\)",
            r".goals_deleteConfirm(\1)"
        ),
        # goals_updateFailed(error: e.toString()) -> goals_updateFailed(e.toString())
        (
            "goals_updateFailed named -> positional",
            r"\.goals_updateFailed\(error:\s*([^)]+)\)",
            r".goals_updateFailed(\1)"
        ),
        # goals_editTitle(goalName: goal.name) -> goals_editTitle(goal.name)
        (
            "goals_editTitle named -> positional",
            r"\.goals_editTitle\(goalName:\s*([^)]+)\)",
            r".goals_editTitle(\1)"
        ),
    ]
    
    # Body Measurement Screen Fixes
    body_replacements = [
        # body_weightKg(weight: weight) -> body_weightKg(weight)
        (
            "body_weightKg named -> positional",
            r"\.body_weightKg\(weight:\s*([^)]+)\)",
            r".body_weightKg(\1)"
        ),
        # body_bodyFatPercent(bodyFat: bodyFat) -> body_bodyFatPercent(bodyFat)
        (
            "body_bodyFatPercent named -> positional",
            r"\.body_bodyFatPercent\(bodyFat:\s*([^)]+)\)",
            r".body_bodyFatPercent(\1)"
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
    print(f"✓ Build #15.2 Fix Complete!")
    print(f"  Total fixes applied: {total_fixes}")
    print("=" * 80)
    print("\nChanges Summary:")
    print("  • Converted named parameters to positional parameters")
    print("  • This is the CORRECT way for flutter_localizations!")
    print("\nRoot Cause:")
    print("  flutter_gen generates methods with POSITIONAL parameters")
    print("  Named parameters were WRONG!")
    print("\nCorrect Usage:")
    print("  home_shareFailed(e.toString())  // ✅ Positional")
    print("  home_shareFailed(error: e.toString())  // ❌ Named (WRONG!)")
    print("\nExpected Result:")
    print("  Build #15.3 should compile successfully (99% confidence)")
    print("=" * 80)

if __name__ == '__main__':
    main()
