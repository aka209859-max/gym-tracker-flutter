#!/usr/bin/env python3
"""
Pattern B Auto-Applier: Add l10n getter to build methods
Week 1 Day 5 - Build #7 Fix

This script adds the missing l10n getter definition to build methods
in files where Pattern A was already applied but l10n definition is missing.

Strategy:
1. Find the build method signature: Widget build(BuildContext context) {
2. Insert immediately after the opening brace: final l10n = AppLocalizations.of(context)!;
3. Handle both State<T> classes and StatelessWidget classes
4. Skip if l10n definition already exists
"""

import sys
import re
from pathlib import Path
from typing import List, Tuple, Optional


def find_build_method(lines: List[str]) -> Optional[int]:
    """Find the line number of the build method."""
    for i, line in enumerate(lines):
        # Match: Widget build(BuildContext context) {
        if re.search(r'\s+Widget\s+build\s*\(\s*BuildContext\s+context\s*\)\s*\{', line):
            return i
    return None


def has_l10n_definition(lines: List[str], build_line: int) -> bool:
    """Check if l10n getter definition already exists near build method."""
    # Check 20 lines after build method
    search_end = min(build_line + 20, len(lines))
    for i in range(build_line, search_end):
        if 'final l10n = AppLocalizations.of(context)' in lines[i]:
            return True
    return False


def get_indentation(line: str) -> str:
    """Get the indentation (leading whitespace) of a line."""
    match = re.match(r'^(\s*)', line)
    return match.group(1) if match else ''


def add_l10n_getter(file_path: Path, dry_run: bool = False) -> dict:
    """
    Add l10n getter definition to build method.
    
    Returns:
        dict with keys: success, modified, message, details
    """
    result = {
        'success': False,
        'modified': False,
        'message': '',
        'details': {}
    }
    
    try:
        # Read file
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        original_lines = len(lines)
        
        # Find build method
        build_line = find_build_method(lines)
        if build_line is None:
            result['message'] = 'No build method found'
            result['success'] = True  # Not an error, just nothing to do
            return result
        
        # Check if l10n definition already exists
        if has_l10n_definition(lines, build_line):
            result['message'] = 'l10n getter already exists'
            result['success'] = True
            return result
        
        # Get indentation from build method line
        build_indent = get_indentation(lines[build_line])
        # l10n definition should be indented 2 more spaces
        l10n_indent = build_indent + '    '
        
        # Find where to insert l10n definition
        # Look for the first non-empty, non-comment line after build method opening
        insert_line = build_line + 1
        
        # Skip empty lines and comments immediately after build method
        while insert_line < len(lines):
            line_stripped = lines[insert_line].strip()
            if line_stripped and not line_stripped.startswith('//'):
                break
            insert_line += 1
        
        # Create the l10n definition line
        l10n_def = f"{l10n_indent}final l10n = AppLocalizations.of(context)!;\n"
        
        # Insert the line
        lines.insert(insert_line, l10n_def)
        
        # Add blank line after l10n definition if next line isn't blank
        if insert_line + 1 < len(lines) and lines[insert_line + 1].strip():
            lines.insert(insert_line + 1, '\n')
        
        result['details'] = {
            'build_method_line': build_line + 1,  # 1-indexed
            'insert_line': insert_line + 1,  # 1-indexed
            'l10n_definition': l10n_def.strip(),
            'lines_added': 1 if lines[insert_line + 1].strip() else 2,
            'original_lines': original_lines,
            'new_lines': len(lines)
        }
        
        # Write file if not dry run
        if not dry_run:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(lines)
            result['modified'] = True
        
        result['success'] = True
        result['message'] = f'Added l10n getter at line {insert_line + 1}'
        
    except Exception as e:
        result['success'] = False
        result['message'] = f'Error: {str(e)}'
    
    return result


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 apply_pattern_b.py <file_path> [--dry-run]")
        print("\nExample:")
        print("  python3 apply_pattern_b.py lib/screens/gym_review_screen.dart --dry-run")
        sys.exit(1)
    
    file_path = Path(sys.argv[1])
    dry_run = '--dry-run' in sys.argv
    
    if not file_path.exists():
        print(f"❌ Error: File not found: {file_path}")
        sys.exit(1)
    
    print(f"\n{'='*70}")
    print(f"Pattern B Auto-Applier: Add l10n getter")
    print(f"{'='*70}")
    print(f"{'DRY RUN MODE' if dry_run else 'REAL MODE'} - {'No changes will be made' if dry_run else 'Files WILL be modified'}")
    print(f"Target: {file_path}")
    print(f"{'='*70}\n")
    
    # Apply Pattern B
    result = add_l10n_getter(file_path, dry_run=dry_run)
    
    # Print results
    if result['success']:
        if result['modified']:
            print(f"✅ SUCCESS: {result['message']}")
            print(f"\nDetails:")
            for key, value in result['details'].items():
                print(f"  {key}: {value}")
        else:
            if 'already exists' in result['message']:
                print(f"ℹ️  SKIPPED: {result['message']}")
            elif 'No build method' in result['message']:
                print(f"ℹ️  SKIPPED: {result['message']}")
            else:
                print(f"✅ {result['message']}")
    else:
        print(f"❌ FAILED: {result['message']}")
        sys.exit(1)
    
    print(f"\n{'='*70}")
    print(f"Pattern B application {'simulated' if dry_run else 'completed'}")
    print(f"{'='*70}\n")


if __name__ == '__main__':
    main()
