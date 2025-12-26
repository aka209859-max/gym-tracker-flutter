#!/usr/bin/env python3
"""
Fix Build #15 Error: Add ARB placeholder metadata
"""
import json

# ARB keys that need placeholder definitions
KEYS_WITH_PLACEHOLDERS = {
    "home_shareFailed": ["error"],
    "home_deleteError": ["error"],
    "home_weightMinutes": ["weight"],
    "home_deleteRecordConfirm": ["exerciseName"],
    "home_deleteRecordSuccess": ["exerciseName", "count"],
    "home_deleteFailed": ["error"],
    "home_generalError": ["error"],
    "goals_loadFailed": ["error"],
    "goals_deleteConfirm": ["goalName"],
    "goals_updateFailed": ["error"],
    "goals_editTitle": ["goalName"],
    "body_weightKg": ["weight"],
    "body_bodyFatPercent": ["bodyFat"],
}

def add_placeholder_metadata(arb_file_path):
    """Add @key metadata for placeholders"""
    with open(arb_file_path, 'r', encoding='utf-8') as f:
        arb_data = json.load(f)
    
    modified = False
    for key, placeholders in KEYS_WITH_PLACEHOLDERS.items():
        if key in arb_data:
            metadata_key = f"@{key}"
            if metadata_key not in arb_data:
                # Add metadata
                metadata = {
                    "placeholders": {}
                }
                for placeholder in placeholders:
                    metadata["placeholders"][placeholder] = {
                        "type": "String"
                    }
                arb_data[metadata_key] = metadata
                modified = True
                print(f"  Added metadata for: {key} ({len(placeholders)} placeholders)")
    
    if modified:
        with open(arb_file_path, 'w', encoding='utf-8') as f:
            json.dump(arb_data, f, ensure_ascii=False, indent=2)
    
    return modified

def main():
    languages = [
        ("lib/l10n/app_ja.arb", "Japanese"),
        ("lib/l10n/app_en.arb", "English"),
        ("lib/l10n/app_ko.arb", "Korean"),
        ("lib/l10n/app_zh.arb", "Chinese (Simplified)"),
        ("lib/l10n/app_zh_TW.arb", "Chinese (Traditional)"),
        ("lib/l10n/app_de.arb", "German"),
        ("lib/l10n/app_es.arb", "Spanish"),
    ]
    
    print("=" * 70)
    print("Fix Build #15: Adding ARB Placeholder Metadata")
    print("=" * 70)
    print()
    
    total_modified = 0
    for file_path, lang_name in languages:
        print(f"Processing: {lang_name} ({file_path})")
        if add_placeholder_metadata(file_path):
            total_modified += 1
        else:
            print(f"  No changes needed")
        print()
    
    print("=" * 70)
    print(f"Total files modified: {total_modified}/7")
    print("=" * 70)

if __name__ == "__main__":
    main()
