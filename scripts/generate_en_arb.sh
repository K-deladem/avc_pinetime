#!/bin/bash

# Script pour générer automatiquement intl_en.arb à partir de intl_fr.arb
# avec traductions automatiques des valeurs communes

INPUT="lib/l10n/intl_fr.arb"
OUTPUT="lib/l10n/intl_en.arb"

echo "Génération de $OUTPUT à partir de $INPUT..."

# Copier le fichier FR vers EN
cp "$INPUT" "$OUTPUT"

# Remplacer le locale
sed -i '' 's/"@@locale": "fr"/"@@locale": "en"/g' "$OUTPUT"

# Traductions automatiques des mots communs
sed -i '' \
  -e 's/: "Annuler"/: "Cancel"/g' \
  -e 's/: "Enregistrer"/: "Save"/g' \
  -e 's/: "Fermer"/: "Close"/g' \
  -e 's/: "Confirmer"/: "Confirm"/g' \
  -e 's/: "Supprimer"/: "Delete"/g' \
  -e 's/: "Appliquer"/: "Apply"/g' \
  -e 's/: "Retour"/: "Back"/g' \
  -e 's/: "Suivant"/: "Next"/g' \
  -e 's/: "Terminer"/: "Finish"/g' \
  -e 's/: "Réessayer"/: "Retry"/g' \
  -e 's/: "Actualiser"/: "Refresh"/g' \
  -e 's/: "Effacer"/: "Clear"/g' \
  -e 's/: "Erreur"/: "Error"/g' \
  -e 's/: "Liste vide"/: "Empty list"/g' \
  -e 's/: "Accueil"/: "Home"/g' \
  -e 's/: "Historique"/: "History"/g' \
  -e 's/: "Profil"/: "Profile"/g' \
  -e 's/: "Paramètres"/: "Settings"/g' \
  -e 's/: "Données Historiques"/: "Historical Data"/g' \
  -e 's/: "Capteurs InfiniTime"/: "InfiniTime Sensors"/g' \
  -e 's/: "En savoir plus"/: "Learn More"/g' \
  -e 's/: "Asymétrie"/: "Asymmetry"/g' \
  -e 's/: "Niveau de Batterie"/: "Battery Level"/g' \
  -e 's/: "Objectif Équilibre"/: "Balance Goal"/g' \
  -e 's/: "Nombre de Pas"/: "Step Count"/g' \
  -e 's/: "Oublier"/: "Forget"/g' \
  -e 's/: "Firmware"/: "Firmware"/g' \
  -e 's/: "Simulateur"/: "Simulator"/g' \
  -e 's/: "Tous"/: "All"/g' \
  -e 's/: "Gauche"/: "Left"/g' \
  -e 's/: "Droite"/: "Right"/g' \
  -e 's/: "Aucune donnée disponible"/: "No data available"/g' \
  -e 's/: "Notifications"/: "Notifications"/g' \
  -e 's/: "Langue"/: "Language"/g' \
  -e 's/: "Thème"/: "Theme"/g' \
  -e 's/: "Synchronisation"/: "Synchronization"/g' \
  -e 's/: "À propos"/: "About"/g' \
  -e 's/: "Métriques"/: "Metrics"/g' \
  -e 's/: "Déconnecter"/: "Disconnect"/g' \
  -e 's/: "Reconnecter"/: "Reconnect"/g' \
  -e 's/: "Équilibre"/: "Balance"/g' \
  -e 's/: "Connecter"/: "Connect"/g' \
  -e 's/: "Installer"/: "Install"/g' \
  -e 's/: "Recharger"/: "Reload"/g' \
  "$OUTPUT"

echo "✅ Fichier $OUTPUT généré avec succès!"
echo "⚠️ Note: Certaines traductions peuvent nécessiter des ajustements manuels."
