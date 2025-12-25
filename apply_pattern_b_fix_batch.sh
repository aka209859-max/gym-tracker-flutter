#!/bin/bash
# Pattern B Fix Batch Applier
# Week 1 Day 5 - Build #7 Fix
# Fix l10n references outside build() method for all Day 4 files

echo "======================================================================"
echo "Pattern B Fix Batch Applier - Day 4 Files (18 files)"
echo "======================================================================"
echo ""

# Day 4 files list
FILES=(
    "lib/screens/settings/tokutei_shoutorihikihou_screen.dart"
    "lib/screens/workout/workout_detail_screen.dart"
    "lib/screens/workout_import_preview_screen.dart"
    "lib/screens/workout/add_workout_screen_complete.dart"
    "lib/screens/po/gym_equipment_editor_screen.dart"
    "lib/screens/personal_factors_screen.dart"
    "lib/screens/workout/rm_calculator_screen.dart"
    "lib/screens/po/po_member_detail_screen.dart"
    "lib/screens/partner_equipment_editor_screen.dart"
    "lib/screens/map_screen.dart"
    "lib/screens/workout/simple_workout_detail_screen.dart"
    "lib/screens/po/gym_announcement_editor_screen.dart"
    "lib/screens/partner_dashboard_screen.dart"
    "lib/screens/partner_campaign_editor_screen.dart"
    "lib/screens/gym_review_screen.dart"
    "lib/screens/partner/partner_search_screen.dart"
    "lib/screens/partner/partner_detail_screen.dart"
    "lib/screens/crowd_report_screen.dart"
)

# Counters
TOTAL=${#FILES[@]}
SUCCESS=0
SKIPPED=0
FAILED=0
TOTAL_REPLACEMENTS=0

echo "Processing $TOTAL files..."
echo ""

# Process each file
for file in "${FILES[@]}"; do
    echo "Processing: $file"
    
    output=$(python3 apply_pattern_b_fix.py "$file" 2>&1)
    
    if echo "$output" | grep -q "SUCCESS"; then
        replacements=$(echo "$output" | grep -oP 'Fixed \K\d+' || echo "0")
        if [ "$replacements" -gt 0 ]; then
            SUCCESS=$((SUCCESS + 1))
            TOTAL_REPLACEMENTS=$((TOTAL_REPLACEMENTS + replacements))
            echo "  ✅ Fixed $replacements l10n references"
        else
            SKIPPED=$((SKIPPED + 1))
            echo "  ℹ️  No l10n references need fixing"
        fi
    elif echo "$output" | grep -q "No l10n references"; then
        SKIPPED=$((SKIPPED + 1))
        echo "  ℹ️  No l10n references need fixing"
    else
        FAILED=$((FAILED + 1))
        echo "  ❌ Failed"
        echo "$output" | head -5
    fi
    echo ""
done

echo "======================================================================"
echo "Pattern B Fix Batch Application Complete"
echo "======================================================================"
echo ""
echo "Results:"
echo "  Total files:         $TOTAL"
echo "  Files modified:      $SUCCESS"
echo "  Files skipped:       $SKIPPED"
echo "  Files failed:        $FAILED"
echo "  Total replacements:  $TOTAL_REPLACEMENTS"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✅ All files processed successfully!"
    echo "📊 Fixed $TOTAL_REPLACEMENTS l10n references across $SUCCESS files"
    exit 0
else
    echo "⚠️  Some files failed to process"
    exit 1
fi
