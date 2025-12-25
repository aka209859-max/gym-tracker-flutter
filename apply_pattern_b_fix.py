#!/usr/bin/env python3
"""
Pattern B Fix: Replace standalone l10n.arbKey with AppLocalizations.of(context)!.arbKey
Week 1 Day 5 - Build #7 Fix

Problem:
- l10n getter is defined in build() method
- But it's used in other methods (like _submitReview(), _showDialog(), etc.)
- This causes "The getter 'l10n' isn't defined" errors

Solution:
- Replace all `l10n.arbKey` with `AppLocalizations.of(context)!.arbKey`
- EXCEPT when inside the build() method
- Keep the l10n getter definition in build() for readability within that method
"""

import sys
import re
from pathlib import Path
from typing import List, Tuple


def is_inside_build_method(lines: List[str], line_idx: int) -> bool:
    """
    Check if a line is inside the build method.
    Simple heuristic: look backwards for Widget build() and check indentation.
    """
    # Find the most recent method definition before this line
    for i in range(line_idx, -1, -1):
        line = lines[i]
        # Check if we hit a build method
        if re.search(r'\s+Widget\s+build\s*\(\s*BuildContext\s+context\s*\)\s*\{', line):
            # Now check if we're still inside this method
            # by checking if we haven't closed the method yet
            build_indent = len(line) - len(line.lstrip())
            
            # Count braces to see if method is still open
            brace_count = 0
            for j in range(i, line_idx + 1):
                brace_count += lines[j].count('{') - lines[j].count('}')
            
            return brace_count > 0
        
        # If we hit another method, we're not in build
        if re.search(r'\s+(Future<\w+>|void|Widget)\s+\w+\s*\(', line) and 'build' not in line:
            return False
    
    return False


def fix_l10n_references(file_path: Path, dry_run: bool = False) -> dict:
    """
    Replace l10n.arbKey with AppLocalizations.of(context)!.arbKey
    outside of build() method.
    
    Returns:
        dict with keys: success, modified, message, details
    """
    result = {
        'success': False,
        'modified': False,
        'message': '',
        'details': {
            'replacements': 0,
            'lines_changed': [],
        }
    }
    
    try:
        # Read file
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        original_lines = lines.copy()
        replacements = 0
        lines_changed = []
        
        # Process each line
        for i, line in enumerate(lines):
            # Skip if this line doesn't have l10n.
            if 'l10n.' not in line:
                continue
            
            # Skip if this is the l10n definition line itself
            if 'final l10n = AppLocalizations.of(context)' in line:
                continue
            
            # Skip if already using AppLocalizations.of(context)
            if 'AppLocalizations.of(context)' in line:
                continue
            
            # Check if inside build method
            if is_inside_build_method(lines, i):
                continue
            
            # Replace l10n. with AppLocalizations.of(context)!.
            new_line = line.replace('l10n.', 'AppLocalizations.of(context)!.')
            
            if new_line != line:
                lines[i] = new_line
                replacements += 1
                lines_changed.append({
                    'line_number': i + 1,
                    'old': line.rstrip(),
                    'new': new_line.rstrip()
                })
        
        result['details']['replacements'] = replacements
        result['details']['lines_changed'] = lines_changed
        
        if replacements == 0:
            result['success'] = True
            result['message'] = 'No l10n references need fixing'
            return result
        
        # Write file if not dry run
        if not dry_run:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(lines)
            result['modified'] = True
        
        result['success'] = True
        result['message'] = f'Fixed {replacements} l10n references'
        
    except Exception as e:
        result['success'] = False
        result['message'] = f'Error: {str(e)}'
    
    return result


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 apply_pattern_b_fix.py <file_path> [--dry-run]")
        print("\nExample:")
        print("  python3 apply_pattern_b_fix.py lib/screens/gym_review_screen.dart --dry-run")
        sys.exit(1)
    
    file_path = Path(sys.argv[1])
    dry_run = '--dry-run' in sys.argv
    
    if not file_path.exists():
        print(f"❌ Error: File not found: {file_path}")
        sys.exit(1)
    
    print(f"\n{'='*70}")
    print(f"Pattern B Fix: Replace l10n references outside build()")
    print(f"{'='*70}")
    print(f"{'DRY RUN MODE' if dry_run else 'REAL MODE'} - {'No changes will be made' if dry_run else 'Files WILL be modified'}")
    print(f"Target: {file_path}")
    print(f"{'='*70}\n")
    
    # Apply Pattern B Fix
    result = fix_l10n_references(file_path, dry_run=dry_run)
    
    # Print results
    if result['success']:
        if result['details']['replacements'] > 0:
            print(f"✅ SUCCESS: {result['message']}")
            print(f"\nLines changed:")
            for change in result['details']['lines_changed']:
                print(f"\n  Line {change['line_number']}:")
                print(f"    OLD: {change['old']}")
                print(f"    NEW: {change['new']}")
        else:
            print(f"ℹ️  {result['message']}")
    else:
        print(f"❌ FAILED: {result['message']}")
        sys.exit(1)
    
    print(f"\n{'='*70}")
    print(f"Pattern B fix {'simulated' if dry_run else 'completed'}")
    print(f"{'='*70}\n")


if __name__ == '__main__':
    main()
