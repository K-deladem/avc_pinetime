#!/bin/bash

# Script pour corriger les imports dupliqués

echo "🔧 Correction des imports dupliqués..."

FILES=(
  "lib/ui/setting/settings_screen.dart"
  "lib/ui/history/history_screen.dart"
  "lib/ui/home/home_screen.dart"
  "lib/ui/setting/page/language_settings_page.dart"
  "lib/ui/setting/page/theme_settings_page.dart"
  "lib/ui/setting/page/profile_settings_page.dart"
  "lib/ui/setting/page/about_page.dart"
  "lib/ui/setting/page/bluetooth_settings_page.dart"
  "lib/ui/setting/page/watch_management_page.dart"
  "lib/ui/setting/page/contact_support_page.dart"
  "lib/ui/setting/page/chart_preferences_page.dart"
  "lib/ui/home/widget/firmware_selection_dialog.dart"
  "lib/ui/home/widget/firmware_update_dialog.dart"
  "lib/ui/home/widget/watch_button_card.dart"
  "lib/ui/onboarding/onboarding_screen.dart"
)

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "  📄 Nettoyage de $(basename $file)"

    # Supprimer toutes les lignes avec l10n.dart
    sed -i '' '/package:flutter_bloc_app_template\/generated\/l10n.dart/d' "$file"

    # Ajouter UNE SEULE fois après la première ligne d'import
    sed -i '' "/^import /a\\
import 'package:flutter_bloc_app_template/generated/l10n.dart';
" "$file" | head -1

    # S'assurer qu'il n'y a qu'une seule occurrence
    awk '!seen[$0]++ || !/l10n.dart/' "$file" > "$file.tmp" && mv "$file.tmp" "$file"

    echo "  ✅ Nettoyé"
  fi
done

echo ""
echo "✅ Correction terminée!"
