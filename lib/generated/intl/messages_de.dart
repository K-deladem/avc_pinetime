// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'de';

  static String m0(name) => "${name} zu Favoriten hinzugefügt";

  static String m1(name) => "Automatische Verbindung zu ${name}...";

  static String m2(error) => "Abbruch nicht möglich: ${error}";

  static String m3(name) => "Verbinde mit ${name}...";

  static String m4(level) => "Aktueller Batteriestand: ${level}%";

  static String m5(error) => "Fehler: ${error}";

  static String m6(side) => "Firmware für ${side}";

  static String m7(position) => "Uhr ${position} vergessen?";

  static String m8(error) => "Bildauswahlfehler: ${error}";

  static String m9(error) => "Initialisierungsfehler: ${error}";

  static String m10(language) => "Sprache geändert zu ${language}";

  static String m11(position) => "PineTime (${position})";

  static String m12(name) => "${name} von Favoriten entfernt";

  static String m13(position) => "Uhr ${position} wird entfernt...";

  static String m14(side) => "Uhr ${side} aktualisieren";

  static String m15(side) => "Uhr ${side}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "_ABOUT_PAGE":
            MessageLookupByLibrary.simpleMessage("=== ÜBER-SEITE ==="),
        "_BLUETOOTH_PAGE":
            MessageLookupByLibrary.simpleMessage("=== BLUETOOTH-SEITE ==="),
        "_CHART_PREFERENCES": MessageLookupByLibrary.simpleMessage(
            "=== DIAGRAMM-EINSTELLUNGEN ==="),
        "_CHART_WIDGETS":
            MessageLookupByLibrary.simpleMessage("=== DIAGRAMM-WIDGETS ==="),
        "_CONTACT_PAGE":
            MessageLookupByLibrary.simpleMessage("=== KONTAKTSEITE ==="),
        "_EMPTY_STATE":
            MessageLookupByLibrary.simpleMessage("=== LEERE ZUSTÄNDE ==="),
        "_FIRMWARE_DIALOG":
            MessageLookupByLibrary.simpleMessage("=== FIRMWARE-DIALOG ==="),
        "_GENERAL": MessageLookupByLibrary.simpleMessage("=== ALLGEMEIN ==="),
        "_HISTORY_SCREEN":
            MessageLookupByLibrary.simpleMessage("=== VERLAUFSBILDSCHIRM ==="),
        "_HOME_SCREEN":
            MessageLookupByLibrary.simpleMessage("=== STARTBILDSCHIRM ==="),
        "_LANGUAGE_PAGE":
            MessageLookupByLibrary.simpleMessage("=== SPRACHSEITE ==="),
        "_NAVIGATION":
            MessageLookupByLibrary.simpleMessage("=== NAVIGATION ==="),
        "_ONBOARDING":
            MessageLookupByLibrary.simpleMessage("=== ONBOARDING ==="),
        "_PROFILE_PAGE":
            MessageLookupByLibrary.simpleMessage("=== PROFILSEITE ==="),
        "_SETTINGS_SCREEN": MessageLookupByLibrary.simpleMessage(
            "=== EINSTELLUNGSBILDSCHIRM ==="),
        "_THEME_PAGE":
            MessageLookupByLibrary.simpleMessage("=== DESIGNSEITE ==="),
        "_WATCH_BUTTON_CARD": MessageLookupByLibrary.simpleMessage(
            "=== UHR-SCHALTFLÄCHEN-KARTE ==="),
        "_WATCH_MANAGEMENT":
            MessageLookupByLibrary.simpleMessage("=== UHRENVERWALTUNG ==="),
        "about": MessageLookupByLibrary.simpleMessage("Über"),
        "actionIsDefinitive":
            MessageLookupByLibrary.simpleMessage("Diese Aktion ist endgültig."),
        "addedToFavorites": m0,
        "all": MessageLookupByLibrary.simpleMessage("Alle"),
        "appLanguage":
            MessageLookupByLibrary.simpleMessage("Anwendungssprache"),
        "appTheme": MessageLookupByLibrary.simpleMessage("Anwendungsdesign"),
        "appTitle":
            MessageLookupByLibrary.simpleMessage("InfiniTime Companion"),
        "apply": MessageLookupByLibrary.simpleMessage("Anwenden"),
        "applyProfile":
            MessageLookupByLibrary.simpleMessage("Profil anwenden?"),
        "asymmetry": MessageLookupByLibrary.simpleMessage("Asymmetrie"),
        "autoConnectingTo": m1,
        "axis": MessageLookupByLibrary.simpleMessage("Achse"),
        "back": MessageLookupByLibrary.simpleMessage("Zurück"),
        "balance": MessageLookupByLibrary.simpleMessage("Gleichgewicht"),
        "balanceGoal":
            MessageLookupByLibrary.simpleMessage("Gleichgewichtsziel"),
        "balanced5050":
            MessageLookupByLibrary.simpleMessage("Ausgeglichen (50/50)"),
        "batteryLevel": MessageLookupByLibrary.simpleMessage("Batteriestand"),
        "bluetoothSettings":
            MessageLookupByLibrary.simpleMessage("Bluetooth-Einstellungen"),
        "bluetoothSettingsUpdated": MessageLookupByLibrary.simpleMessage(
            "Bluetooth-Einstellungen aktualisiert"),
        "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "cannotCancel": m2,
        "chartPreferences":
            MessageLookupByLibrary.simpleMessage("Diagramm-Einstellungen"),
        "checkFrequency":
            MessageLookupByLibrary.simpleMessage("Überprüfungshäufigkeit"),
        "checkingFirmware":
            MessageLookupByLibrary.simpleMessage("Firmware wird überprüft..."),
        "chooseChartsToDisplay": MessageLookupByLibrary.simpleMessage(
            "Diagramme zum Anzeigen auswählen"),
        "choosePeriod": MessageLookupByLibrary.simpleMessage("Zeitraum wählen"),
        "chooseUniqueDate":
            MessageLookupByLibrary.simpleMessage("Einzelnes Datum wählen"),
        "clear": MessageLookupByLibrary.simpleMessage("Löschen"),
        "close": MessageLookupByLibrary.simpleMessage("Schließen"),
        "collectionFrequency":
            MessageLookupByLibrary.simpleMessage("Erfassungshäufigkeit"),
        "confirm": MessageLookupByLibrary.simpleMessage("Bestätigen"),
        "confirmDeletion":
            MessageLookupByLibrary.simpleMessage("Löschen bestätigen"),
        "connect": MessageLookupByLibrary.simpleMessage("Verbinden"),
        "connectingTo": m3,
        "connectionAndDataRecording": MessageLookupByLibrary.simpleMessage(
            "Verbindung und Datenaufzeichnung"),
        "connectionSuccessful":
            MessageLookupByLibrary.simpleMessage("Verbindung erfolgreich!"),
        "connectionTimeout": MessageLookupByLibrary.simpleMessage(
            "Verbindungstimeout. Überprüfen Sie, ob die Uhr in der Nähe ist."),
        "contactSupport":
            MessageLookupByLibrary.simpleMessage("Support kontaktieren"),
        "credits": MessageLookupByLibrary.simpleMessage("Danksagungen"),
        "currentBattery": m4,
        "dailyGoal": MessageLookupByLibrary.simpleMessage("Tagesziel"),
        "darkGold": MessageLookupByLibrary.simpleMessage("Dunkles Gold"),
        "darkMint": MessageLookupByLibrary.simpleMessage("Dunkles Minzgrün"),
        "darkTheme": MessageLookupByLibrary.simpleMessage("Dunkles Design"),
        "dataReset":
            MessageLookupByLibrary.simpleMessage("Daten zurückgesetzt."),
        "dataSimulator": MessageLookupByLibrary.simpleMessage("Datensimulator"),
        "delete": MessageLookupByLibrary.simpleMessage("Löschen"),
        "deleteAll": MessageLookupByLibrary.simpleMessage("Alles löschen"),
        "deleteAllLocalData":
            MessageLookupByLibrary.simpleMessage("Alle lokalen Daten löschen"),
        "deletePhoto": MessageLookupByLibrary.simpleMessage("Foto löschen"),
        "deleteWatchQuestion":
            MessageLookupByLibrary.simpleMessage("Uhr löschen?"),
        "developedBy": MessageLookupByLibrary.simpleMessage(
            "Entwickelt vom Health & Tech Team – 2025"),
        "disconnect": MessageLookupByLibrary.simpleMessage("Trennen"),
        "displayedCharts":
            MessageLookupByLibrary.simpleMessage("Angezeigte Diagramme"),
        "doNotDisconnectWatch":
            MessageLookupByLibrary.simpleMessage("Trennen Sie die Uhr nicht"),
        "editName": MessageLookupByLibrary.simpleMessage("Name bearbeiten"),
        "editNameTitle":
            MessageLookupByLibrary.simpleMessage("Name bearbeiten"),
        "emptyList": MessageLookupByLibrary.simpleMessage("Leere Liste"),
        "endDateMustBeAfterStart": MessageLookupByLibrary.simpleMessage(
            "Enddatum muss nach Startdatum liegen"),
        "enterCodeToConfirm": MessageLookupByLibrary.simpleMessage(
            "Bitte geben Sie diesen Code zur Bestätigung ein:"),
        "error": MessageLookupByLibrary.simpleMessage("Fehler"),
        "errorOccurred": m5,
        "experimentalTheme":
            MessageLookupByLibrary.simpleMessage("Experimentelles Design"),
        "exportInDevelopment":
            MessageLookupByLibrary.simpleMessage("Export in Entwicklung..."),
        "exportMyData":
            MessageLookupByLibrary.simpleMessage("Meine Daten exportieren"),
        "finish": MessageLookupByLibrary.simpleMessage("Fertig"),
        "firmware": MessageLookupByLibrary.simpleMessage("Firmware"),
        "firmwareFor": m6,
        "firmwareUpToDate":
            MessageLookupByLibrary.simpleMessage("Firmware ist aktuell."),
        "firmwareUpdate":
            MessageLookupByLibrary.simpleMessage("Firmware-Update"),
        "forceSyncWithWatches": MessageLookupByLibrary.simpleMessage(
            "Synchronisierung mit Uhren erzwingen"),
        "forget": MessageLookupByLibrary.simpleMessage("Vergessen"),
        "forgetThisWatch":
            MessageLookupByLibrary.simpleMessage("Diese Uhr vergessen"),
        "forgetWatchTitle": m7,
        "generate30Days":
            MessageLookupByLibrary.simpleMessage("30 Tage generieren"),
        "generate7Days":
            MessageLookupByLibrary.simpleMessage("7 Tage generieren"),
        "historicalData":
            MessageLookupByLibrary.simpleMessage("Historische Daten"),
        "history": MessageLookupByLibrary.simpleMessage("Verlauf"),
        "imageSelectionError": m8,
        "importData": MessageLookupByLibrary.simpleMessage("Daten importieren"),
        "infinitimeSensors":
            MessageLookupByLibrary.simpleMessage("InfiniTime-Sensoren"),
        "initializationError": m9,
        "install": MessageLookupByLibrary.simpleMessage("Installieren"),
        "installFirmware":
            MessageLookupByLibrary.simpleMessage("Firmware installieren"),
        "language": MessageLookupByLibrary.simpleMessage("Sprache"),
        "languageChangedTo": m10,
        "learnMore": MessageLookupByLibrary.simpleMessage("Mehr erfahren"),
        "left": MessageLookupByLibrary.simpleMessage("Links"),
        "leftDominant70":
            MessageLookupByLibrary.simpleMessage("Links dominant (70%)"),
        "leftWatch": MessageLookupByLibrary.simpleMessage("Linke Uhr"),
        "lightGold": MessageLookupByLibrary.simpleMessage("Helles Gold"),
        "lightMint": MessageLookupByLibrary.simpleMessage("Helles Minzgrün"),
        "lightTheme": MessageLookupByLibrary.simpleMessage("Helles Design"),
        "loadingFirmwares":
            MessageLookupByLibrary.simpleMessage("Firmwares werden geladen..."),
        "magnitude": MessageLookupByLibrary.simpleMessage("Größe"),
        "manageNameAndPhoto": MessageLookupByLibrary.simpleMessage(
            "Name und Profilfoto verwalten"),
        "messageSentToSupport": MessageLookupByLibrary.simpleMessage(
            "Nachricht an Support gesendet."),
        "metrics": MessageLookupByLibrary.simpleMessage("Metriken"),
        "nameCannotBeEmpty":
            MessageLookupByLibrary.simpleMessage("Name darf nicht leer sein"),
        "navHistory": MessageLookupByLibrary.simpleMessage("Verlauf"),
        "navHome": MessageLookupByLibrary.simpleMessage("Home"),
        "navProfile": MessageLookupByLibrary.simpleMessage("Profil"),
        "navSettings": MessageLookupByLibrary.simpleMessage("Einstellungen"),
        "newName": MessageLookupByLibrary.simpleMessage("Neuer Name"),
        "next": MessageLookupByLibrary.simpleMessage("Weiter"),
        "noDataAvailable":
            MessageLookupByLibrary.simpleMessage("Keine Daten verfügbar"),
        "noFirmwareAvailable":
            MessageLookupByLibrary.simpleMessage("Keine Firmware verfügbar"),
        "notifications":
            MessageLookupByLibrary.simpleMessage("Benachrichtigungen"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "permissionsRequired":
            MessageLookupByLibrary.simpleMessage("Berechtigungen erforderlich"),
        "pinetimePosition": m11,
        "pleaseWaitBetweenConnections": MessageLookupByLibrary.simpleMessage(
            "Bitte warten Sie zwischen Verbindungsversuchen"),
        "privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Datenschutzrichtlinie"),
        "privacyPolicyContent": MessageLookupByLibrary.simpleMessage(
            "Datenschutzrichtlinie wird hier hinzugefügt."),
        "profile": MessageLookupByLibrary.simpleMessage("Profil"),
        "profileUpdated": MessageLookupByLibrary.simpleMessage(
            "Profil erfolgreich aktualisiert"),
        "pushUpdate": MessageLookupByLibrary.simpleMessage("Update übertragen"),
        "receiveDailyReminders": MessageLookupByLibrary.simpleMessage(
            "Tägliche Erinnerungen erhalten"),
        "reconnect": MessageLookupByLibrary.simpleMessage("Erneut verbinden"),
        "refresh": MessageLookupByLibrary.simpleMessage("Aktualisieren"),
        "reload": MessageLookupByLibrary.simpleMessage("Neu laden"),
        "removedFromFavorites": m12,
        "removingWatch": m13,
        "renameWatch": MessageLookupByLibrary.simpleMessage("Uhr umbenennen"),
        "resetAllConfigurations": MessageLookupByLibrary.simpleMessage(
            "Alle Konfigurationen zurücksetzen"),
        "resetData": MessageLookupByLibrary.simpleMessage("Daten zurücksetzen"),
        "resetFilter":
            MessageLookupByLibrary.simpleMessage("Filter zurücksetzen"),
        "resetSettings":
            MessageLookupByLibrary.simpleMessage("Einstellungen zurücksetzen"),
        "restartScan": MessageLookupByLibrary.simpleMessage("Scan neu starten"),
        "retry": MessageLookupByLibrary.simpleMessage("Wiederholen"),
        "right": MessageLookupByLibrary.simpleMessage("Rechts"),
        "rightDominant70":
            MessageLookupByLibrary.simpleMessage("Rechts dominant (70%)"),
        "rightWatch": MessageLookupByLibrary.simpleMessage("Rechte Uhr"),
        "save": MessageLookupByLibrary.simpleMessage("Speichern"),
        "saveToFile":
            MessageLookupByLibrary.simpleMessage("In Datei speichern"),
        "scanPineTime":
            MessageLookupByLibrary.simpleMessage("PineTime scannen"),
        "searchDevice": MessageLookupByLibrary.simpleMessage("Gerät suchen"),
        "sendConfigToWatches": MessageLookupByLibrary.simpleMessage(
            "Konfiguration an Uhren senden"),
        "settings": MessageLookupByLibrary.simpleMessage("Einstellungen"),
        "settingsButton": MessageLookupByLibrary.simpleMessage("Einstellungen"),
        "shareMyData":
            MessageLookupByLibrary.simpleMessage("Meine Daten teilen"),
        "showStats":
            MessageLookupByLibrary.simpleMessage("Statistiken anzeigen"),
        "simulator": MessageLookupByLibrary.simpleMessage("Simulator"),
        "sorryNoProductWishlist": MessageLookupByLibrary.simpleMessage(
            "Entschuldigung, Sie haben kein Produkt in Ihrer Wunschliste"),
        "startAdding": MessageLookupByLibrary.simpleMessage(
            "Beginnen Sie mit dem Hinzufügen"),
        "startScan": MessageLookupByLibrary.simpleMessage("Scan starten"),
        "stepCount": MessageLookupByLibrary.simpleMessage("Schrittzahl"),
        "supportEmail":
            MessageLookupByLibrary.simpleMessage("support@monapp.com"),
        "synchronization":
            MessageLookupByLibrary.simpleMessage("Synchronisierung"),
        "systemInformation":
            MessageLookupByLibrary.simpleMessage("Systeminformationen"),
        "systemTheme": MessageLookupByLibrary.simpleMessage("Systemdesign"),
        "termsOfUse":
            MessageLookupByLibrary.simpleMessage("Nutzungsbedingungen"),
        "termsOfUseContent": MessageLookupByLibrary.simpleMessage(
            "Nutzungsbedingungen werden hier hinzugefügt."),
        "testVibration":
            MessageLookupByLibrary.simpleMessage("Vibration testen"),
        "theme": MessageLookupByLibrary.simpleMessage("Design"),
        "themeUpdated":
            MessageLookupByLibrary.simpleMessage("Design aktualisiert."),
        "tryAgainOrContact": MessageLookupByLibrary.simpleMessage(
            "Bitte versuchen Sie es erneut oder kontaktieren Sie den Support."),
        "updateComplete":
            MessageLookupByLibrary.simpleMessage("Update abgeschlossen"),
        "updateErrorOccurred": MessageLookupByLibrary.simpleMessage(
            "Bei der Aktualisierung ist ein Fehler aufgetreten."),
        "updateFailed": MessageLookupByLibrary.simpleMessage("Fehler"),
        "updateInstalledSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Update erfolgreich installiert!"),
        "updateWatchTitle": m14,
        "updateWatches":
            MessageLookupByLibrary.simpleMessage("Uhren aktualisieren"),
        "updating":
            MessageLookupByLibrary.simpleMessage("Aktualisierung läuft"),
        "vibrationTested": MessageLookupByLibrary.simpleMessage(
            "Vibration erfolgreich getestet"),
        "watchDeleted": MessageLookupByLibrary.simpleMessage("Uhr gelöscht."),
        "watchLeftRight": m15,
        "watchSynced":
            MessageLookupByLibrary.simpleMessage("Uhr synchronisiert"),
        "watchWillRestart": MessageLookupByLibrary.simpleMessage(
            "Ihre Uhr wird automatisch neu starten."),
        "whatToUpdate": MessageLookupByLibrary.simpleMessage(
            "Was möchten Sie aktualisieren?")
      };
}
