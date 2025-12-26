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

  static String m0(time) => "Active: ${time}";

  static String m1(name) => "${name} added to favorites";

  static String m2(days) => "${days}d ago";

  static String m3(hours) => "${hours}h ago";

  static String m4(minutes) => "${minutes}min ago";

  static String m5(seconds) => "${seconds}s ago";

  static String m6(name) => "Auto-connecting to ${name}...";

  static String m7(value, unit) => "Avg: ${value} ${unit}";

  static String m8(level) => "Battery: ${level}%";

  static String m9(error) => "Cannot cancel: ${error}";

  static String m10(count) => "${count} chart(s) enabled";

  static String m11(name) => "Connecting to ${name}...";

  static String m12(error) => "Connection error: ${error}";

  static String m13(current, max) => "Retrying... (attempt ${current}/${max})";

  static String m14(side) => "Connection successful for ${side}";

  static String m15(email) =>
      "For any questions regarding this policy, please contact: ${email}.";

  static String m16(email) => "Contact us at: ${email}";

  static String m17(level) => "Current battery: ${level}%";

  static String m18(mode) => "Current mode: ${mode}";

  static String m19(size) => "Data exported successfully (${size} bytes)";

  static String m20(days) => "${days} days of data generated!";

  static String m21(side) => "Deleting watch ${side}...";

  static String m22(side) => "Device info request for ${side}";

  static String m23(current, total, percent) =>
      "Device ${current}/${total} - ${percent}%";

  static String m24(side) => "Disconnection of ${side}";

  static String m25(duration) => "Duration: ${duration}";

  static String m26(side) => "Error forgetting watch ${side}";

  static String m27(error) => "Error: ${error}";

  static String m28(error) => "Error: ${error}";

  static String m29(count) => "${count} events";

  static String m30(error) => "Export error: ${error}";

  static String m31(side) => "Firmware for ${side}";

  static String m32(side) => "Forget watch ${side}?";

  static String m33(position) => "Forget watch ${position}?";

  static String m34(start, end) => "From ${start} to ${end}";

  static String m35(days) => "Generate ${days} days";

  static String m36(percent) =>
      "Generating with asymmetry (${percent}% left)...";

  static String m37(days) => "Generating ${days} days of data...";

  static String m38(gap) => "Goal not reached (gap: ${gap}%)";

  static String m39(error) => "Image selection error: ${error}";

  static String m40(error) => "Error selecting image: ${error}";

  static String m41(error) => "Import error: ${error}";

  static String m42(error) => "Initialization error: ${error}";

  static String m43(count) => "Install on ${count} watches";

  static String m44(current, total) =>
      "Installing on device ${current}/${total}...";

  static String m45(value) => "${value} ms";

  static String m46(error) => "Invalid file format: ${error}";

  static String m47(language) => "Language changed to ${language}";

  static String m48(name) => "Language changed to ${name}";

  static String m49(date) => "Last updated: ${date}";

  static String m50(percent) => "Left Dominant (${percent}%)";

  static String m51(value) => "Magnitude: ${value}";

  static String m52(value) => "~${value} MB/day (8h usage, 2 watches)";

  static String m53(count) => "PDF generated with ${count} chart(s)";

  static String m54(error) => "Error generating PDF: ${error}";

  static String m55(period) => "Period: ${period}";

  static String m56(position) => "PineTime (${position})";

  static String m57(side) => "Reconnection in progress for ${side}";

  static String m58(count) => "${count} records";

  static String m59(name) => "${name} removed from favorites";

  static String m60(position) => "Removing watch ${position}...";

  static String m61(error) => "Reset error: ${error}";

  static String m62(percent) => "Right Dominant (${percent}%)";

  static String m63(count) => "${count} samples";

  static String m64(count) => "~${count} samples/hour";

  static String m65(count) => "${count} samples/hour per watch";

  static String m66(count) => "About ${count} samples/min per watch";

  static String m67(speed) => "Speed: ${speed} KB/s";

  static String m68(count) => "${count} steps";

  static String m69(minutes) => "${minutes} minutes ago";

  static String m70(watches, timezone) =>
      "Time synced for: ${watches}\nTimezone: ${timezone}";

  static String m71(type) => "Type: ${type}";

  static String m72(period, type) => "Period: ${period} • Type: ${type}";

  static String m73(side) => "Update watch ${side}";

  static String m74(side) => "Update watch ${side}";

  static String m75(version, buildNumber) =>
      "Version ${version} (build ${buildNumber})";

  static String m76(side) => "Watch ${side} forgotten successfully";

  static String m77(side) => "Watch ${side}";

  static String m78(side) => "Watch ${side}";

  static String m79(status) => "Status: ${status}";

  static String m80(count) =>
      "${count} watch(es) connected will be updated with the new watchface.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "_ABOUT_PAGE": MessageLookupByLibrary.simpleMessage("=== ABOUT PAGE ==="),
    "_BLUETOOTH_PAGE": MessageLookupByLibrary.simpleMessage(
      "=== PAGE BLUETOOTH ===",
    ),
    "_BLUETOOTH_SETTINGS": MessageLookupByLibrary.simpleMessage(
      "=== BLUETOOTH SETTINGS ===",
    ),
    "_BLUETOOTH_SETTINGS_PAGE": MessageLookupByLibrary.simpleMessage(
      "=== BLUETOOTH SETTINGS PAGE ===",
    ),
    "_CHART_LABELS": MessageLookupByLibrary.simpleMessage(
      "=== CHART LABELS ===",
    ),
    "_CHART_PREFERENCES": MessageLookupByLibrary.simpleMessage(
      "=== CHART PREFERENCES ===",
    ),
    "_CHART_PREFERENCES_PAGE": MessageLookupByLibrary.simpleMessage(
      "=== CHART PREFERENCES PAGE ===",
    ),
    "_CHART_WIDGETS": MessageLookupByLibrary.simpleMessage(
      "=== WIDGETS GRAPHIQUES ===",
    ),
    "_CONNECTION_ERRORS": MessageLookupByLibrary.simpleMessage(
      "=== CONNECTION ERRORS ===",
    ),
    "_CONTACT_PAGE": MessageLookupByLibrary.simpleMessage(
      "=== PAGE CONTACT ===",
    ),
    "_CONTACT_SUPPORT": MessageLookupByLibrary.simpleMessage(
      "=== CONTACT SUPPORT ===",
    ),
    "_EMPTY_SAVE_PAGE": MessageLookupByLibrary.simpleMessage(
      "=== EMPTY SAVE PAGE ===",
    ),
    "_EMPTY_STATE": MessageLookupByLibrary.simpleMessage("=== EMPTY STATE ==="),
    "_FIRMWARE_DIALOG": MessageLookupByLibrary.simpleMessage(
      "=== DIALOGUE FIRMWARE ===",
    ),
    "_GENERAL": MessageLookupByLibrary.simpleMessage("=== GÉNÉRAL ==="),
    "_GOAL_SETTINGS": MessageLookupByLibrary.simpleMessage(
      "=== GOAL SETTINGS ===",
    ),
    "_GOAL_SETTINGS_PAGE": MessageLookupByLibrary.simpleMessage(
      "=== GOAL SETTINGS PAGE ===",
    ),
    "_HISTORY_SCREEN": MessageLookupByLibrary.simpleMessage(
      "=== HISTORY SCREEN ===",
    ),
    "_HOME_SCREEN": MessageLookupByLibrary.simpleMessage("=== HOME SCREEN ==="),
    "_LANGUAGE_PAGE": MessageLookupByLibrary.simpleMessage(
      "=== PAGE LANGUE ===",
    ),
    "_LANGUAGE_SETTINGS_PAGE": MessageLookupByLibrary.simpleMessage(
      "=== LANGUAGE SETTINGS PAGE ===",
    ),
    "_MOVEMENT_SAMPLING": MessageLookupByLibrary.simpleMessage(
      "=== MOVEMENT SAMPLING ===",
    ),
    "_MOVEMENT_SAMPLING_PAGE": MessageLookupByLibrary.simpleMessage(
      "=== MOVEMENT SAMPLING PAGE ===",
    ),
    "_NAVIGATION": MessageLookupByLibrary.simpleMessage("=== NAVIGATION ==="),
    "_ONBOARDING": MessageLookupByLibrary.simpleMessage("=== ONBOARDING ==="),
    "_ONBOARDING_SCREEN": MessageLookupByLibrary.simpleMessage(
      "=== ONBOARDING SCREEN ===",
    ),
    "_PDF_EXPORT": MessageLookupByLibrary.simpleMessage("=== PDF EXPORT ==="),
    "_PRIVACY_POLICY_PAGE": MessageLookupByLibrary.simpleMessage(
      "=== PRIVACY POLICY PAGE ===",
    ),
    "_PROFILE_HEADER": MessageLookupByLibrary.simpleMessage(
      "=== PROFILE HEADER ===",
    ),
    "_PROFILE_PAGE": MessageLookupByLibrary.simpleMessage(
      "=== PAGE PROFIL ===",
    ),
    "_PROFILE_SETTINGS_PAGE": MessageLookupByLibrary.simpleMessage(
      "=== PROFILE SETTINGS PAGE ===",
    ),
    "_RESET_DIALOGS": MessageLookupByLibrary.simpleMessage(
      "=== RESET DIALOGS ===",
    ),
    "_SEARCH_FILTER_SCREEN": MessageLookupByLibrary.simpleMessage(
      "=== SEARCH FILTER SCREEN ===",
    ),
    "_SETTINGS_SCREEN": MessageLookupByLibrary.simpleMessage(
      "=== ÉCRAN PARAMÈTRES ===",
    ),
    "_SETTINGS_SCREEN_EXTRA": MessageLookupByLibrary.simpleMessage(
      "=== SETTINGS SCREEN EXTRA ===",
    ),
    "_SPLASH_SCREEN": MessageLookupByLibrary.simpleMessage(
      "=== SPLASH SCREEN ===",
    ),
    "_THEME_PAGE": MessageLookupByLibrary.simpleMessage("=== PAGE THÈME ==="),
    "_THEME_SETTINGS_PAGE": MessageLookupByLibrary.simpleMessage(
      "=== THEME SETTINGS PAGE ===",
    ),
    "_TIME_PREFERENCES": MessageLookupByLibrary.simpleMessage(
      "=== TIME PREFERENCES ===",
    ),
    "_TIME_PREFERENCES_PAGE": MessageLookupByLibrary.simpleMessage(
      "=== TIME PREFERENCES PAGE ===",
    ),
    "_WATCHFACE_INSTALL": MessageLookupByLibrary.simpleMessage(
      "=== WATCHFACE INSTALL ===",
    ),
    "_WATCHFACE_INSTALL_SHEET": MessageLookupByLibrary.simpleMessage(
      "=== WATCHFACE INSTALL SHEET ===",
    ),
    "_WATCH_BUTTON_CARD": MessageLookupByLibrary.simpleMessage(
      "=== CARTE BOUTON MONTRE ===",
    ),
    "_WATCH_CARD": MessageLookupByLibrary.simpleMessage("=== WATCH CARD ==="),
    "_WATCH_MANAGEMENT": MessageLookupByLibrary.simpleMessage(
      "=== GESTION MONTRES ===",
    ),
    "_WATCH_MANAGEMENT_PAGE": MessageLookupByLibrary.simpleMessage(
      "=== WATCH MANAGEMENT PAGE ===",
    ),
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "actionIsDefinitive": MessageLookupByLibrary.simpleMessage(
      "This action is permanent.",
    ),
    "active": m0,
    "activityDetected": MessageLookupByLibrary.simpleMessage(
      "Activity detected",
    ),
    "actualRatio": MessageLookupByLibrary.simpleMessage("Actual ratio"),
    "addedToFavorites": m1,
    "adjustBluetoothSettings": MessageLookupByLibrary.simpleMessage(
      "Adjust Bluetooth settings to optimize connection and battery consumption",
    ),
    "advancedSettings": MessageLookupByLibrary.simpleMessage(
      "Advanced settings",
    ),
    "affectedSide": MessageLookupByLibrary.simpleMessage("Affected side"),
    "agoDays": m2,
    "agoHours": m3,
    "agoMinutes": m4,
    "agoSeconds": m5,
    "all": MessageLookupByLibrary.simpleMessage("All"),
    "allConfigurationsWillBeReset": MessageLookupByLibrary.simpleMessage(
      "All your configurations will be reset.\nThis action is **irreversible**.",
    ),
    "allData": MessageLookupByLibrary.simpleMessage("All"),
    "allDataDeleted": MessageLookupByLibrary.simpleMessage("All data deleted"),
    "allDataLabel": MessageLookupByLibrary.simpleMessage("All data"),
    "allLocalDataWillBeDeleted": MessageLookupByLibrary.simpleMessage(
      "All your local data will be deleted.\nThis action is **irreversible**.",
    ),
    "appLanguage": MessageLookupByLibrary.simpleMessage("Application Language"),
    "appLanguageTitle": MessageLookupByLibrary.simpleMessage("App Language"),
    "appTheme": MessageLookupByLibrary.simpleMessage("Application Theme"),
    "appThemeTitle": MessageLookupByLibrary.simpleMessage("App Theme"),
    "appTitle": MessageLookupByLibrary.simpleMessage("InfiniTime Companion"),
    "appearance": MessageLookupByLibrary.simpleMessage("Appearance"),
    "apply": MessageLookupByLibrary.simpleMessage("Apply"),
    "applyButton": MessageLookupByLibrary.simpleMessage("Apply"),
    "applyProfile": MessageLookupByLibrary.simpleMessage("Apply profile?"),
    "applyProfileDescription": MessageLookupByLibrary.simpleMessage(
      "This will modify all your Bluetooth settings according to the selected profile.",
    ),
    "applyProfileQuestion": MessageLookupByLibrary.simpleMessage(
      "Apply profile?",
    ),
    "armToVibrate": MessageLookupByLibrary.simpleMessage("Arm to vibrate"),
    "asymmetricDataGenerated": MessageLookupByLibrary.simpleMessage(
      "Asymmetric data generated!",
    ),
    "asymmetry": MessageLookupByLibrary.simpleMessage("Asymmetry"),
    "asymmetryMagnitudeAndAxis": MessageLookupByLibrary.simpleMessage(
      "Asymmetry Magnitude & Axis",
    ),
    "asymmetryMagnitudeAxis": MessageLookupByLibrary.simpleMessage(
      "Asymmetry (Magnitude & Axis)",
    ),
    "asymmetryMagnitudeAxisDescription": MessageLookupByLibrary.simpleMessage(
      "Merged gauge chart showing asymmetry - Always enabled",
    ),
    "asymmetryMovementRatio": MessageLookupByLibrary.simpleMessage(
      "Movement Asymmetry (Ratio)",
    ),
    "attempts": MessageLookupByLibrary.simpleMessage("attempts"),
    "autoConnectingTo": m6,
    "averageLabel": m7,
    "axis": MessageLookupByLibrary.simpleMessage("Axis"),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "backButton": MessageLookupByLibrary.simpleMessage("Back"),
    "balance": MessageLookupByLibrary.simpleMessage("Balance"),
    "balanceGoal": MessageLookupByLibrary.simpleMessage("Balance Goal"),
    "balanceGoalDescription": MessageLookupByLibrary.simpleMessage(
      "Magnitude/axis heatmap for balance tracking",
    ),
    "balanceGoalHeatmap": MessageLookupByLibrary.simpleMessage(
      "Balance Goal (Heatmap)",
    ),
    "balanced": MessageLookupByLibrary.simpleMessage("Balanced (50/50)"),
    "balanced5050": MessageLookupByLibrary.simpleMessage("Balanced (50/50)"),
    "balancedProfile": MessageLookupByLibrary.simpleMessage("Balanced"),
    "balancedProfileDescription": MessageLookupByLibrary.simpleMessage(
      "Recommended default settings",
    ),
    "balancedStatus": MessageLookupByLibrary.simpleMessage("Balanced"),
    "battery": MessageLookupByLibrary.simpleMessage("Battery"),
    "batteryAt": m8,
    "batteryCritical": MessageLookupByLibrary.simpleMessage("Critical"),
    "batteryExcellent": MessageLookupByLibrary.simpleMessage("Excellent"),
    "batteryGood": MessageLookupByLibrary.simpleMessage("Good"),
    "batteryLevel": MessageLookupByLibrary.simpleMessage("Battery level"),
    "batteryLevelDescription": MessageLookupByLibrary.simpleMessage(
      "Battery level comparison of both watches",
    ),
    "batteryLevelLabel": MessageLookupByLibrary.simpleMessage("Battery level"),
    "batteryLow": MessageLookupByLibrary.simpleMessage("Low"),
    "batteryRssiFrequency": MessageLookupByLibrary.simpleMessage(
      "Battery/RSSI frequency",
    ),
    "batteryRssiFrequencyDescription": MessageLookupByLibrary.simpleMessage(
      "Recording interval for basic info",
    ),
    "bluetoothSettings": MessageLookupByLibrary.simpleMessage(
      "Bluetooth Settings",
    ),
    "bluetoothSettingsUpdated": MessageLookupByLibrary.simpleMessage(
      "Bluetooth settings updated",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelDfu": MessageLookupByLibrary.simpleMessage("Cancel DFU"),
    "cancelInstallation": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cannotCancel": m9,
    "cannotOpenEmailClient": MessageLookupByLibrary.simpleMessage(
      "Cannot open email client.",
    ),
    "changeThreshold": MessageLookupByLibrary.simpleMessage("Change threshold"),
    "changeThresholdLabel": MessageLookupByLibrary.simpleMessage(
      "Change threshold",
    ),
    "chartPreferences": MessageLookupByLibrary.simpleMessage(
      "Chart Preferences",
    ),
    "chartsEnabledCount": m10,
    "checkFrequency": MessageLookupByLibrary.simpleMessage("Check Frequency"),
    "checkFrequencyMinutes": MessageLookupByLibrary.simpleMessage("minutes"),
    "checkingFirmware": MessageLookupByLibrary.simpleMessage(
      "Checking firmware...",
    ),
    "chooseAPeriod": MessageLookupByLibrary.simpleMessage("Choose a period"),
    "chooseChartsToDisplay": MessageLookupByLibrary.simpleMessage(
      "Choose charts to display",
    ),
    "choosePeriod": MessageLookupByLibrary.simpleMessage("Choose a period"),
    "chooseSingleDate": MessageLookupByLibrary.simpleMessage(
      "Choose a single date",
    ),
    "chooseUniqueDate": MessageLookupByLibrary.simpleMessage(
      "Choose a single date",
    ),
    "classicModes": MessageLookupByLibrary.simpleMessage("Classic modes"),
    "clear": MessageLookupByLibrary.simpleMessage("Clear"),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "closeToGoal": MessageLookupByLibrary.simpleMessage("Close"),
    "collectionFrequency": MessageLookupByLibrary.simpleMessage(
      "Collection Frequency",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmDeletion": MessageLookupByLibrary.simpleMessage("Confirm Deletion"),
    "connect": MessageLookupByLibrary.simpleMessage("Connect"),
    "connected": MessageLookupByLibrary.simpleMessage("Connected"),
    "connectingTo": m11,
    "connection": MessageLookupByLibrary.simpleMessage("Connection"),
    "connectionAndDataRecording": MessageLookupByLibrary.simpleMessage(
      "Connection and data recording",
    ),
    "connectionDelay": MessageLookupByLibrary.simpleMessage("Connection delay"),
    "connectionDelayDescription": MessageLookupByLibrary.simpleMessage(
      "Maximum time to establish connection",
    ),
    "connectionError": m12,
    "connectionErrorBluetooth": MessageLookupByLibrary.simpleMessage(
      "Bluetooth error. Please check that Bluetooth is enabled.",
    ),
    "connectionErrorGatt": MessageLookupByLibrary.simpleMessage(
      "Bluetooth communication error. Please restart Bluetooth and try again.",
    ),
    "connectionErrorPermission": MessageLookupByLibrary.simpleMessage(
      "Bluetooth permission required. Please grant permissions in settings.",
    ),
    "connectionErrorTimeout": MessageLookupByLibrary.simpleMessage(
      "Connection timeout. Please make sure the device is nearby and try again.",
    ),
    "connectionErrorUnknown": MessageLookupByLibrary.simpleMessage(
      "Connection failed. Please try again.",
    ),
    "connectionMaxRetriesReached": MessageLookupByLibrary.simpleMessage(
      "Maximum connection attempts reached",
    ),
    "connectionRetrying": m13,
    "connectionSuccessFor": m14,
    "connectionSuccessful": MessageLookupByLibrary.simpleMessage(
      "Connection successful!",
    ),
    "connectionTimeout": MessageLookupByLibrary.simpleMessage(
      "Connection timeout. Check that the watch is nearby.",
    ),
    "connections": MessageLookupByLibrary.simpleMessage("Connections"),
    "contactPolicyContent": m15,
    "contactSupport": MessageLookupByLibrary.simpleMessage("Contact Support"),
    "contactSupportTitle": MessageLookupByLibrary.simpleMessage(
      "Contact Support",
    ),
    "contactTitle": MessageLookupByLibrary.simpleMessage("6. Contact"),
    "contactUsAt": m16,
    "credits": MessageLookupByLibrary.simpleMessage("Credits"),
    "currentBattery": m17,
    "currentMode": m18,
    "custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "customPeriod": MessageLookupByLibrary.simpleMessage("Custom period"),
    "customTimezone": MessageLookupByLibrary.simpleMessage("Custom timezone"),
    "customVibration": MessageLookupByLibrary.simpleMessage("Custom Vibration"),
    "dailyGoal": MessageLookupByLibrary.simpleMessage("Daily Goal"),
    "dailyIncrease": MessageLookupByLibrary.simpleMessage("Daily Increase"),
    "dailyIncreasePercent": MessageLookupByLibrary.simpleMessage(
      "Daily increase percentage",
    ),
    "darkGold": MessageLookupByLibrary.simpleMessage("Dark Gold"),
    "darkMint": MessageLookupByLibrary.simpleMessage("Dark Mint"),
    "darkTheme": MessageLookupByLibrary.simpleMessage("Dark Theme"),
    "dataCollectedContent": MessageLookupByLibrary.simpleMessage(
      "We collect data related to your activity in the application, including your name, preferences, rehabilitation goals, and data from connected watches. This information is only used to improve your experience and provide personalized tracking.",
    ),
    "dataCollectedTitle": MessageLookupByLibrary.simpleMessage(
      "2. Data Collected",
    ),
    "dataExportedSuccessfully": m19,
    "dataRecording": MessageLookupByLibrary.simpleMessage("Data recording"),
    "dataReset": MessageLookupByLibrary.simpleMessage("Data reset."),
    "dataSimulator": MessageLookupByLibrary.simpleMessage("Data Simulator"),
    "dataUsageContent": MessageLookupByLibrary.simpleMessage(
      "Data is used to display your progress, notify you when you reach your goals, and personalize app features. No data is shared with third parties without your consent.",
    ),
    "dataUsageTitle": MessageLookupByLibrary.simpleMessage("3. Data Usage"),
    "daysDataGenerated": m20,
    "defaultUserName": MessageLookupByLibrary.simpleMessage("User"),
    "defineGoalsAndVerification": MessageLookupByLibrary.simpleMessage(
      "Define goals and verification",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteAll": MessageLookupByLibrary.simpleMessage("Delete All"),
    "deleteAllDataWarning": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete ALL data?\n\nThis action is irreversible.",
    ),
    "deleteAllLocalData": MessageLookupByLibrary.simpleMessage(
      "Delete all local data",
    ),
    "deletePhoto": MessageLookupByLibrary.simpleMessage("Delete photo"),
    "deleteWatch": MessageLookupByLibrary.simpleMessage("Delete watch"),
    "deleteWatchQuestion": MessageLookupByLibrary.simpleMessage(
      "Delete the watch?",
    ),
    "deletingWatch": m21,
    "deletionInProgress": MessageLookupByLibrary.simpleMessage(
      "Deletion in progress...",
    ),
    "developedBy": MessageLookupByLibrary.simpleMessage(
      "Developed by Health & Tech Team – 2025",
    ),
    "deviceInfoRequest": m22,
    "deviceProgress": m23,
    "disabledChartsNotShown": MessageLookupByLibrary.simpleMessage(
      "Disabled charts will not be shown on the main screen",
    ),
    "disconnect": MessageLookupByLibrary.simpleMessage("Disconnect"),
    "disconnected": MessageLookupByLibrary.simpleMessage("Disconnected"),
    "disconnectionOf": m24,
    "displayedCharts": MessageLookupByLibrary.simpleMessage("Displayed Charts"),
    "doNotDisconnectWatch": MessageLookupByLibrary.simpleMessage(
      "Do not disconnect the watch",
    ),
    "downloadInProgress": MessageLookupByLibrary.simpleMessage(
      "Download in progress...",
    ),
    "downloadingInProgress": MessageLookupByLibrary.simpleMessage(
      "Downloading...",
    ),
    "downloadingUpdateFile": MessageLookupByLibrary.simpleMessage(
      "Downloading update file...",
    ),
    "duration": m25,
    "dynamicGoal": MessageLookupByLibrary.simpleMessage("Dynamic Goal"),
    "dynamicGoalConfig": MessageLookupByLibrary.simpleMessage(
      "Dynamic goal configuration",
    ),
    "dynamicGoalConfigDescription": MessageLookupByLibrary.simpleMessage(
      "The goal will be calculated based on the last X days with a daily increase of Y%.",
    ),
    "dynamicGoalDescription": MessageLookupByLibrary.simpleMessage(
      "Calculated over last days with daily increase",
    ),
    "dynamicGoalInfo": MessageLookupByLibrary.simpleMessage(
      "The goal will be automatically recalculated each day based on your progress.",
    ),
    "economy": MessageLookupByLibrary.simpleMessage("Economy"),
    "economyDescription": MessageLookupByLibrary.simpleMessage(
      "1 sample / 2s (~30/min)",
    ),
    "economyMax": MessageLookupByLibrary.simpleMessage("Max Economy"),
    "economyMaxDescription": MessageLookupByLibrary.simpleMessage(
      "1 sample / 5s (~12/min)",
    ),
    "editName": MessageLookupByLibrary.simpleMessage("Edit Name"),
    "editNameTitle": MessageLookupByLibrary.simpleMessage("Edit Name"),
    "emailClientOpened": MessageLookupByLibrary.simpleMessage(
      "Email client opened. Send your message.",
    ),
    "emptyList": MessageLookupByLibrary.simpleMessage("Empty list"),
    "endDate": MessageLookupByLibrary.simpleMessage("End date"),
    "endDateMustBeAfterStart": MessageLookupByLibrary.simpleMessage(
      "End date must be after start date",
    ),
    "enterCodeAbove": MessageLookupByLibrary.simpleMessage(
      "Enter the code above",
    ),
    "enterCodeToConfirm": MessageLookupByLibrary.simpleMessage(
      "Please enter this code to confirm:",
    ),
    "enterDecimalValue": MessageLookupByLibrary.simpleMessage(
      "Enter a decimal value",
    ),
    "enterValue": MessageLookupByLibrary.simpleMessage("Enter a value"),
    "enterValueBetween0And100": MessageLookupByLibrary.simpleMessage(
      "Enter a value between 0 and 100",
    ),
    "enterYourName": MessageLookupByLibrary.simpleMessage("Enter your name"),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "errorForgettingWatch": m26,
    "errorLabel": m27,
    "errorLoadingData": MessageLookupByLibrary.simpleMessage("Loading error"),
    "errorOccurred": m28,
    "events": MessageLookupByLibrary.simpleMessage("Events"),
    "eventsCount": m29,
    "everyDayCounts": MessageLookupByLibrary.simpleMessage("Every day counts!"),
    "experimentalTheme": MessageLookupByLibrary.simpleMessage(
      "Experimental Theme",
    ),
    "exportData": MessageLookupByLibrary.simpleMessage("Export data"),
    "exportError": m30,
    "exportInDevelopment": MessageLookupByLibrary.simpleMessage(
      "Export is under development...",
    ),
    "exportMyData": MessageLookupByLibrary.simpleMessage("Export My Data"),
    "fileIsEmpty": MessageLookupByLibrary.simpleMessage("File is empty"),
    "fileNotFound": MessageLookupByLibrary.simpleMessage("File not found"),
    "filterByDateOrPeriod": MessageLookupByLibrary.simpleMessage(
      "Filter by date or period",
    ),
    "finish": MessageLookupByLibrary.simpleMessage("Finish"),
    "firmware": MessageLookupByLibrary.simpleMessage("Firmware"),
    "firmwareFor": m31,
    "firmwareUpToDate": MessageLookupByLibrary.simpleMessage(
      "Firmware is up to date.",
    ),
    "firmwareUpdate": MessageLookupByLibrary.simpleMessage("Firmware update"),
    "firmwareUpdateInProgress": MessageLookupByLibrary.simpleMessage(
      "Firmware update in progress...",
    ),
    "firstNameExample": MessageLookupByLibrary.simpleMessage("Ex: Marie"),
    "firstNameMinLength": MessageLookupByLibrary.simpleMessage(
      "First name must be at least 2 characters",
    ),
    "fixedGoal": MessageLookupByLibrary.simpleMessage("Fixed Goal"),
    "fixedGoalConfig": MessageLookupByLibrary.simpleMessage(
      "Fixed goal configuration",
    ),
    "fixedGoalConfigDescription": MessageLookupByLibrary.simpleMessage(
      "Set the goal ratio to achieve directly.",
    ),
    "fixedGoalDescription": MessageLookupByLibrary.simpleMessage(
      "Set a fixed ratio to achieve",
    ),
    "forceSyncWithWatches": MessageLookupByLibrary.simpleMessage(
      "Force sync with watches",
    ),
    "forget": MessageLookupByLibrary.simpleMessage("Forget"),
    "forgetThisWatch": MessageLookupByLibrary.simpleMessage(
      "Forget This Watch",
    ),
    "forgetWatchDescription": MessageLookupByLibrary.simpleMessage(
      "This action will:\n• Disconnect the watch\n• Delete binding data\n• Clear connection history\n\nYou will need to reconnect it manually.",
    ),
    "forgetWatchQuestion": m32,
    "forgetWatchTitle": m33,
    "format24Hours": MessageLookupByLibrary.simpleMessage("24-hour format"),
    "frequencyLabel": MessageLookupByLibrary.simpleMessage(
      "Frequency (minutes)",
    ),
    "fromToDate": m34,
    "fullName": MessageLookupByLibrary.simpleMessage("Full name"),
    "generate30Days": MessageLookupByLibrary.simpleMessage("Generate 30 days"),
    "generate7Days": MessageLookupByLibrary.simpleMessage("Generate 7 days"),
    "generateDays": m35,
    "generatingAsymmetry": m36,
    "generatingDaysData": m37,
    "goal": MessageLookupByLibrary.simpleMessage("Goal"),
    "goalConfiguration": MessageLookupByLibrary.simpleMessage(
      "Goal Configuration",
    ),
    "goalNotReached": m38,
    "goalOfTheDay": MessageLookupByLibrary.simpleMessage("Goal of the day:"),
    "goalRatio": MessageLookupByLibrary.simpleMessage("Goal Ratio"),
    "goalReached": MessageLookupByLibrary.simpleMessage("Goal reached"),
    "goalSettings": MessageLookupByLibrary.simpleMessage("Goal Settings"),
    "goalType": MessageLookupByLibrary.simpleMessage("Goal type"),
    "hello": MessageLookupByLibrary.simpleMessage("Hello! "),
    "historicalData": MessageLookupByLibrary.simpleMessage("Historical Data"),
    "history": MessageLookupByLibrary.simpleMessage("History"),
    "imageSelectionError": m39,
    "imageSelectionErrorMessage": m40,
    "importData": MessageLookupByLibrary.simpleMessage("Import Data"),
    "importError": m41,
    "infiniTimeSensors": MessageLookupByLibrary.simpleMessage(
      "InfiniTime Sensors",
    ),
    "infinitimeSensors": MessageLookupByLibrary.simpleMessage(
      "InfiniTime Sensors",
    ),
    "information": MessageLookupByLibrary.simpleMessage("Information"),
    "initializationError": m42,
    "install": MessageLookupByLibrary.simpleMessage("Install"),
    "installFirmware": MessageLookupByLibrary.simpleMessage("Install Firmware"),
    "installFirmwareOnBothWatches": MessageLookupByLibrary.simpleMessage(
      "Install firmware on both watches",
    ),
    "installOnWatch": MessageLookupByLibrary.simpleMessage("Install on watch"),
    "installOnWatches": m43,
    "installationCancelledByUser": MessageLookupByLibrary.simpleMessage(
      "Installation cancelled by user.",
    ),
    "installingOnDevice": m44,
    "intense": MessageLookupByLibrary.simpleMessage("Intense"),
    "interval": MessageLookupByLibrary.simpleMessage("Interval"),
    "intervalLabel": MessageLookupByLibrary.simpleMessage("Interval"),
    "intervalMs": MessageLookupByLibrary.simpleMessage("ms (seconds)"),
    "intervalMsValue": m45,
    "introductionContent": MessageLookupByLibrary.simpleMessage(
      "We are committed to protecting your privacy. This policy explains what data we collect, why, and how it is used within our application.",
    ),
    "introductionTitle": MessageLookupByLibrary.simpleMessage(
      "1. Introduction",
    ),
    "invalidFileFormat": m46,
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "languageChangedTo": m47,
    "languageChangedToName": m48,
    "last30Days": MessageLookupByLibrary.simpleMessage("Last 30 days"),
    "last7Days": MessageLookupByLibrary.simpleMessage("Last 7 days"),
    "lastUpdated": m49,
    "learnMore": MessageLookupByLibrary.simpleMessage("Learn more"),
    "left": MessageLookupByLibrary.simpleMessage("Left"),
    "leftDominanceStatus": MessageLookupByLibrary.simpleMessage(
      "Left dominance",
    ),
    "leftDominant": m50,
    "leftDominant70": MessageLookupByLibrary.simpleMessage(
      "Left Dominant (70%)",
    ),
    "leftSide": MessageLookupByLibrary.simpleMessage("Left"),
    "leftWatch": MessageLookupByLibrary.simpleMessage("Left Watch"),
    "leftWatchConnected": MessageLookupByLibrary.simpleMessage(
      "Left watch connected",
    ),
    "leftWatchDisconnected": MessageLookupByLibrary.simpleMessage(
      "Left watch disconnected",
    ),
    "letsConfigureProfile": MessageLookupByLibrary.simpleMessage(
      "Let\'s configure your profile",
    ),
    "light": MessageLookupByLibrary.simpleMessage("Light"),
    "lightGold": MessageLookupByLibrary.simpleMessage("Light Gold"),
    "lightMint": MessageLookupByLibrary.simpleMessage("Light Mint"),
    "lightTheme": MessageLookupByLibrary.simpleMessage("Light Theme"),
    "loadingFirmwares": MessageLookupByLibrary.simpleMessage(
      "Loading firmwares...",
    ),
    "loadingTakingLonger": MessageLookupByLibrary.simpleMessage(
      "Loading is taking longer than expected...\nPlease wait or restart the app.",
    ),
    "localData": MessageLookupByLibrary.simpleMessage("Local data"),
    "magnitude": MessageLookupByLibrary.simpleMessage("Magnitude"),
    "magnitudeValue": m51,
    "manageNameAndPhoto": MessageLookupByLibrary.simpleMessage(
      "Manage name and profile photo",
    ),
    "maxSamplesPerFlush": MessageLookupByLibrary.simpleMessage(
      "Max samples per flush",
    ),
    "maxSamplesPerFlushLabel": MessageLookupByLibrary.simpleMessage(
      "Max samples per flush",
    ),
    "maximum": MessageLookupByLibrary.simpleMessage("Maximum"),
    "maximumDescription": MessageLookupByLibrary.simpleMessage(
      "Record everything (~600/min)",
    ),
    "mbPerDay": m52,
    "message": MessageLookupByLibrary.simpleMessage("Message"),
    "messageSentToSupport": MessageLookupByLibrary.simpleMessage(
      "Message sent to support.",
    ),
    "metrics": MessageLookupByLibrary.simpleMessage("Metrics"),
    "minutes": MessageLookupByLibrary.simpleMessage("minutes"),
    "modeAggregate": MessageLookupByLibrary.simpleMessage("Average"),
    "modeAggregateDescription": MessageLookupByLibrary.simpleMessage(
      "Calculates average over interval",
    ),
    "modeAll": MessageLookupByLibrary.simpleMessage("All"),
    "modeAllDescription": MessageLookupByLibrary.simpleMessage(
      "Records all received data",
    ),
    "modeInterval": MessageLookupByLibrary.simpleMessage("Interval"),
    "modeIntervalDescription": MessageLookupByLibrary.simpleMessage(
      "Keeps one sample per time interval",
    ),
    "modePerUnit": MessageLookupByLibrary.simpleMessage("Per unit"),
    "modePerUnitDescription": MessageLookupByLibrary.simpleMessage(
      "Number of records per hour/minute/second",
    ),
    "modeThreshold": MessageLookupByLibrary.simpleMessage("Threshold"),
    "modeThresholdDescription": MessageLookupByLibrary.simpleMessage(
      "Records only during significant changes",
    ),
    "moderate": MessageLookupByLibrary.simpleMessage("Moderate"),
    "movement": MessageLookupByLibrary.simpleMessage("Movement"),
    "movementAsymmetry": MessageLookupByLibrary.simpleMessage(
      "Movement Asymmetry",
    ),
    "movementAsymmetryDescription": MessageLookupByLibrary.simpleMessage(
      "Asymmetry ratio chart with Magnitude/Axis filter and goal",
    ),
    "movementFrequency": MessageLookupByLibrary.simpleMessage(
      "Movement frequency",
    ),
    "movementFrequencyDescription": MessageLookupByLibrary.simpleMessage(
      "Recording interval for movement data",
    ),
    "movementSampling": MessageLookupByLibrary.simpleMessage(
      "Movement Sampling",
    ),
    "movementSamplingTitle": MessageLookupByLibrary.simpleMessage(
      "Movement Sampling",
    ),
    "movements": MessageLookupByLibrary.simpleMessage("Movements"),
    "nameCannotBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Name cannot be empty",
    ),
    "navHistory": MessageLookupByLibrary.simpleMessage("History"),
    "navHome": MessageLookupByLibrary.simpleMessage("Home"),
    "navProfile": MessageLookupByLibrary.simpleMessage("Profile"),
    "navSettings": MessageLookupByLibrary.simpleMessage("Settings"),
    "neverSynced": MessageLookupByLibrary.simpleMessage("Never synced"),
    "neverSynchronized": MessageLookupByLibrary.simpleMessage(
      "Never synchronized",
    ),
    "newName": MessageLookupByLibrary.simpleMessage("New name"),
    "next": MessageLookupByLibrary.simpleMessage("Next"),
    "nextButton": MessageLookupByLibrary.simpleMessage("Next"),
    "noDataAvailable": MessageLookupByLibrary.simpleMessage(
      "No data available",
    ),
    "noDataForDay": MessageLookupByLibrary.simpleMessage(
      "No data available for this day",
    ),
    "noFirmwareAvailable": MessageLookupByLibrary.simpleMessage(
      "No firmware available",
    ),
    "noLegendData": MessageLookupByLibrary.simpleMessage("None"),
    "noProductInWishlist": MessageLookupByLibrary.simpleMessage(
      "Sorry, you have no product in your wishlist",
    ),
    "noWatchConnected": MessageLookupByLibrary.simpleMessage(
      "No watch connected.\nConnect at least one watch to sync time.",
    ),
    "normal": MessageLookupByLibrary.simpleMessage("Normal"),
    "normalDescription": MessageLookupByLibrary.simpleMessage(
      "1 sample / second (~60/min)",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "notificationsAndVibrations": MessageLookupByLibrary.simpleMessage(
      "Notifications & Vibrations",
    ),
    "numberMustBeBetween1And10": MessageLookupByLibrary.simpleMessage(
      "Number must be between 1 and 10",
    ),
    "numberOfDays": MessageLookupByLibrary.simpleMessage("Number of days"),
    "numberOfRecords": MessageLookupByLibrary.simpleMessage(
      "Number of records",
    ),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "oops": MessageLookupByLibrary.simpleMessage("Oops!"),
    "pdfGeneratedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "PDF generated successfully",
    ),
    "pdfGeneratedWithCharts": m53,
    "pdfGenerationError": m54,
    "per": MessageLookupByLibrary.simpleMessage("Per"),
    "perTimeUnit": MessageLookupByLibrary.simpleMessage("Per time unit"),
    "perTimeUnitDescription": MessageLookupByLibrary.simpleMessage(
      "Define the number of records per hour/minute/second",
    ),
    "percentageDecimal": MessageLookupByLibrary.simpleMessage("Percentage (%)"),
    "performanceProfile": MessageLookupByLibrary.simpleMessage("Performance"),
    "performanceProfileDescription": MessageLookupByLibrary.simpleMessage(
      "Fast connections and frequent data",
    ),
    "periodDay": MessageLookupByLibrary.simpleMessage("Day"),
    "periodDays": MessageLookupByLibrary.simpleMessage(
      "Number of days in period",
    ),
    "periodDaysUnit": MessageLookupByLibrary.simpleMessage("days"),
    "periodLabel": m55,
    "periodMonth": MessageLookupByLibrary.simpleMessage("Month"),
    "periodWeek": MessageLookupByLibrary.simpleMessage("Week"),
    "periodicCheckFrequency": MessageLookupByLibrary.simpleMessage(
      "Periodic check frequency",
    ),
    "periodicCheckFrequencyDescription": MessageLookupByLibrary.simpleMessage(
      "Set how often the system checks if the goal is reached.",
    ),
    "permissionsRequired": MessageLookupByLibrary.simpleMessage(
      "Permissions Required",
    ),
    "phoneTimezone": MessageLookupByLibrary.simpleMessage("Phone timezone"),
    "pinetimePosition": m56,
    "pleaseEnterFirstName": MessageLookupByLibrary.simpleMessage(
      "Please enter your first name",
    ),
    "pleaseEnterMessage": MessageLookupByLibrary.simpleMessage(
      "Please enter a message.",
    ),
    "pleaseEnterSubject": MessageLookupByLibrary.simpleMessage(
      "Please enter a subject.",
    ),
    "pleaseWaitBetweenConnections": MessageLookupByLibrary.simpleMessage(
      "Please wait between connection attempts",
    ),
    "powerSaving": MessageLookupByLibrary.simpleMessage("Power Saving"),
    "powerSavingDescription": MessageLookupByLibrary.simpleMessage(
      "Spaced connections to preserve battery",
    ),
    "precise": MessageLookupByLibrary.simpleMessage("Precise"),
    "preciseDescription": MessageLookupByLibrary.simpleMessage(
      "2 samples / second (~120/min)",
    ),
    "presetProfiles": MessageLookupByLibrary.simpleMessage("Preset profiles"),
    "presets": MessageLookupByLibrary.simpleMessage("Presets"),
    "preview": MessageLookupByLibrary.simpleMessage("Preview"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "privacyPolicyContent": MessageLookupByLibrary.simpleMessage(
      "Privacy policy will be added here.",
    ),
    "privacyPolicyMenuItem": MessageLookupByLibrary.simpleMessage(
      "Privacy Policy",
    ),
    "privacyPolicyTitle": MessageLookupByLibrary.simpleMessage(
      "Privacy Policy",
    ),
    "privacyPolicyWillBeAdded": MessageLookupByLibrary.simpleMessage(
      "The privacy policy will be added here.",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profilePhotoUpdated": MessageLookupByLibrary.simpleMessage(
      "Profile photo updated!",
    ),
    "profileTitle": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileUpdated": MessageLookupByLibrary.simpleMessage(
      "Profile updated successfully",
    ),
    "profileUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Profile updated successfully",
    ),
    "pushUpdate": MessageLookupByLibrary.simpleMessage("Push Update"),
    "ratioLabel": MessageLookupByLibrary.simpleMessage("Ratio:"),
    "ratioPercent": MessageLookupByLibrary.simpleMessage("Ratio (%)"),
    "readyForRehabilitation": MessageLookupByLibrary.simpleMessage(
      "Ready to take the next steps in your rehabilitation?",
    ),
    "receiveDailyReminders": MessageLookupByLibrary.simpleMessage(
      "Receive daily reminders",
    ),
    "reconnect": MessageLookupByLibrary.simpleMessage("Reconnect"),
    "reconnectionAttempts": MessageLookupByLibrary.simpleMessage(
      "Reconnection attempts",
    ),
    "reconnectionAttemptsDescription": MessageLookupByLibrary.simpleMessage(
      "Number of retries on failure",
    ),
    "reconnectionInProgressFor": m57,
    "recordingFrequency": MessageLookupByLibrary.simpleMessage(
      "Recording frequency",
    ),
    "recordingFrequencyDescription": MessageLookupByLibrary.simpleMessage(
      "Reduce the volume of stored movement data. Less frequent sampling saves storage space.",
    ),
    "recordsCount": m58,
    "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "reload": MessageLookupByLibrary.simpleMessage("Reload"),
    "removedFromFavorites": m59,
    "removingWatch": m60,
    "renameWatch": MessageLookupByLibrary.simpleMessage("Rename watch"),
    "resetAllConfigurations": MessageLookupByLibrary.simpleMessage(
      "Reset all configurations",
    ),
    "resetAppAndSettings": MessageLookupByLibrary.simpleMessage(
      "Reset app and settings",
    ),
    "resetConfigurationsQuestion": MessageLookupByLibrary.simpleMessage(
      "Reset configurations?",
    ),
    "resetData": MessageLookupByLibrary.simpleMessage("Reset Data"),
    "resetDataQuestion": MessageLookupByLibrary.simpleMessage("Reset data?"),
    "resetError": m61,
    "resetFilter": MessageLookupByLibrary.simpleMessage("Reset filter"),
    "resetSettings": MessageLookupByLibrary.simpleMessage("Reset Settings"),
    "resetTheFilter": MessageLookupByLibrary.simpleMessage("Reset the filter"),
    "rest": MessageLookupByLibrary.simpleMessage("Rest"),
    "restartScan": MessageLookupByLibrary.simpleMessage("Restart Scan"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "right": MessageLookupByLibrary.simpleMessage("Right"),
    "rightDominanceStatus": MessageLookupByLibrary.simpleMessage(
      "Right dominance",
    ),
    "rightDominant": m62,
    "rightDominant70": MessageLookupByLibrary.simpleMessage(
      "Right Dominant (70%)",
    ),
    "rightSide": MessageLookupByLibrary.simpleMessage("Right"),
    "rightWatch": MessageLookupByLibrary.simpleMessage("Right Watch"),
    "rightWatchConnected": MessageLookupByLibrary.simpleMessage(
      "Right watch connected",
    ),
    "rightWatchDisconnected": MessageLookupByLibrary.simpleMessage(
      "Right watch disconnected",
    ),
    "samplesPerFlushUnit": m63,
    "samplesPerHour": m64,
    "samplesPerHourPerWatch": m65,
    "samplesPerMinutePerWatch": m66,
    "samplesUnit": MessageLookupByLibrary.simpleMessage("samples"),
    "samplingMode": MessageLookupByLibrary.simpleMessage("Sampling mode"),
    "samplingModeLabel": MessageLookupByLibrary.simpleMessage("Sampling mode"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveToFile": MessageLookupByLibrary.simpleMessage("Save to file"),
    "scanDuration": MessageLookupByLibrary.simpleMessage("Scan duration"),
    "scanDurationDescription": MessageLookupByLibrary.simpleMessage(
      "Time to wait to find watches",
    ),
    "scanPineTime": MessageLookupByLibrary.simpleMessage("Scan a PineTime"),
    "searchDevice": MessageLookupByLibrary.simpleMessage("Search Device"),
    "seconds": MessageLookupByLibrary.simpleMessage("seconds"),
    "securityContent": MessageLookupByLibrary.simpleMessage(
      "Your data is stored locally on your device. We do not transmit any information to remote servers without your explicit authorization.",
    ),
    "securityTitle": MessageLookupByLibrary.simpleMessage("4. Security"),
    "selectChartsToDisplay": MessageLookupByLibrary.simpleMessage(
      "Select charts to display",
    ),
    "selectDateRange": MessageLookupByLibrary.simpleMessage(
      "Select a date range",
    ),
    "selectEndDate": MessageLookupByLibrary.simpleMessage("Select end date"),
    "selectStartDate": MessageLookupByLibrary.simpleMessage(
      "Select start date",
    ),
    "selectThisMode": MessageLookupByLibrary.simpleMessage("Select this mode"),
    "selectTimezone": MessageLookupByLibrary.simpleMessage("Select timezone"),
    "sendConfigToWatches": MessageLookupByLibrary.simpleMessage(
      "Send config to watches",
    ),
    "sendMessage": MessageLookupByLibrary.simpleMessage("Send Message"),
    "sendMessageToSupport": MessageLookupByLibrary.simpleMessage(
      "Send a message to our support team:",
    ),
    "sendingInProgress": MessageLookupByLibrary.simpleMessage("Sending..."),
    "sensorTrackingDescription": MessageLookupByLibrary.simpleMessage(
      "Complete tracking of battery, heart rate, steps and other metrics collected from your PineTime watches.",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "settingsButton": MessageLookupByLibrary.simpleMessage("Settings"),
    "settingsImportedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Settings imported successfully!",
    ),
    "settingsNotLoaded": MessageLookupByLibrary.simpleMessage(
      "Settings not loaded. Cannot export.",
    ),
    "sevenDays": MessageLookupByLibrary.simpleMessage("7 days"),
    "share": MessageLookupByLibrary.simpleMessage("Share"),
    "shareMyData": MessageLookupByLibrary.simpleMessage("Share My Data"),
    "showStats": MessageLookupByLibrary.simpleMessage("Show Stats"),
    "sideInfoDescription": MessageLookupByLibrary.simpleMessage(
      "This information will help us personalize your rehabilitation tracking",
    ),
    "simulator": MessageLookupByLibrary.simpleMessage("Simulator"),
    "sorryNoProductWishlist": MessageLookupByLibrary.simpleMessage(
      "Sorry, you have no product in your wishlist",
    ),
    "speedKbps": m67,
    "startAdding": MessageLookupByLibrary.simpleMessage("Start Adding"),
    "startAddingButton": MessageLookupByLibrary.simpleMessage("Start Adding"),
    "startButton": MessageLookupByLibrary.simpleMessage("Start"),
    "startDate": MessageLookupByLibrary.simpleMessage("Start date"),
    "startScan": MessageLookupByLibrary.simpleMessage("Start Scan"),
    "statsDisplayedInConsole": MessageLookupByLibrary.simpleMessage(
      "Stats displayed in console",
    ),
    "stepCount": MessageLookupByLibrary.simpleMessage("Step Count"),
    "stepCountDescription": MessageLookupByLibrary.simpleMessage(
      "Step count comparison between both arms",
    ),
    "steps": MessageLookupByLibrary.simpleMessage("Steps"),
    "stepsUnit": m68,
    "storageEstimate": MessageLookupByLibrary.simpleMessage("Storage estimate"),
    "subject": MessageLookupByLibrary.simpleMessage("Subject"),
    "support": MessageLookupByLibrary.simpleMessage("Support"),
    "supportEmail": MessageLookupByLibrary.simpleMessage("kdetou@etu.uqac.ca"),
    "supportEmailLabel": MessageLookupByLibrary.simpleMessage("Support Email"),
    "syncNow": MessageLookupByLibrary.simpleMessage("Sync now"),
    "syncSettings": MessageLookupByLibrary.simpleMessage(
      "Synchronization Settings",
    ),
    "syncedAgo": m69,
    "syncedJustNow": MessageLookupByLibrary.simpleMessage("Synced just now"),
    "synchronization": MessageLookupByLibrary.simpleMessage("Synchronization"),
    "syncing": MessageLookupByLibrary.simpleMessage("Syncing..."),
    "systemInformation": MessageLookupByLibrary.simpleMessage(
      "System Information",
    ),
    "systemTheme": MessageLookupByLibrary.simpleMessage("System Theme"),
    "tapToChangePhoto": MessageLookupByLibrary.simpleMessage(
      "Tap to change photo",
    ),
    "termsOfUse": MessageLookupByLibrary.simpleMessage("Terms of Use"),
    "termsOfUseContent": MessageLookupByLibrary.simpleMessage(
      "Terms of use will be added here.",
    ),
    "termsOfUseWillBeAdded": MessageLookupByLibrary.simpleMessage(
      "The terms of use will be added here.",
    ),
    "testModeOnly": MessageLookupByLibrary.simpleMessage(
      "Test Mode Only\n\nGenerates fake data to test charts.",
    ),
    "testVibration": MessageLookupByLibrary.simpleMessage("Test vibration"),
    "thankYouForUsing": MessageLookupByLibrary.simpleMessage(
      "Thank you for using our application!",
    ),
    "theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "themeExperimental": MessageLookupByLibrary.simpleMessage("Experimental"),
    "themeExperimentalDescription": MessageLookupByLibrary.simpleMessage(
      "Advanced visual mode for testing",
    ),
    "themeGoldDark": MessageLookupByLibrary.simpleMessage("Gold (Dark)"),
    "themeGoldDarkDescription": MessageLookupByLibrary.simpleMessage(
      "Elegant dark theme with gold accents",
    ),
    "themeGoldLight": MessageLookupByLibrary.simpleMessage("Gold (Light)"),
    "themeGoldLightDescription": MessageLookupByLibrary.simpleMessage(
      "Elegant light theme with gold accents",
    ),
    "themeMintDark": MessageLookupByLibrary.simpleMessage("Mint (Dark)"),
    "themeMintDarkDescription": MessageLookupByLibrary.simpleMessage(
      "Dark theme with a mint tint",
    ),
    "themeMintLight": MessageLookupByLibrary.simpleMessage("Mint (Light)"),
    "themeMintLightDescription": MessageLookupByLibrary.simpleMessage(
      "Light theme with a mint green tint",
    ),
    "themeSystem": MessageLookupByLibrary.simpleMessage("Follow System"),
    "themeSystemDescription": MessageLookupByLibrary.simpleMessage(
      "Automatically adapts theme to device settings",
    ),
    "themeUpdated": MessageLookupByLibrary.simpleMessage("Theme updated."),
    "therapyConfiguration": MessageLookupByLibrary.simpleMessage(
      "Therapy Configuration",
    ),
    "thirtyDays": MessageLookupByLibrary.simpleMessage("30 days"),
    "thisActionIsPermanent": MessageLookupByLibrary.simpleMessage(
      "This action is permanent.",
    ),
    "thresholdUnit": MessageLookupByLibrary.simpleMessage("g"),
    "timeConfiguration": MessageLookupByLibrary.simpleMessage(
      "Time configuration",
    ),
    "timeConfigurationDescription": MessageLookupByLibrary.simpleMessage(
      "Customize time synchronization settings with your watches",
    ),
    "timeSyncInfo": MessageLookupByLibrary.simpleMessage(
      "Time is automatically synced on each watch connection. Use manual sync after traveling to a different timezone or during daylight saving time changes (summer/winter).",
    ),
    "timeSyncedFor": m70,
    "timeSynchronization": MessageLookupByLibrary.simpleMessage(
      "Time synchronization",
    ),
    "timeUnitHour": MessageLookupByLibrary.simpleMessage("Hour"),
    "timeUnitMinute": MessageLookupByLibrary.simpleMessage("Minute"),
    "timeUnitSecond": MessageLookupByLibrary.simpleMessage("Second"),
    "timezoneFormatSync": MessageLookupByLibrary.simpleMessage(
      "Timezone, time format and synchronization",
    ),
    "today": MessageLookupByLibrary.simpleMessage("Today"),
    "tryAgainOrContact": MessageLookupByLibrary.simpleMessage(
      "Please try again or contact support.",
    ),
    "typeDisplay": m71,
    "typeLabel": m72,
    "unbalanced": MessageLookupByLibrary.simpleMessage("Unbalanced"),
    "updateComplete": MessageLookupByLibrary.simpleMessage("Update Complete"),
    "updateErrorOccurred": MessageLookupByLibrary.simpleMessage(
      "An error occurred during the update.",
    ),
    "updateFailed": MessageLookupByLibrary.simpleMessage("Error"),
    "updateInstalledSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Update installed successfully!",
    ),
    "updateWatch": m73,
    "updateWatchTitle": m74,
    "updateWatches": MessageLookupByLibrary.simpleMessage("Update Watches"),
    "updating": MessageLookupByLibrary.simpleMessage("Updating"),
    "useCustomTimezone": MessageLookupByLibrary.simpleMessage(
      "Use custom timezone",
    ),
    "usePhoneTimezone": MessageLookupByLibrary.simpleMessage(
      "Use phone timezone",
    ),
    "userName": MessageLookupByLibrary.simpleMessage("Username"),
    "versionBuild": m75,
    "vibrationCount": MessageLookupByLibrary.simpleMessage("Vibration count"),
    "vibrationCountDescription": MessageLookupByLibrary.simpleMessage(
      "The watch will vibrate this many times for each notification.",
    ),
    "vibrationTestInProgress": MessageLookupByLibrary.simpleMessage(
      "Vibration test in progress...",
    ),
    "vibrationTested": MessageLookupByLibrary.simpleMessage(
      "Vibration tested successfully",
    ),
    "vibrationTestedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Vibration tested successfully",
    ),
    "vibrationType": MessageLookupByLibrary.simpleMessage("Vibration type"),
    "watchConnected": MessageLookupByLibrary.simpleMessage("Connected"),
    "watchDeleted": MessageLookupByLibrary.simpleMessage("Watch deleted."),
    "watchForgottenSuccessfully": m76,
    "watchLeftRight": m77,
    "watchNotConnected": MessageLookupByLibrary.simpleMessage("Not connected"),
    "watchSide": m78,
    "watchStatus": m79,
    "watchSynced": MessageLookupByLibrary.simpleMessage("Watch synced"),
    "watchWillRestart": MessageLookupByLibrary.simpleMessage(
      "Your watch will restart automatically.",
    ),
    "watches": MessageLookupByLibrary.simpleMessage("Watches"),
    "watchesWillBeUpdated": m80,
    "watchfaceInstallation": MessageLookupByLibrary.simpleMessage(
      "Watchface Installation",
    ),
    "weekdayFri": MessageLookupByLibrary.simpleMessage("Fri"),
    "weekdayMon": MessageLookupByLibrary.simpleMessage("Mon"),
    "weekdaySat": MessageLookupByLibrary.simpleMessage("Sat"),
    "weekdaySun": MessageLookupByLibrary.simpleMessage("Sun"),
    "weekdayThu": MessageLookupByLibrary.simpleMessage("Thu"),
    "weekdayTue": MessageLookupByLibrary.simpleMessage("Tue"),
    "weekdayWed": MessageLookupByLibrary.simpleMessage("Wed"),
    "welcomeTitle": MessageLookupByLibrary.simpleMessage("Welcome!"),
    "whatIsYourName": MessageLookupByLibrary.simpleMessage(
      "What is your name?",
    ),
    "whatToUpdate": MessageLookupByLibrary.simpleMessage(
      "What would you like to update?",
    ),
    "whichSideAffected": MessageLookupByLibrary.simpleMessage(
      "Which is your affected side?",
    ),
    "yesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
    "yourFirstName": MessageLookupByLibrary.simpleMessage("Your first name"),
    "yourRightsContent": MessageLookupByLibrary.simpleMessage(
      "You can view, modify, or delete your data at any time from the application. For any specific request, you can contact our support.",
    ),
    "yourRightsTitle": MessageLookupByLibrary.simpleMessage("5. Your Rights"),
  };
}
