#!/bin/bash
# Restore additional broken files from fc26dba

COMMIT="fc26dba"
FILES=(
  "lib/screens/workout_import_preview_screen.dart"
  "lib/screens/profile_edit_screen.dart"
)

for file in "${FILES[@]}"; do
  echo "Restoring $file from $COMMIT..."
  git show "$COMMIT:$file" > "$file"
  if [ $? -eq 0 ]; then
    echo "✅ Successfully restored: $file"
  else
    echo "❌ Failed to restore: $file"
  fi
done

echo ""
echo "✅ Restoration complete!"
