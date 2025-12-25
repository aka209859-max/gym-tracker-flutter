#!/usr/bin/env python3
"""
COMPREHENSIVE const removal for AppLocalizations.

This script handles ALL const patterns:
1. const Widget(...) - direct const widget
2. const [...] - const lists containing AppLocalizations
3. const {...} - const maps/sets containing AppLocalizations
4. Parent widgets with const children using AppLocalizations

Strategy: If ANY descendant uses AppLocalizations, remove ALL const keywords in that subtree.
"""

import re
import sys
from pathlib import Path

def remove_all_const_with_localizations(content: str) -> tuple[str, int]:
    """
    Remove ALL const keywords from structures containing AppLocalizations.
    """
    lines = content.split('\n')
    fixes = 0
    
    # First pass: Find all lines with AppLocalizations
    localization_lines = set()
    for i, line in enumerate(lines):
        if 'AppLocalizations.of(context)' in line:
            localization_lines.add(i)
    
    if not localization_lines:
        return content, 0
    
    # Second pass: Remove const from parent structures
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # Skip if no const keyword
        if 'const ' not in line:
            i += 1
            continue
        
        # Check if this line starts a structure that contains AppLocalizations
        # Look ahead up to 50 lines to find if AppLocalizations is used
        lookahend_range = min(i + 50, len(lines))
        has_localization = any(j in localization_lines for j in range(i, lookahend_range))
        
        if has_localization:
            # Pattern 1: const [...] or const {...}
            if re.search(r'const\s*[\[{]', line):
                lines[i] = re.sub(r'(\s*)const\s*([\[{])', r'\1\2', line)
                fixes += 1
                print(f"✓ Removed 'const' from array/map at line {i+1}")
            
            # Pattern 2: const Widget(...)
            elif re.search(r'const\s+\w+\s*\(', line):
                lines[i] = re.sub(r'(\s*)const\s+(\w+\s*\()', r'\1\2', line)
                fixes += 1
                print(f"✓ Removed 'const' from widget at line {i+1}")
        
        i += 1
    
    # Third pass: Clean up any remaining 'const' before AppLocalizations lines
    for i in localization_lines:
        if i > 0 and i < len(lines):
            # Check previous lines for const declarations
            for j in range(max(0, i-5), i):
                if 'const ' in lines[j] and 'AppLocalizations' not in lines[j]:
                    # Remove const if it's a widget/list/map declaration
                    if re.search(r'const\s*[\[{]', lines[j]):
                        lines[j] = re.sub(r'(\s*)const\s*([\[{])', r'\1\2', lines[j])
                        fixes += 1
                        print(f"✓ Removed 'const' from parent structure at line {j+1}")
                    elif re.search(r'const\s+\w+\s*\(', lines[j]):
                        lines[j] = re.sub(r'(\s*)const\s+(\w+\s*\()', r'\1\2', lines[j])
                        fixes += 1
                        print(f"✓ Removed 'const' from parent widget at line {j+1}")
    
    return '\n'.join(lines), fixes

def process_file(filepath: Path) -> int:
    """Process a single Dart file."""
    try:
        content = filepath.read_text(encoding='utf-8')
        
        # Skip if no AppLocalizations usage
        if 'AppLocalizations.of(context)' not in content:
            return 0
        
        # Skip if no 'const' keyword
        if 'const ' not in content:
            return 0
        
        modified, fixes = remove_all_const_with_localizations(content)
        
        if fixes > 0:
            filepath.write_text(modified, encoding='utf-8')
            print(f"📝 Fixed {fixes} issues in {filepath}")
            return fixes
        
        return 0
        
    except Exception as e:
        print(f"❌ Error processing {filepath}: {e}", file=sys.stderr)
        return 0

def main():
    lib_dir = Path('lib')
    
    if not lib_dir.exists():
        print("Error: lib/ directory not found", file=sys.stderr)
        sys.exit(1)
    
    dart_files = list(lib_dir.rglob('*.dart'))
    print(f"🔍 Found {len(dart_files)} Dart files")
    
    total_fixes = 0
    fixed_files = 0
    
    for filepath in sorted(dart_files):
        fixes = process_file(filepath)
        if fixes > 0:
            total_fixes += fixes
            fixed_files += 1
    
    print(f"\n✅ Summary:")
    print(f"   Files processed: {len(dart_files)}")
    print(f"   Files modified: {fixed_files}")
    print(f"   Total fixes: {total_fixes}")
    
    return 0 if total_fixes >= 0 else 1

if __name__ == '__main__':
    sys.exit(main())
