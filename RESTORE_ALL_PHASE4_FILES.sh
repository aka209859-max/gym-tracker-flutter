#!/bin/bash

# Phase 4 で破壊された全ファイルのリスト
ERROR_FILES=(
  "lib/screens/home_screen.dart"
  "lib/screens/map_screen.dart"
  "lib/screens/profile_screen.dart"
  "lib/screens/splash_screen.dart"
  "lib/screens/developer_menu_screen.dart"
  "lib/screens/personal_factors_screen.dart"
  "lib/screens/workout/add_workout_screen.dart"
  "lib/screens/workout/ai_coaching_screen_tabbed.dart"
  "lib/screens/workout/workout_log_screen.dart"
  "lib/screens/workout/workout_history_screen.dart"
  "lib/screens/workout/personal_records_screen.dart"
  "lib/screens/ai_addon_purchase_screen.dart"
  "lib/screens/body_measurement_screen.dart"
  "lib/screens/campaign/campaign_registration_screen.dart"
  "lib/screens/campaign/campaign_sns_share_screen.dart"
  "lib/screens/crowd_report_screen.dart"
  "lib/screens/favorites_screen.dart"
  "lib/screens/goals_screen.dart"
  "lib/screens/gym_detail_screen.dart"
  "lib/screens/language_settings_screen.dart"
  "lib/screens/onboarding/onboarding_screen.dart"
  "lib/screens/partner/chat_screen_partner.dart"
  "lib/screens/partner/partner_search_screen_new.dart"
  "lib/screens/personal_training/trainer_records_screen.dart"
  "lib/screens/redeem_invite_code_screen.dart"
  "lib/screens/reservation_form_screen.dart"
  "lib/screens/search_screen.dart"
  "lib/screens/settings/notification_settings_screen.dart"
  "lib/screens/settings/terms_of_service_screen.dart"
  "lib/screens/settings/tokutei_shoutorihikihou_screen.dart"
  "lib/screens/settings/trial_progress_screen.dart"
  "lib/screens/subscription_screen.dart"
  "lib/screens/visit_history_screen.dart"
  "lib/screens/workout/create_template_screen.dart"
  "lib/screens/workout/rm_calculator_screen.dart"
  "lib/screens/workout/simple_workout_detail_screen.dart"
  "lib/screens/workout/statistics_dashboard_screen.dart"
  "lib/screens/workout/template_screen.dart"
  "lib/screens/workout/weekly_reports_screen.dart"
)

echo "🔄 Phase 4 以前の状態に復元開始..."
echo "📊 対象ファイル数: ${#ERROR_FILES[@]}"

RESTORED=0
FAILED=0

for file in "${ERROR_FILES[@]}"; do
  if git checkout 768b631 -- "$file" 2>/dev/null; then
    echo "✅ $file"
    ((RESTORED++))
  else
    echo "❌ $file (not found in 768b631)"
    ((FAILED++))
  fi
done

echo ""
echo "📊 復元結果:"
echo "  ✅ 成功: $RESTORED ファイル"
echo "  ❌ 失敗: $FAILED ファイル"
echo ""
echo "🎯 次のステップ:"
echo "  git add ."
echo "  git commit -m 'fix: Restore all Phase 4 broken files from 768b631'"
echo "  git push origin localization-perfect"
