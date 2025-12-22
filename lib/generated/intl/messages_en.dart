// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(name) => "${name} added to favorites";

  static String m1(name) => "Auto-connecting to ${name}...";

  static String m2(error) => "Cannot cancel: ${error}";

  static String m3(name) => "Connecting to ${name}...";

  static String m4(level) => "Current battery: ${level}%";

  static String m5(error) => "Error: ${error}";

  static String m6(side) => "Firmware for ${side}";

  static String m7(position) => "Forget watch ${position}?";

  static String m8(error) => "Image selection error: ${error}";

  static String m9(error) => "Initialization error: ${error}";

  static String m10(language) => "Language changed to ${language}";

  static String m11(position) => "PineTime (${position})";

  static String m12(name) => "${name} removed from favorites";

  static String m13(position) => "Removing watch ${position}...";

  static String m14(side) => "Update watch ${side}";

  static String m15(side) => "Watch ${side}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "_ABOUT_PAGE":
            MessageLookupByLibrary.simpleMessage("=== PAGE À PROPOS ==="),
        "_BLUETOOTH_PAGE":
            MessageLookupByLibrary.simpleMessage("=== PAGE BLUETOOTH ==="),
        "_CHART_PREFERENCES": MessageLookupByLibrary.simpleMessage(
            "=== PRÉFÉRENCES GRAPHIQUES ==="),
        "_CHART_WIDGETS":
            MessageLookupByLibrary.simpleMessage("=== WIDGETS GRAPHIQUES ==="),
        "_CONTACT_PAGE":
            MessageLookupByLibrary.simpleMessage("=== PAGE CONTACT ==="),
        "_EMPTY_STATE":
            MessageLookupByLibrary.simpleMessage("=== ÉTATS VIDES ==="),
        "_FIRMWARE_DIALOG":
            MessageLookupByLibrary.simpleMessage("=== DIALOGUE FIRMWARE ==="),
        "_GENERAL": MessageLookupByLibrary.simpleMessage("=== GÉNÉRAL ==="),
        "_HISTORY_SCREEN":
            MessageLookupByLibrary.simpleMessage("=== ÉCRAN HISTORIQUE ==="),
        "_HOME_SCREEN":
            MessageLookupByLibrary.simpleMessage("=== ÉCRAN ACCUEIL ==="),
        "_LANGUAGE_PAGE":
            MessageLookupByLibrary.simpleMessage("=== PAGE LANGUE ==="),
        "_NAVIGATION":
            MessageLookupByLibrary.simpleMessage("=== NAVIGATION ==="),
        "_ONBOARDING":
            MessageLookupByLibrary.simpleMessage("=== ONBOARDING ==="),
        "_PROFILE_PAGE":
            MessageLookupByLibrary.simpleMessage("=== PAGE PROFIL ==="),
        "_SETTINGS_SCREEN":
            MessageLookupByLibrary.simpleMessage("=== ÉCRAN PARAMÈTRES ==="),
        "_THEME_PAGE":
            MessageLookupByLibrary.simpleMessage("=== PAGE THÈME ==="),
        "_WATCH_BUTTON_CARD":
            MessageLookupByLibrary.simpleMessage("=== CARTE BOUTON MONTRE ==="),
        "_WATCH_MANAGEMENT":
            MessageLookupByLibrary.simpleMessage("=== GESTION MONTRES ==="),
        "about": MessageLookupByLibrary.simpleMessage("About"),
        "actionIsDefinitive":
            MessageLookupByLibrary.simpleMessage("This action is permanent."),
        "addedToFavorites": m0,
        "all": MessageLookupByLibrary.simpleMessage("All"),
        "appLanguage":
            MessageLookupByLibrary.simpleMessage("Application Language"),
        "appTheme": MessageLookupByLibrary.simpleMessage("Application Theme"),
        "appTitle":
            MessageLookupByLibrary.simpleMessage("InfiniTime Companion"),
        "apply": MessageLookupByLibrary.simpleMessage("Apply"),
        "applyProfile": MessageLookupByLibrary.simpleMessage("Apply profile?"),
        "asymmetry": MessageLookupByLibrary.simpleMessage("Asymmetry"),
        "autoConnectingTo": m1,
        "axis": MessageLookupByLibrary.simpleMessage("Axis"),
        "back": MessageLookupByLibrary.simpleMessage("Back"),
        "balance": MessageLookupByLibrary.simpleMessage("Balance"),
        "balanceGoal": MessageLookupByLibrary.simpleMessage("Balance Goal"),
        "balanced5050":
            MessageLookupByLibrary.simpleMessage("Balanced (50/50)"),
        "batteryLevel": MessageLookupByLibrary.simpleMessage("Battery Level"),
        "bluetoothSettings":
            MessageLookupByLibrary.simpleMessage("Bluetooth Settings"),
        "bluetoothSettingsUpdated":
            MessageLookupByLibrary.simpleMessage("Bluetooth settings updated"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cannotCancel": m2,
        "chartPreferences":
            MessageLookupByLibrary.simpleMessage("Chart Preferences"),
        "checkFrequency":
            MessageLookupByLibrary.simpleMessage("Check Frequency"),
        "checkingFirmware":
            MessageLookupByLibrary.simpleMessage("Checking firmware..."),
        "chooseChartsToDisplay":
            MessageLookupByLibrary.simpleMessage("Choose charts to display"),
        "choosePeriod": MessageLookupByLibrary.simpleMessage("Choose a period"),
        "chooseUniqueDate":
            MessageLookupByLibrary.simpleMessage("Choose a single date"),
        "clear": MessageLookupByLibrary.simpleMessage("Clear"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "collectionFrequency":
            MessageLookupByLibrary.simpleMessage("Collection Frequency"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "confirmDeletion":
            MessageLookupByLibrary.simpleMessage("Confirm deletion"),
        "connect": MessageLookupByLibrary.simpleMessage("Connect"),
        "connectingTo": m3,
        "connectionAndDataRecording": MessageLookupByLibrary.simpleMessage(
            "Connection and data recording"),
        "connectionSuccessful":
            MessageLookupByLibrary.simpleMessage("Connection successful!"),
        "connectionTimeout": MessageLookupByLibrary.simpleMessage(
            "Connection timeout. Check that the watch is nearby."),
        "contactSupport":
            MessageLookupByLibrary.simpleMessage("Contact Support"),
        "credits": MessageLookupByLibrary.simpleMessage("Credits"),
        "currentBattery": m4,
        "dailyGoal": MessageLookupByLibrary.simpleMessage("Daily Goal"),
        "darkGold": MessageLookupByLibrary.simpleMessage("Dark Gold"),
        "darkMint": MessageLookupByLibrary.simpleMessage("Dark Mint"),
        "darkTheme": MessageLookupByLibrary.simpleMessage("Dark Theme"),
        "dataReset": MessageLookupByLibrary.simpleMessage("Data reset."),
        "dataSimulator": MessageLookupByLibrary.simpleMessage("Data Simulator"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteAll": MessageLookupByLibrary.simpleMessage("Delete All"),
        "deleteAllLocalData":
            MessageLookupByLibrary.simpleMessage("Delete all local data"),
        "deletePhoto": MessageLookupByLibrary.simpleMessage("Delete Photo"),
        "deleteWatchQuestion":
            MessageLookupByLibrary.simpleMessage("Delete watch?"),
        "developedBy": MessageLookupByLibrary.simpleMessage(
            "Developed by Health & Tech team – 2025"),
        "disconnect": MessageLookupByLibrary.simpleMessage("Disconnect"),
        "displayedCharts":
            MessageLookupByLibrary.simpleMessage("Displayed Charts"),
        "doNotDisconnectWatch":
            MessageLookupByLibrary.simpleMessage("Do not disconnect the watch"),
        "editName": MessageLookupByLibrary.simpleMessage("Edit Name"),
        "editNameTitle": MessageLookupByLibrary.simpleMessage("Edit Name"),
        "emptyList": MessageLookupByLibrary.simpleMessage("Empty list"),
        "endDateMustBeAfterStart": MessageLookupByLibrary.simpleMessage(
            "End date must be after start date"),
        "enterCodeToConfirm": MessageLookupByLibrary.simpleMessage(
            "Please enter this code to confirm:"),
        "error": MessageLookupByLibrary.simpleMessage("Error"),
        "errorOccurred": m5,
        "experimentalTheme":
            MessageLookupByLibrary.simpleMessage("Experimental Theme"),
        "exportInDevelopment":
            MessageLookupByLibrary.simpleMessage("Export in development..."),
        "exportMyData": MessageLookupByLibrary.simpleMessage("Export My Data"),
        "finish": MessageLookupByLibrary.simpleMessage("Finish"),
        "firmware": MessageLookupByLibrary.simpleMessage("Firmware"),
        "firmwareFor": m6,
        "firmwareUpToDate":
            MessageLookupByLibrary.simpleMessage("Firmware up to date."),
        "firmwareUpdate":
            MessageLookupByLibrary.simpleMessage("Firmware Update"),
        "forceSyncWithWatches":
            MessageLookupByLibrary.simpleMessage("Force sync with watches"),
        "forget": MessageLookupByLibrary.simpleMessage("Forget"),
        "forgetThisWatch":
            MessageLookupByLibrary.simpleMessage("Forget This Watch"),
        "forgetWatchTitle": m7,
        "generate30Days":
            MessageLookupByLibrary.simpleMessage("Generate 30 days"),
        "generate7Days":
            MessageLookupByLibrary.simpleMessage("Generate 7 days"),
        "historicalData":
            MessageLookupByLibrary.simpleMessage("Historical Data"),
        "history": MessageLookupByLibrary.simpleMessage("History"),
        "imageSelectionError": m8,
        "importData": MessageLookupByLibrary.simpleMessage("Import Data"),
        "infinitimeSensors":
            MessageLookupByLibrary.simpleMessage("InfiniTime Sensors"),
        "initializationError": m9,
        "install": MessageLookupByLibrary.simpleMessage("Install"),
        "installFirmware":
            MessageLookupByLibrary.simpleMessage("Install Firmware"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "languageChangedTo": m10,
        "learnMore": MessageLookupByLibrary.simpleMessage("Learn More"),
        "left": MessageLookupByLibrary.simpleMessage("Left"),
        "leftDominant70":
            MessageLookupByLibrary.simpleMessage("Left Dominant (70%)"),
        "leftWatch": MessageLookupByLibrary.simpleMessage("Left Watch"),
        "lightGold": MessageLookupByLibrary.simpleMessage("Light Gold"),
        "lightMint": MessageLookupByLibrary.simpleMessage("Light Mint"),
        "lightTheme": MessageLookupByLibrary.simpleMessage("Light Theme"),
        "loadingFirmwares":
            MessageLookupByLibrary.simpleMessage("Loading firmwares..."),
        "magnitude": MessageLookupByLibrary.simpleMessage("Magnitude"),
        "manageNameAndPhoto": MessageLookupByLibrary.simpleMessage(
            "Manage name and profile photo"),
        "messageSentToSupport":
            MessageLookupByLibrary.simpleMessage("Message sent to support."),
        "metrics": MessageLookupByLibrary.simpleMessage("Metrics"),
        "nameCannotBeEmpty":
            MessageLookupByLibrary.simpleMessage("Name cannot be empty"),
        "navHistory": MessageLookupByLibrary.simpleMessage("History"),
        "navHome": MessageLookupByLibrary.simpleMessage("Home"),
        "navProfile": MessageLookupByLibrary.simpleMessage("Profile"),
        "navSettings": MessageLookupByLibrary.simpleMessage("Settings"),
        "newName": MessageLookupByLibrary.simpleMessage("New Name"),
        "next": MessageLookupByLibrary.simpleMessage("Next"),
        "noDataAvailable":
            MessageLookupByLibrary.simpleMessage("No data available"),
        "noFirmwareAvailable":
            MessageLookupByLibrary.simpleMessage("No firmware available"),
        "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "permissionsRequired":
            MessageLookupByLibrary.simpleMessage("Permissions Required"),
        "pinetimePosition": m11,
        "pleaseWaitBetweenConnections": MessageLookupByLibrary.simpleMessage(
            "Please wait between connection attempts"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
        "privacyPolicyContent": MessageLookupByLibrary.simpleMessage(
            "Privacy policy will be added here."),
        "profile": MessageLookupByLibrary.simpleMessage("Profile"),
        "profileUpdated": MessageLookupByLibrary.simpleMessage(
            "Profile updated successfully"),
        "pushUpdate": MessageLookupByLibrary.simpleMessage("Push Update"),
        "receiveDailyReminders":
            MessageLookupByLibrary.simpleMessage("Receive daily reminders"),
        "reconnect": MessageLookupByLibrary.simpleMessage("Reconnect"),
        "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
        "reload": MessageLookupByLibrary.simpleMessage("Reload"),
        "removedFromFavorites": m12,
        "removingWatch": m13,
        "renameWatch": MessageLookupByLibrary.simpleMessage("Rename Watch"),
        "resetAllConfigurations":
            MessageLookupByLibrary.simpleMessage("Reset all configurations"),
        "resetData": MessageLookupByLibrary.simpleMessage("Reset Data"),
        "resetFilter": MessageLookupByLibrary.simpleMessage("Reset filter"),
        "resetSettings": MessageLookupByLibrary.simpleMessage("Reset Settings"),
        "restartScan": MessageLookupByLibrary.simpleMessage("Restart Scan"),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "right": MessageLookupByLibrary.simpleMessage("Right"),
        "rightDominant70":
            MessageLookupByLibrary.simpleMessage("Right Dominant (70%)"),
        "rightWatch": MessageLookupByLibrary.simpleMessage("Right Watch"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "saveToFile": MessageLookupByLibrary.simpleMessage("Save to file"),
        "scanPineTime": MessageLookupByLibrary.simpleMessage("Scan a PineTime"),
        "searchDevice": MessageLookupByLibrary.simpleMessage("Search Device"),
        "sendConfigToWatches":
            MessageLookupByLibrary.simpleMessage("Send config to watches"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "settingsButton": MessageLookupByLibrary.simpleMessage("Settings"),
        "shareMyData": MessageLookupByLibrary.simpleMessage("Share My Data"),
        "showStats": MessageLookupByLibrary.simpleMessage("Show Stats"),
        "simulator": MessageLookupByLibrary.simpleMessage("Simulator"),
        "sorryNoProductWishlist": MessageLookupByLibrary.simpleMessage(
            "Sorry, you have no product in your wishlist"),
        "startAdding": MessageLookupByLibrary.simpleMessage("Start Adding"),
        "startScan": MessageLookupByLibrary.simpleMessage("Start Scan"),
        "stepCount": MessageLookupByLibrary.simpleMessage("Step Count"),
        "supportEmail":
            MessageLookupByLibrary.simpleMessage("support@monapp.com"),
        "synchronization":
            MessageLookupByLibrary.simpleMessage("Synchronization"),
        "systemInformation":
            MessageLookupByLibrary.simpleMessage("System Information"),
        "systemTheme": MessageLookupByLibrary.simpleMessage("System Theme"),
        "termsOfUse": MessageLookupByLibrary.simpleMessage("Terms of Use"),
        "termsOfUseContent": MessageLookupByLibrary.simpleMessage(
            "Terms of use will be added here."),
        "testVibration": MessageLookupByLibrary.simpleMessage("Test Vibration"),
        "theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "themeUpdated": MessageLookupByLibrary.simpleMessage("Theme updated."),
        "tryAgainOrContact": MessageLookupByLibrary.simpleMessage(
            "Please try again or contact support."),
        "updateComplete":
            MessageLookupByLibrary.simpleMessage("Update Complete"),
        "updateErrorOccurred": MessageLookupByLibrary.simpleMessage(
            "An error occurred during the update."),
        "updateFailed": MessageLookupByLibrary.simpleMessage("Error"),
        "updateInstalledSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Update installed successfully!"),
        "updateWatchTitle": m14,
        "updateWatches": MessageLookupByLibrary.simpleMessage("Update Watches"),
        "updating": MessageLookupByLibrary.simpleMessage("Updating"),
        "vibrationTested": MessageLookupByLibrary.simpleMessage(
            "Vibration tested successfully"),
        "watchDeleted": MessageLookupByLibrary.simpleMessage("Watch deleted."),
        "watchLeftRight": m15,
        "watchSynced":
            MessageLookupByLibrary.simpleMessage("Watch synchronized"),
        "watchWillRestart": MessageLookupByLibrary.simpleMessage(
            "Your watch will restart automatically."),
        "whatToUpdate": MessageLookupByLibrary.simpleMessage(
            "What would you like to update?")
      };
}
