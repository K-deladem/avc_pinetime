#!/bin/bash

# Script pour remplacer automatiquement les textes en dur par S.of(context)
# dans les fichiers UI les plus importants

echo "🔄 Remplacement automatique des textes en dur..."

# Liste des fichiers à traiter
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

# Fonction pour ajouter l'import S.of(context)
add_import() {
  local file=$1

  # Vérifier si l'import existe déjà
  if ! grep -q "import 'package:flutter_bloc_app_template/generated/l10n.dart';" "$file"; then
    echo "  ➕ Ajout de l'import dans $(basename $file)"

    # Trouver la dernière ligne d'import et ajouter après
    sed -i '' "/^import /a\\
import 'package:flutter_bloc_app_template/generated/l10n.dart';
" "$file"
  fi
}

# Fonction pour remplacer les textes
replace_texts() {
  local file=$1
  echo "  🔧 Remplacement des textes dans $(basename $file)"

  sed -i '' \
    -e 's/Text("Annuler")/Text(S.of(context).cancel)/g' \
    -e "s/Text('Annuler')/Text(S.of(context).cancel)/g" \
    -e 's/"Annuler"/S.of(context).cancel/g' \
    -e "s/'Annuler'/S.of(context).cancel/g" \
    -e 's/Text("Enregistrer")/Text(S.of(context).save)/g' \
    -e "s/Text('Enregistrer')/Text(S.of(context).save)/g" \
    -e 's/"Enregistrer"/S.of(context).save/g' \
    -e 's/Text("Fermer")/Text(S.of(context).close)/g' \
    -e "s/Text('Fermer')/Text(S.of(context).close)/g" \
    -e 's/"Fermer"/S.of(context).close/g' \
    -e 's/Text("OK")/Text(S.of(context).ok)/g' \
    -e 's/"OK"/S.of(context).ok/g' \
    -e 's/Text("Confirmer")/Text(S.of(context).confirm)/g' \
    -e 's/"Confirmer"/S.of(context).confirm/g' \
    -e 's/Text("Supprimer")/Text(S.of(context).delete)/g' \
    -e 's/"Supprimer"/S.of(context).delete/g' \
    -e 's/Text("Appliquer")/Text(S.of(context).apply)/g' \
    -e 's/"Appliquer"/S.of(context).apply/g' \
    -e 's/Text("Retour")/Text(S.of(context).back)/g' \
    -e 's/"Retour"/S.of(context).back/g' \
    -e 's/Text("Suivant")/Text(S.of(context).next)/g' \
    -e 's/"Suivant"/S.of(context).next/g' \
    -e 's/Text("Terminer")/Text(S.of(context).finish)/g' \
    -e 's/"Terminer"/S.of(context).finish/g' \
    -e 's/Text("Réessayer")/Text(S.of(context).retry)/g' \
    -e 's/"Réessayer"/S.of(context).retry/g' \
    -e 's/Text("Actualiser")/Text(S.of(context).refresh)/g' \
    -e 's/"Actualiser"/S.of(context).refresh/g' \
    -e 's/Text("Effacer")/Text(S.of(context).clear)/g' \
    -e 's/"Effacer"/S.of(context).clear/g' \
    -e 's/Text("Erreur")/Text(S.of(context).error)/g' \
    -e 's/"Erreur"/S.of(context).error/g' \
    -e 's/Text("Paramètres")/Text(S.of(context).settings)/g' \
    -e "s/Text('Paramètres')/Text(S.of(context).settings)/g" \
    -e 's/"Paramètres"/S.of(context).settings/g' \
    -e "s/'Paramètres'/S.of(context).settings/g" \
    -e 's/Text("Profil")/Text(S.of(context).profile)/g' \
    -e 's/"Profil"/S.of(context).profile/g' \
    -e 's/Text("Notifications")/Text(S.of(context).notifications)/g' \
    -e 's/"Notifications"/S.of(context).notifications/g' \
    -e 's/Text("Langue")/Text(S.of(context).language)/g' \
    -e 's/"Langue"/S.of(context).language/g' \
    -e 's/Text("Thème")/Text(S.of(context).theme)/g' \
    -e 's/"Thème"/S.of(context).theme/g' \
    -e 's/Text("Historique")/Text(S.of(context).history)/g' \
    -e 's/"Historique"/S.of(context).history/g' \
    -e 's/Text("Tous")/Text(S.of(context).all)/g' \
    -e 's/"Tous"/S.of(context).all/g' \
    -e 's/Text("Gauche")/Text(S.of(context).left)/g' \
    -e 's/"Gauche"/S.of(context).left/g' \
    -e 's/Text("Droite")/Text(S.of(context).right)/g' \
    -e 's/"Droite"/S.of(context).right/g' \
    -e 's/Text("Aucune donnée disponible")/Text(S.of(context).noDataAvailable)/g' \
    -e 's/"Aucune donnée disponible"/S.of(context).noDataAvailable/g' \
    -e 's/Text("Synchronisation")/Text(S.of(context).synchronization)/g' \
    -e 's/"Synchronisation"/S.of(context).synchronization/g' \
    -e 's/Text("À propos")/Text(S.of(context).about)/g' \
    -e 's/"À propos"/S.of(context).about/g' \
    -e 's/Text("Firmware")/Text(S.of(context).firmware)/g' \
    -e 's/"Firmware"/S.of(context).firmware/g' \
    -e 's/Text("Installer")/Text(S.of(context).install)/g' \
    -e 's/"Installer"/S.of(context).install/g' \
    -e 's/Text("Recharger")/Text(S.of(context).reload)/g' \
    -e 's/"Recharger"/S.of(context).reload/g' \
    -e 's/Text("Connecter")/Text(S.of(context).connect)/g' \
    -e 's/"Connecter"/S.of(context).connect/g' \
    -e 's/Text("Déconnecter")/Text(S.of(context).disconnect)/g' \
    -e 's/"Déconnecter"/S.of(context).disconnect/g' \
    -e 's/Text("Reconnecter")/Text(S.of(context).reconnect)/g' \
    -e 's/"Reconnecter"/S.of(context).reconnect/g' \
    -e 's/Text("Métriques")/Text(S.of(context).metrics)/g' \
    -e 's/"Métriques"/S.of(context).metrics/g' \
    -e 's/Text("Équilibre")/Text(S.of(context).balance)/g' \
    -e 's/"Équilibre"/S.of(context).balance/g' \
    "$file"
}

# Traiter chaque fichier
for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "📄 Traitement de $file"
    add_import "$file"
    replace_texts "$file"
    echo "  ✅ Terminé"
  else
    echo "  ⚠️  Fichier non trouvé: $file"
  fi
done

echo ""
echo "✅ Remplacement automatique terminé!"
echo "📊 Fichiers traités: ${#FILES[@]}"
echo ""
echo "⚠️  IMPORTANT: Certains textes nécessitent un remplacement manuel:"
echo "   - Textes avec paramètres (ex: 'Batterie: \$level%')"
echo "   - Titres d'AppBar dynamiques"
echo "   - Messages avec interpolation de variables"
echo ""
echo "🔍 Pour vérifier les textes restants:"
echo "   grep -r 'Text(\"' lib/ui/"
echo "   grep -r \"Text('\" lib/ui/"
