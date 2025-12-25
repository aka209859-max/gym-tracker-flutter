#!/bin/bash
# Restore files broken by Phase 4 auto-replacement

GOOD_COMMIT="768b631"

FILES=(
"lib/config/crowd_data_config.dart"
"lib/main.dart"
"lib/models/achievement.dart"
"lib/models/review.dart"
"lib/models/training_partner.dart"
"lib/models/workout_template.dart"
"lib/providers/locale_provider.dart"
"lib/screens/partner/partner_search_screen_new.dart"
"lib/screens/profile_edit_screen.dart"
"lib/screens/workout/ai_coaching_screen_tabbed.dart"
"lib/screens/workout/create_template_screen.dart"
"lib/screens/workout/personal_records_screen.dart"
"lib/screens/workout_import_preview_screen.dart"
"lib/services/ai_prediction_service.dart"
"lib/services/habit_formation_service.dart"
"lib/services/offline_service.dart"
"lib/services/scientific_database.dart"
"lib/services/subscription_management_service.dart"
"lib/services/trainer_workout_service.dart"
"lib/services/training_analysis_service.dart"
"lib/services/workout_import_service.dart"
"lib/utils/app_themes.dart"
)

echo "🔄 Restoring 22 files from commit $GOOD_COMMIT..."

for file in "${FILES[@]}"; do
  if git checkout "$GOOD_COMMIT" -- "$file"; then
    echo "✅ Restored: $file"
  else
    echo "❌ Failed: $file"
  fi
done

echo ""
echo "✅ Restoration complete!"
