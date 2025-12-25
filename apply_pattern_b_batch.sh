#!/bin/bash
# Pattern B Batch Applier
# Week 1 Day 5 - Build #7 Fix
# Add l10n getter to all Day 4 files

echo "======================================================================"
echo "Pattern B Batch Applier - Day 4 Files (18 files)"
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

echo "Processing $TOTAL files..."
echo ""

# Process each file
for file in "${FILES[@]}"; do
    echo "Processing: $file"
    
    if python3 apply_pattern_b.py "$file" 2>&1 | grep -q "SUCCESS\|SKIPPED"; then
        if python3 apply_pattern_b.py "$file" 2>&1 | grep -q "SUCCESS"; then
            SUCCESS=$((SUCCESS + 1))
            echo "  ✅ l10n getter added"
        else
            SKIPPED=$((SKIPPED + 1))
            echo "  ℹ️  Already has l10n or no build method"
        fi
    else
        FAILED=$((FAILED + 1))
        echo "  ❌ Failed"
    fi
    echo ""
done

echo "======================================================================"
echo "Pattern B Batch Application Complete"
echo "======================================================================"
echo ""
echo "Results:"
echo "  Total files:    $TOTAL"
echo "  Modified:       $SUCCESS"
echo "  Skipped:        $SKIPPED"
echo "  Failed:         $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✅ All files processed successfully!"
    exit 0
else
    echo "⚠️  Some files failed to process"
    exit 1
fi
