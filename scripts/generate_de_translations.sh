#!/bin/bash

# Script pour créer les traductions allemandes complètes
OUTPUT="lib/l10n/intl_de.arb"

echo "🇩🇪 Génération des traductions allemandes..."

# Copier la structure du fichier anglais et traduire
cat > "$OUTPUT" << 'EOF'
{
  "@@locale": "de",

  "_GENERAL": "=== ALLGEMEIN ===",
  "appTitle": "InfiniTime Companion",
  "@appTitle": {
    "description": "Der Titel der Anwendung"
  },
  "error": "Fehler",
  "@error": {},
  "emptyList": "Leere Liste",
  "@emptyList": {},
  "cancel": "Abbrechen",
  "@cancel": {},
  "ok": "OK",
  "@ok": {},
  "save": "Speichern",
  "@save": {},
  "close": "Schließen",
  "@close": {},
  "confirm": "Bestätigen",
  "@confirm": {},
  "delete": "Löschen",
  "@delete": {},
  "apply": "Anwenden",
  "@apply": {},
  "back": "Zurück",
  "@back": {},
  "next": "Weiter",
  "@next": {},
  "finish": "Fertig",
  "@finish": {},
  "retry": "Wiederholen",
  "@retry": {},
  "refresh": "Aktualisieren",
  "@refresh": {},
  "clear": "Löschen",
  "@clear": {},

  "_NAVIGATION": "=== NAVIGATION ===",
  "navHome": "Home",
  "@navHome": {},
  "navHistory": "Verlauf",
  "@navHistory": {},
  "navProfile": "Profil",
  "@navProfile": {},
  "navSettings": "Einstellungen",
  "@navSettings": {},

  "_HOME_SCREEN": "=== STARTBILDSCHIRM ===",
  "historicalData": "Historische Daten",
  "@historicalData": {},
  "infinitimeSensors": "InfiniTime-Sensoren",
  "@infinitimeSensors": {},
  "learnMore": "Mehr erfahren",
  "@learnMore": {},
  "asymmetry": "Asymmetrie",
  "@asymmetry": {},
  "batteryLevel": "Batteriestand",
  "@batteryLevel": {},
  "balanceGoal": "Gleichgewichtsziel",
  "@balanceGoal": {},
  "stepCount": "Schrittzahl",
  "@stepCount": {},
  "forgetWatchTitle": "Uhr {position} vergessen?",
  "@forgetWatchTitle": {
    "placeholders": {
      "position": {
        "type": "String"
      }
    }
  },
  "forget": "Vergessen",
  "@forget": {},
  "removingWatch": "Uhr {position} wird entfernt...",
  "@removingWatch": {
    "placeholders": {
      "position": {
        "type": "String"
      }
    }
  },
  "updateWatchTitle": "Uhr {side} aktualisieren",
  "@updateWatchTitle": {
    "placeholders": {
      "side": {
        "type": "String"
      }
    }
  },
  "whatToUpdate": "Was möchten Sie aktualisieren?",
  "@whatToUpdate": {},
  "firmware": "Firmware",
  "@firmware": {},
  "simulator": "Simulator",
  "@simulator": {},
  "dataSimulator": "Datensimulator",
  "@dataSimulator": {},
  "generate7Days": "7 Tage generieren",
  "@generate7Days": {},
  "generate30Days": "30 Tage generieren",
  "@generate30Days": {},
  "leftDominant70": "Links dominant (70%)",
  "@leftDominant70": {},
  "rightDominant70": "Rechts dominant (70%)",
  "@rightDominant70": {},
  "balanced5050": "Ausgeglichen (50/50)",
  "@balanced5050": {},
  "showStats": "Statistiken anzeigen",
  "@showStats": {},
  "deleteAll": "Alles löschen",
  "@deleteAll": {},
  "confirmDeletion": "Löschen bestätigen",
  "@confirmDeletion": {},

  "_HISTORY_SCREEN": "=== VERLAUFSBILDSCHIRM ===",
  "history": "Verlauf",
  "@history": {},
  "all": "Alle",
  "@all": {},
  "left": "Links",
  "@left": {},
  "right": "Rechts",
  "@right": {},
  "errorOccurred": "Fehler: {error}",
  "@errorOccurred": {
    "placeholders": {
      "error": {
        "type": "String"
      }
    }
  },
  "noDataAvailable": "Keine Daten verfügbar",
  "@noDataAvailable": {},
  "endDateMustBeAfterStart": "Enddatum muss nach Startdatum liegen",
  "@endDateMustBeAfterStart": {},
  "exportInDevelopment": "Export in Entwicklung...",
  "@exportInDevelopment": {},
  "chooseUniqueDate": "Einzelnes Datum wählen",
  "@chooseUniqueDate": {},
  "choosePeriod": "Zeitraum wählen",
  "@choosePeriod": {},
  "resetFilter": "Filter zurücksetzen",
  "@resetFilter": {},

  "_SETTINGS_SCREEN": "=== EINSTELLUNGSBILDSCHIRM ===",
  "settings": "Einstellungen",
  "@settings": {},
  "profile": "Profil",
  "@profile": {},
  "manageNameAndPhoto": "Name und Profilfoto verwalten",
  "@manageNameAndPhoto": {},
  "notifications": "Benachrichtigungen",
  "@notifications": {},
  "receiveDailyReminders": "Tägliche Erinnerungen erhalten",
  "@receiveDailyReminders": {},
  "language": "Sprache",
  "@language": {},
  "theme": "Design",
  "@theme": {},
  "bluetoothSettings": "Bluetooth-Einstellungen",
  "@bluetoothSettings": {},
  "connectionAndDataRecording": "Verbindung und Datenaufzeichnung",
  "@connectionAndDataRecording": {},
  "displayedCharts": "Angezeigte Diagramme",
  "@displayedCharts": {},
  "chooseChartsToDisplay": "Diagramme zum Anzeigen auswählen",
  "@chooseChartsToDisplay": {},
  "collectionFrequency": "Erfassungshäufigkeit",
  "@collectionFrequency": {},
  "dailyGoal": "Tagesziel",
  "@dailyGoal": {},
  "checkFrequency": "Überprüfungshäufigkeit",
  "@checkFrequency": {},
  "leftWatch": "Linke Uhr",
  "@leftWatch": {},
  "rightWatch": "Rechte Uhr",
  "@rightWatch": {},
  "pushUpdate": "Update übertragen",
  "@pushUpdate": {},
  "sendConfigToWatches": "Konfiguration an Uhren senden",
  "@sendConfigToWatches": {},
  "updateWatches": "Uhren aktualisieren",
  "@updateWatches": {},
  "installFirmware": "Firmware installieren",
  "@installFirmware": {},
  "synchronization": "Synchronisierung",
  "@synchronization": {},
  "forceSyncWithWatches": "Synchronisierung mit Uhren erzwingen",
  "@forceSyncWithWatches": {},
  "privacyPolicy": "Datenschutzrichtlinie",
  "@privacyPolicy": {},
  "about": "Über",
  "@about": {},
  "contactSupport": "Support kontaktieren",
  "@contactSupport": {},
  "supportEmail": "support@monapp.com",
  "@supportEmail": {},
  "shareMyData": "Meine Daten teilen",
  "@shareMyData": {},
  "importData": "Daten importieren",
  "@importData": {},
  "exportMyData": "Meine Daten exportieren",
  "@exportMyData": {},
  "saveToFile": "In Datei speichern",
  "@saveToFile": {},
  "resetSettings": "Einstellungen zurücksetzen",
  "@resetSettings": {},
  "resetAllConfigurations": "Alle Konfigurationen zurücksetzen",
  "@resetAllConfigurations": {},
  "resetData": "Daten zurücksetzen",
  "@resetData": {},
  "deleteAllLocalData": "Alle lokalen Daten löschen",
  "@deleteAllLocalData": {},
  "editName": "Name bearbeiten",
  "@editName": {},
  "editNameTitle": "Name bearbeiten",
  "@editNameTitle": {},
  "enterCodeToConfirm": "Bitte geben Sie diesen Code zur Bestätigung ein:",
  "@enterCodeToConfirm": {},
  "dataReset": "Daten zurückgesetzt.",
  "@dataReset": {},
  "imageSelectionError": "Bildauswahlfehler: {error}",
  "@imageSelectionError": {
    "placeholders": {
      "error": {
        "type": "String"
      }
    }
  },

  "_LANGUAGE_PAGE": "=== SPRACHSEITE ===",
  "appLanguage": "Anwendungssprache",
  "@appLanguage": {},
  "languageChangedTo": "Sprache geändert zu {language}",
  "@languageChangedTo": {
    "placeholders": {
      "language": {
        "type": "String"
      }
    }
  },

  "_ABOUT_PAGE": "=== ÜBER-SEITE ===",
  "termsOfUse": "Nutzungsbedingungen",
  "@termsOfUse": {},
  "privacyPolicyContent": "Datenschutzrichtlinie wird hier hinzugefügt.",
  "@privacyPolicyContent": {},
  "termsOfUseContent": "Nutzungsbedingungen werden hier hinzugefügt.",
  "@termsOfUseContent": {},
  "credits": "Danksagungen",
  "@credits": {},
  "developedBy": "Entwickelt vom Health & Tech Team – 2025",
  "@developedBy": {},

  "_BLUETOOTH_PAGE": "=== BLUETOOTH-SEITE ===",
  "bluetoothSettingsUpdated": "Bluetooth-Einstellungen aktualisiert",
  "@bluetoothSettingsUpdated": {},
  "applyProfile": "Profil anwenden?",
  "@applyProfile": {},
  "connectionTimeout": "Verbindungstimeout. Überprüfen Sie, ob die Uhr in der Nähe ist.",
  "@connectionTimeout": {},
  "initializationError": "Initialisierungsfehler: {error}",
  "@initializationError": {
    "placeholders": {
      "error": {
        "type": "String"
      }
    }
  },
  "permissionsRequired": "Berechtigungen erforderlich",
  "@permissionsRequired": {},
  "settingsButton": "Einstellungen",
  "@settingsButton": {},
  "autoConnectingTo": "Automatische Verbindung zu {name}...",
  "@autoConnectingTo": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  },
  "pleaseWaitBetweenConnections": "Bitte warten Sie zwischen Verbindungsversuchen",
  "@pleaseWaitBetweenConnections": {},
  "connectingTo": "Verbinde mit {name}...",
  "@connectingTo": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  },
  "connectionSuccessful": "Verbindung erfolgreich!",
  "@connectionSuccessful": {},
  "pinetimePosition": "PineTime ({position})",
  "@pinetimePosition": {
    "placeholders": {
      "position": {
        "type": "String"
      }
    }
  },
  "removedFromFavorites": "{name} von Favoriten entfernt",
  "@removedFromFavorites": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  },
  "addedToFavorites": "{name} zu Favoriten hinzugefügt",
  "@addedToFavorites": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  },
  "connect": "Verbinden",
  "@connect": {},
  "restartScan": "Scan neu starten",
  "@restartScan": {},
  "startScan": "Scan starten",
  "@startScan": {},
  "searchDevice": "Gerät suchen",
  "@searchDevice": {},

  "_WATCH_MANAGEMENT": "=== UHRENVERWALTUNG ===",
  "renameWatch": "Uhr umbenennen",
  "@renameWatch": {},
  "vibrationTested": "Vibration erfolgreich getestet",
  "@vibrationTested": {},
  "watchSynced": "Uhr synchronisiert",
  "@watchSynced": {},
  "currentBattery": "Aktueller Batteriestand: {level}%",
  "@currentBattery": {
    "placeholders": {
      "level": {
        "type": "int"
      }
    }
  },
  "checkingFirmware": "Firmware wird überprüft...",
  "@checkingFirmware": {},
  "firmwareUpToDate": "Firmware ist aktuell.",
  "@firmwareUpToDate": {},
  "deleteWatchQuestion": "Uhr löschen?",
  "@deleteWatchQuestion": {},
  "actionIsDefinitive": "Diese Aktion ist endgültig.",
  "@actionIsDefinitive": {},
  "watchDeleted": "Uhr gelöscht.",
  "@watchDeleted": {},
  "watchLeftRight": "Uhr {side}",
  "@watchLeftRight": {
    "placeholders": {
      "side": {
        "type": "String"
      }
    }
  },
  "testVibration": "Vibration testen",
  "@testVibration": {},
  "firmwareUpdate": "Firmware-Update",
  "@firmwareUpdate": {},

  "_PROFILE_PAGE": "=== PROFILSEITE ===",
  "nameCannotBeEmpty": "Name darf nicht leer sein",
  "@nameCannotBeEmpty": {},
  "profileUpdated": "Profil erfolgreich aktualisiert",
  "@profileUpdated": {},
  "deletePhoto": "Foto löschen",
  "@deletePhoto": {},

  "_THEME_PAGE": "=== DESIGNSEITE ===",
  "themeUpdated": "Design aktualisiert.",
  "@themeUpdated": {},
  "appTheme": "Anwendungsdesign",
  "@appTheme": {},
  "systemTheme": "Systemdesign",
  "@systemTheme": {},
  "lightTheme": "Helles Design",
  "@lightTheme": {},
  "darkTheme": "Dunkles Design",
  "@darkTheme": {},
  "lightGold": "Helles Gold",
  "@lightGold": {},
  "darkGold": "Dunkles Gold",
  "@darkGold": {},
  "lightMint": "Helles Minzgrün",
  "@lightMint": {},
  "darkMint": "Dunkles Minzgrün",
  "@darkMint": {},
  "experimentalTheme": "Experimentelles Design",
  "@experimentalTheme": {},

  "_CHART_PREFERENCES": "=== DIAGRAMM-EINSTELLUNGEN ===",
  "chartPreferences": "Diagramm-Einstellungen",
  "@chartPreferences": {},

  "_CONTACT_PAGE": "=== KONTAKTSEITE ===",
  "messageSentToSupport": "Nachricht an Support gesendet.",
  "@messageSentToSupport": {},

  "_FIRMWARE_DIALOG": "=== FIRMWARE-DIALOG ===",
  "firmwareFor": "Firmware für {side}",
  "@firmwareFor": {
    "placeholders": {
      "side": {
        "type": "String"
      }
    }
  },
  "loadingFirmwares": "Firmwares werden geladen...",
  "@loadingFirmwares": {},
  "noFirmwareAvailable": "Keine Firmware verfügbar",
  "@noFirmwareAvailable": {},
  "reload": "Neu laden",
  "@reload": {},
  "install": "Installieren",
  "@install": {},
  "updating": "Aktualisierung läuft",
  "@updating": {},
  "updateComplete": "Update abgeschlossen",
  "@updateComplete": {},
  "updateFailed": "Fehler",
  "@updateFailed": {},
  "doNotDisconnectWatch": "Trennen Sie die Uhr nicht",
  "@doNotDisconnectWatch": {},
  "updateInstalledSuccessfully": "Update erfolgreich installiert!",
  "@updateInstalledSuccessfully": {},
  "watchWillRestart": "Ihre Uhr wird automatisch neu starten.",
  "@watchWillRestart": {},
  "updateErrorOccurred": "Bei der Aktualisierung ist ein Fehler aufgetreten.",
  "@updateErrorOccurred": {},
  "tryAgainOrContact": "Bitte versuchen Sie es erneut oder kontaktieren Sie den Support.",
  "@tryAgainOrContact": {},

  "_WATCH_BUTTON_CARD": "=== UHR-SCHALTFLÄCHEN-KARTE ===",
  "metrics": "Metriken",
  "@metrics": {},
  "cannotCancel": "Abbruch nicht möglich: {error}",
  "@cannotCancel": {
    "placeholders": {
      "error": {
        "type": "String"
      }
    }
  },
  "systemInformation": "Systeminformationen",
  "@systemInformation": {},
  "disconnect": "Trennen",
  "@disconnect": {},
  "reconnect": "Erneut verbinden",
  "@reconnect": {},
  "forgetThisWatch": "Diese Uhr vergessen",
  "@forgetThisWatch": {},
  "scanPineTime": "PineTime scannen",
  "@scanPineTime": {},

  "_CHART_WIDGETS": "=== DIAGRAMM-WIDGETS ===",
  "balance": "Gleichgewicht",
  "@balance": {},
  "magnitude": "Größe",
  "@magnitude": {},
  "axis": "Achse",
  "@axis": {},

  "_ONBOARDING": "=== ONBOARDING ===",
  "newName": "Neuer Name",
  "@newName": {},

  "_EMPTY_STATE": "=== LEERE ZUSTÄNDE ===",
  "sorryNoProductWishlist": "Entschuldigung, Sie haben kein Produkt in Ihrer Wunschliste",
  "@sorryNoProductWishlist": {},
  "startAdding": "Beginnen Sie mit dem Hinzufügen",
  "@startAdding": {}
}
EOF

echo "✅ Fichier allemand généré: $OUTPUT"
echo "⚠️ Exécutez maintenant: flutter pub run intl_utils:generate"
