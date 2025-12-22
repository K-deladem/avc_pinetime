#!/bin/bash

# Script pour compléter toutes les traductions EN manquantes
OUTPUT="lib/l10n/intl_en.arb"

echo "Complétion des traductions anglaises dans $OUTPUT..."

# Effectuer toutes les traductions
sed -i '' \
  -e 's/: "Oublier la montre {position} ?"/: "Forget watch {position}?"/g' \
  -e 's/: "Suppression de la montre {position}..."/: "Removing watch {position}..."/g' \
  -e 's/: "Mettre à jour la montre {side}"/: "Update watch {side}"/g' \
  -e 's/: "Que souhaitez-vous mettre à jour ?"/: "What would you like to update?"/g' \
  -e 's/: "Simulateur de Données"/: "Data Simulator"/g' \
  -e 's/: "Générer 7 jours"/: "Generate 7 days"/g' \
  -e 's/: "Générer 30 jours"/: "Generate 30 days"/g' \
  -e 's/: "Gauche Dominant (70%)"/: "Left Dominant (70%)"/g' \
  -e 's/: "Droite Dominant (70%)"/: "Right Dominant (70%)"/g' \
  -e 's/: "Équilibré (50\/50)"/: "Balanced (50\/50)"/g' \
  -e 's/: "Afficher Stats"/: "Show Stats"/g' \
  -e 's/: "Supprimer Tout"/: "Delete All"/g' \
  -e 's/: "Confirmer la suppression"/: "Confirm deletion"/g' \
  -e 's/: "Erreur: {error}"/: "Error: {error}"/g' \
  -e 's/: "La date de fin doit être après la date de début"/: "End date must be after start date"/g' \
  -e 's/: "Export en cours de développement..."/: "Export in development..."/g' \
  -e 's/: "Choisir une date unique"/: "Choose a single date"/g' \
  -e 's/: "Choisir une période"/: "Choose a period"/g' \
  -e 's/: "Réinitialiser le filtre"/: "Reset filter"/g' \
  -e 's/: "Gérer nom et photo de profil"/: "Manage name and profile photo"/g' \
  -e 's/: "Recevoir des rappels quotidiens"/: "Receive daily reminders"/g' \
  -e 's/: "Paramètres Bluetooth"/: "Bluetooth Settings"/g' \
  -e 's/: "Connexion et enregistrement des données"/: "Connection and data recording"/g' \
  -e 's/: "Graphiques affichés"/: "Displayed Charts"/g' \
  -e 's/: "Choisir les graphiques à afficher"/: "Choose charts to display"/g' \
  -e 's/: "Fréquence de collecte"/: "Collection Frequency"/g' \
  -e 's/: "Objectif journalier"/: "Daily Goal"/g' \
  -e 's/: "Fréquence de vérification"/: "Check Frequency"/g' \
  -e 's/: "Montre gauche"/: "Left Watch"/g' \
  -e 's/: "Montre droite"/: "Right Watch"/g' \
  -e 's/: "Pousser la mise à jour"/: "Push Update"/g' \
  -e 's/: "Envoyer config aux montres"/: "Send config to watches"/g' \
  -e 's/: "Mettre à jour les montres"/: "Update Watches"/g' \
  -e 's/: "Installer firmware"/: "Install Firmware"/g' \
  -e 's/: "Forcer la synchronisation avec les montres"/: "Force sync with watches"/g' \
  -e 's/: "Politique de confidentialité"/: "Privacy Policy"/g' \
  -e 's/: "Contacter le support"/: "Contact Support"/g' \
  -e 's/: "Partager mes données"/: "Share My Data"/g' \
  -e 's/: "Importer des données"/: "Import Data"/g' \
  -e 's/: "Exporter mes données"/: "Export My Data"/g' \
  -e 's/: "Sauvegarder dans un fichier"/: "Save to file"/g' \
  -e 's/: "Réinitialiser les paramètres"/: "Reset Settings"/g' \
  -e 's/: "Réinitialiser toutes les configurations"/: "Reset all configurations"/g' \
  -e 's/: "Réinitialiser les données"/: "Reset Data"/g' \
  -e 's/: "Supprimer toutes les données locales"/: "Delete all local data"/g' \
  -e 's/: "Modifier le nom"/: "Edit Name"/g' \
  -e 's/: "Veuillez saisir ce code pour confirmer :"/: "Please enter this code to confirm:"/g' \
  -e 's/: "Données réinitialisées."/: "Data reset."/g' \
  -e 's/: "Erreur lors de la sélection de l'"'"'image : {error}"/: "Image selection error: {error}"/g' \
  -e 's/: "Langue de l'"'"'application"/: "Application Language"/g' \
  -e 's/: "Langue changée en {language}"/: "Language changed to {language}"/g' \
  -e 's/: "Conditions d'"'"'utilisation"/: "Terms of Use"/g' \
  -e 's/: "La politique de confidentialité sera ajoutée ici."/: "Privacy policy will be added here."/g' \
  -e 's/: "Les conditions d'"'"'utilisation seront ajoutées ici."/: "Terms of use will be added here."/g' \
  -e 's/: "Crédits"/: "Credits"/g' \
  -e 's/: "Développé par l'"'"'équipe Santé & Tech – 2025"/: "Developed by Health & Tech team – 2025"/g' \
  -e 's/: "Paramètres Bluetooth mis à jour"/: "Bluetooth settings updated"/g' \
  -e 's/: "Appliquer le profil ?"/: "Apply profile?"/g' \
  -e 's/: "Connexion expirée. Vérifiez que la montre est à proximité."/: "Connection timeout. Check that the watch is nearby."/g' \
  -e 's/: "Erreur d'"'"'initialisation: {error}"/: "Initialization error: {error}"/g' \
  -e 's/: "Permissions requises"/: "Permissions Required"/g' \
  -e 's/: "Connexion automatique à {name}..."/: "Auto-connecting to {name}..."/g' \
  -e 's/: "Veuillez patienter entre les tentatives de connexion"/: "Please wait between connection attempts"/g' \
  -e 's/: "Connexion à {name}..."/: "Connecting to {name}..."/g' \
  -e 's/: "Connexion réussie !"/: "Connection successful!"/g' \
  -e 's/: "{name} retiré des favoris"/: "{name} removed from favorites"/g' \
  -e 's/: "{name} ajouté aux favoris"/: "{name} added to favorites"/g' \
  -e 's/: "Relancer le scan"/: "Restart Scan"/g' \
  -e 's/: "Commencer le scan"/: "Start Scan"/g' \
  -e 's/: "Rechercher un dispositif"/: "Search Device"/g' \
  -e 's/: "Renommer la montre"/: "Rename Watch"/g' \
  -e 's/: "Vibration testée avec succès"/: "Vibration tested successfully"/g' \
  -e 's/: "Montre synchronisée"/: "Watch synchronized"/g' \
  -e 's/: "Batterie actuelle : {level}%"/: "Current battery: {level}%"/g' \
  -e 's/: "Vérification du firmware..."/: "Checking firmware..."/g' \
  -e 's/: "Firmware à jour."/: "Firmware up to date."/g' \
  -e 's/: "Supprimer la montre ?"/: "Delete watch?"/g' \
  -e 's/: "Cette action est définitive."/: "This action is permanent."/g' \
  -e 's/: "Montre supprimée."/: "Watch deleted."/g' \
  -e 's/: "Montre {side}"/: "Watch {side}"/g' \
  -e 's/: "Tester la vibration"/: "Test Vibration"/g' \
  -e 's/: "Mise à jour firmware"/: "Firmware Update"/g' \
  -e 's/: "Le nom ne peut pas être vide"/: "Name cannot be empty"/g' \
  -e 's/: "Profil mis à jour avec succès"/: "Profile updated successfully"/g' \
  -e 's/: "Supprimer la photo"/: "Delete Photo"/g' \
  -e 's/: "Thème mis à jour."/: "Theme updated."/g' \
  -e 's/: "Thème de l'"'"'application"/: "Application Theme"/g' \
  -e 's/: "Thème du système"/: "System Theme"/g' \
  -e 's/: "Thème clair"/: "Light Theme"/g' \
  -e 's/: "Thème sombre"/: "Dark Theme"/g' \
  -e 's/: "Or clair"/: "Light Gold"/g' \
  -e 's/: "Or sombre"/: "Dark Gold"/g' \
  -e 's/: "Menthe claire"/: "Light Mint"/g' \
  -e 's/: "Menthe sombre"/: "Dark Mint"/g' \
  -e 's/: "Thème expérimental"/: "Experimental Theme"/g' \
  -e 's/: "Préférences des Graphiques"/: "Chart Preferences"/g' \
  -e 's/: "Message envoyé au support."/: "Message sent to support."/g' \
  -e 's/: "Firmware pour {side}"/: "Firmware for {side}"/g' \
  -e 's/: "Chargement des firmwares..."/: "Loading firmwares..."/g' \
  -e 's/: "Aucun firmware disponible"/: "No firmware available"/g' \
  -e 's/: "Mise à jour en cours"/: "Updating"/g' \
  -e 's/: "Mise à jour terminée"/: "Update Complete"/g' \
  -e 's/: "Ne déconnectez pas la montre"/: "Do not disconnect the watch"/g' \
  -e 's/: "La mise à jour a été installée avec succès !"/: "Update installed successfully!"/g' \
  -e 's/: "Votre montre va redémarrer automatiquement."/: "Your watch will restart automatically."/g' \
  -e 's/: "Une erreur est survenue lors de la mise à jour."/: "An error occurred during the update."/g' \
  -e 's/: "Veuillez réessayer ou contacter le support."/: "Please try again or contact support."/g' \
  -e 's/: "Impossible d'"'"'annuler: {error}"/: "Cannot cancel: {error}"/g' \
  -e 's/: "Informations système"/: "System Information"/g' \
  -e 's/: "Oublier cette montre"/: "Forget This Watch"/g' \
  -e 's/: "Scanner une PineTime"/: "Scan a PineTime"/g' \
  -e 's/: "Nouveau nom"/: "New Name"/g' \
  "$OUTPUT"

echo "✅ Toutes les traductions anglaises ont été complétées!"
echo "⚠️ Exécutez maintenant: flutter pub run intl_utils:generate"
