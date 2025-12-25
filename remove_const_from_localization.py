#!/usr/bin/env python3
"""
Remove 'const' keyword from widget constructors that use AppLocalizations.

This script fixes the compile error:
"Error: Not a constant expression."

Strategy:
1. Find all lines with AppLocalizations.of(context)
2. Check if parent widget constructor has 'const'
3. Remove 'const' if found
"""

import re
import sys
from pathlib import Path

def remove_const_before_localization(content: str) -> tuple[str, int]:
    """
    Remove 'const' keyword from widget constructors that contain AppLocalizations.
    
    Returns:
        (modified_content, number_of_fixes)
    """
    lines = content.split('\n')
    fixes = 0
    
    # Pattern 1: const SnackBar/Text/etc with AppLocalizations inside
    # Example: const SnackBar(content: Text(AppLocalizations.of(context)!.key))
    pattern1 = re.compile(
        r'(\s*)(const\s+)(SnackBar|Text|AlertDialog|InputDecoration|Tab|ListTile|DropdownMenuItem|Card|Container|Column|Row|Scaffold|AppBar|TextButton|ElevatedButton|IconButton)\s*\('
    )
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # Check if this line has 'const Widget(' pattern
        match = pattern1.search(line)
        if match:
            # Look ahead to see if AppLocalizations is used in this widget
            indent = match.group(1)
            widget_name = match.group(3)
            
            # Find the closing parenthesis (simple heuristic: next 10 lines)
            widget_block = '\n'.join(lines[i:min(i+20, len(lines))])
            
            if 'AppLocalizations.of(context)' in widget_block:
                # Remove the 'const' keyword
                lines[i] = pattern1.sub(r'\1\3(', line)
                fixes += 1
                print(f"✓ Removed 'const' from {widget_name} at line {i+1}")
        
        i += 1
    
    # Pattern 2: InputDecoration with const modifier
    # Example: decoration: const InputDecoration(...)
    pattern2 = re.compile(r'(\s*decoration:\s*)(const\s+)(InputDecoration\s*\()')
    
    for i, line in enumerate(lines):
        if pattern2.search(line):
            # Check if AppLocalizations is used nearby (within next 5 lines)
            block = '\n'.join(lines[i:min(i+5, len(lines))])
            if 'AppLocalizations.of(context)' in block:
                lines[i] = pattern2.sub(r'\1\3', line)
                fixes += 1
                print(f"✓ Removed 'const' from InputDecoration at line {i+1}")
    
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
        
        modified, fixes = remove_const_before_localization(content)
        
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
    
    return 0 if total_fixes > 0 else 1

if __name__ == '__main__':
    sys.exit(main())
