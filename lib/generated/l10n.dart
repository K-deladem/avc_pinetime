// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `=== GÉNÉRAL ===`
  String get _GENERAL {
    return Intl.message(
      '=== GÉNÉRAL ===',
      name: '_GENERAL',
      desc: '',
      args: [],
    );
  }

  /// `InfiniTime Companion`
  String get appTitle {
    return Intl.message(
      'InfiniTime Companion',
      name: 'appTitle',
      desc: 'Le titre de l\'application',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `Empty list`
  String get emptyList {
    return Intl.message('Empty list', name: 'emptyList', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Apply`
  String get apply {
    return Intl.message('Apply', name: 'apply', desc: '', args: []);
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Finish`
  String get finish {
    return Intl.message('Finish', name: 'finish', desc: '', args: []);
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `Refresh`
  String get refresh {
    return Intl.message('Refresh', name: 'refresh', desc: '', args: []);
  }

  /// `Clear`
  String get clear {
    return Intl.message('Clear', name: 'clear', desc: '', args: []);
  }

  /// `=== NAVIGATION ===`
  String get _NAVIGATION {
    return Intl.message(
      '=== NAVIGATION ===',
      name: '_NAVIGATION',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get navHome {
    return Intl.message('Home', name: 'navHome', desc: '', args: []);
  }

  /// `History`
  String get navHistory {
    return Intl.message('History', name: 'navHistory', desc: '', args: []);
  }

  /// `Profile`
  String get navProfile {
    return Intl.message('Profile', name: 'navProfile', desc: '', args: []);
  }

  /// `Settings`
  String get navSettings {
    return Intl.message('Settings', name: 'navSettings', desc: '', args: []);
  }

  /// `=== HOME SCREEN ===`
  String get _HOME_SCREEN {
    return Intl.message(
      '=== HOME SCREEN ===',
      name: '_HOME_SCREEN',
      desc: '',
      args: [],
    );
  }

  /// `Historical Data`
  String get historicalData {
    return Intl.message(
      'Historical Data',
      name: 'historicalData',
      desc: '',
      args: [],
    );
  }

  /// `InfiniTime Sensors`
  String get infinitimeSensors {
    return Intl.message(
      'InfiniTime Sensors',
      name: 'infinitimeSensors',
      desc: '',
      args: [],
    );
  }

  /// `Learn more`
  String get learnMore {
    return Intl.message('Learn more', name: 'learnMore', desc: '', args: []);
  }

  /// `Asymmetry`
  String get asymmetry {
    return Intl.message('Asymmetry', name: 'asymmetry', desc: '', args: []);
  }

  /// `Battery level`
  String get batteryLevel {
    return Intl.message(
      'Battery level',
      name: 'batteryLevel',
      desc: '',
      args: [],
    );
  }

  /// `Balance Goal`
  String get balanceGoal {
    return Intl.message(
      'Balance Goal',
      name: 'balanceGoal',
      desc: '',
      args: [],
    );
  }

  /// `Step Count`
  String get stepCount {
    return Intl.message('Step Count', name: 'stepCount', desc: '', args: []);
  }

  /// `Forget watch {position}?`
  String forgetWatchTitle(String position) {
    return Intl.message(
      'Forget watch $position?',
      name: 'forgetWatchTitle',
      desc: '',
      args: [position],
    );
  }

  /// `Forget`
  String get forget {
    return Intl.message('Forget', name: 'forget', desc: '', args: []);
  }

  /// `Removing watch {position}...`
  String removingWatch(String position) {
    return Intl.message(
      'Removing watch $position...',
      name: 'removingWatch',
      desc: '',
      args: [position],
    );
  }

  /// `Update watch {side}`
  String updateWatchTitle(String side) {
    return Intl.message(
      'Update watch $side',
      name: 'updateWatchTitle',
      desc: '',
      args: [side],
    );
  }

  /// `What would you like to update?`
  String get whatToUpdate {
    return Intl.message(
      'What would you like to update?',
      name: 'whatToUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Firmware`
  String get firmware {
    return Intl.message('Firmware', name: 'firmware', desc: '', args: []);
  }

  /// `Simulator`
  String get simulator {
    return Intl.message('Simulator', name: 'simulator', desc: '', args: []);
  }

  /// `Data Simulator`
  String get dataSimulator {
    return Intl.message(
      'Data Simulator',
      name: 'dataSimulator',
      desc: '',
      args: [],
    );
  }

  /// `Generate 7 days`
  String get generate7Days {
    return Intl.message(
      'Generate 7 days',
      name: 'generate7Days',
      desc: '',
      args: [],
    );
  }

  /// `Generate 30 days`
  String get generate30Days {
    return Intl.message(
      'Generate 30 days',
      name: 'generate30Days',
      desc: '',
      args: [],
    );
  }

  /// `Left Dominant (70%)`
  String get leftDominant70 {
    return Intl.message(
      'Left Dominant (70%)',
      name: 'leftDominant70',
      desc: '',
      args: [],
    );
  }

  /// `Right Dominant (70%)`
  String get rightDominant70 {
    return Intl.message(
      'Right Dominant (70%)',
      name: 'rightDominant70',
      desc: '',
      args: [],
    );
  }

  /// `Balanced (50/50)`
  String get balanced5050 {
    return Intl.message(
      'Balanced (50/50)',
      name: 'balanced5050',
      desc: '',
      args: [],
    );
  }

  /// `Show Stats`
  String get showStats {
    return Intl.message('Show Stats', name: 'showStats', desc: '', args: []);
  }

  /// `Delete All`
  String get deleteAll {
    return Intl.message('Delete All', name: 'deleteAll', desc: '', args: []);
  }

  /// `Confirm Deletion`
  String get confirmDeletion {
    return Intl.message(
      'Confirm Deletion',
      name: 'confirmDeletion',
      desc: '',
      args: [],
    );
  }

  /// `=== HISTORY SCREEN ===`
  String get _HISTORY_SCREEN {
    return Intl.message(
      '=== HISTORY SCREEN ===',
      name: '_HISTORY_SCREEN',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get history {
    return Intl.message('History', name: 'history', desc: '', args: []);
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  /// `Left`
  String get left {
    return Intl.message('Left', name: 'left', desc: '', args: []);
  }

  /// `Right`
  String get right {
    return Intl.message('Right', name: 'right', desc: '', args: []);
  }

  /// `Error: {error}`
  String errorOccurred(String error) {
    return Intl.message(
      'Error: $error',
      name: 'errorOccurred',
      desc: '',
      args: [error],
    );
  }

  /// `No data available`
  String get noDataAvailable {
    return Intl.message(
      'No data available',
      name: 'noDataAvailable',
      desc: '',
      args: [],
    );
  }

  /// `End date must be after start date`
  String get endDateMustBeAfterStart {
    return Intl.message(
      'End date must be after start date',
      name: 'endDateMustBeAfterStart',
      desc: '',
      args: [],
    );
  }

  /// `Export is under development...`
  String get exportInDevelopment {
    return Intl.message(
      'Export is under development...',
      name: 'exportInDevelopment',
      desc: '',
      args: [],
    );
  }

  /// `Choose a single date`
  String get chooseUniqueDate {
    return Intl.message(
      'Choose a single date',
      name: 'chooseUniqueDate',
      desc: '',
      args: [],
    );
  }

  /// `Choose a period`
  String get choosePeriod {
    return Intl.message(
      'Choose a period',
      name: 'choosePeriod',
      desc: '',
      args: [],
    );
  }

  /// `Reset filter`
  String get resetFilter {
    return Intl.message(
      'Reset filter',
      name: 'resetFilter',
      desc: '',
      args: [],
    );
  }

  /// `=== ÉCRAN PARAMÈTRES ===`
  String get _SETTINGS_SCREEN {
    return Intl.message(
      '=== ÉCRAN PARAMÈTRES ===',
      name: '_SETTINGS_SCREEN',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Manage name and profile photo`
  String get manageNameAndPhoto {
    return Intl.message(
      'Manage name and profile photo',
      name: 'manageNameAndPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Receive daily reminders`
  String get receiveDailyReminders {
    return Intl.message(
      'Receive daily reminders',
      name: 'receiveDailyReminders',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Theme`
  String get theme {
    return Intl.message('Theme', name: 'theme', desc: '', args: []);
  }

  /// `Bluetooth Settings`
  String get bluetoothSettings {
    return Intl.message(
      'Bluetooth Settings',
      name: 'bluetoothSettings',
      desc: '',
      args: [],
    );
  }

  /// `Connection and data recording`
  String get connectionAndDataRecording {
    return Intl.message(
      'Connection and data recording',
      name: 'connectionAndDataRecording',
      desc: '',
      args: [],
    );
  }

  /// `Displayed Charts`
  String get displayedCharts {
    return Intl.message(
      'Displayed Charts',
      name: 'displayedCharts',
      desc: '',
      args: [],
    );
  }

  /// `Choose charts to display`
  String get chooseChartsToDisplay {
    return Intl.message(
      'Choose charts to display',
      name: 'chooseChartsToDisplay',
      desc: '',
      args: [],
    );
  }

  /// `Collection Frequency`
  String get collectionFrequency {
    return Intl.message(
      'Collection Frequency',
      name: 'collectionFrequency',
      desc: '',
      args: [],
    );
  }

  /// `Daily Goal`
  String get dailyGoal {
    return Intl.message('Daily Goal', name: 'dailyGoal', desc: '', args: []);
  }

  /// `Check Frequency`
  String get checkFrequency {
    return Intl.message(
      'Check Frequency',
      name: 'checkFrequency',
      desc: '',
      args: [],
    );
  }

  /// `Left Watch`
  String get leftWatch {
    return Intl.message('Left Watch', name: 'leftWatch', desc: '', args: []);
  }

  /// `Right Watch`
  String get rightWatch {
    return Intl.message('Right Watch', name: 'rightWatch', desc: '', args: []);
  }

  /// `Push Update`
  String get pushUpdate {
    return Intl.message('Push Update', name: 'pushUpdate', desc: '', args: []);
  }

  /// `Send config to watches`
  String get sendConfigToWatches {
    return Intl.message(
      'Send config to watches',
      name: 'sendConfigToWatches',
      desc: '',
      args: [],
    );
  }

  /// `Update Watches`
  String get updateWatches {
    return Intl.message(
      'Update Watches',
      name: 'updateWatches',
      desc: '',
      args: [],
    );
  }

  /// `Install Firmware`
  String get installFirmware {
    return Intl.message(
      'Install Firmware',
      name: 'installFirmware',
      desc: '',
      args: [],
    );
  }

  /// `Synchronization`
  String get synchronization {
    return Intl.message(
      'Synchronization',
      name: 'synchronization',
      desc: '',
      args: [],
    );
  }

  /// `Force sync with watches`
  String get forceSyncWithWatches {
    return Intl.message(
      'Force sync with watches',
      name: 'forceSyncWithWatches',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `Contact Support`
  String get contactSupport {
    return Intl.message(
      'Contact Support',
      name: 'contactSupport',
      desc: '',
      args: [],
    );
  }

  /// `kdetou@etu.uqac.ca`
  String get supportEmail {
    return Intl.message(
      'kdetou@etu.uqac.ca',
      name: 'supportEmail',
      desc: '',
      args: [],
    );
  }

  /// `Share My Data`
  String get shareMyData {
    return Intl.message(
      'Share My Data',
      name: 'shareMyData',
      desc: '',
      args: [],
    );
  }

  /// `Import Data`
  String get importData {
    return Intl.message('Import Data', name: 'importData', desc: '', args: []);
  }

  /// `Export My Data`
  String get exportMyData {
    return Intl.message(
      'Export My Data',
      name: 'exportMyData',
      desc: '',
      args: [],
    );
  }

  /// `Save to file`
  String get saveToFile {
    return Intl.message('Save to file', name: 'saveToFile', desc: '', args: []);
  }

  /// `Reset Settings`
  String get resetSettings {
    return Intl.message(
      'Reset Settings',
      name: 'resetSettings',
      desc: '',
      args: [],
    );
  }

  /// `Reset all configurations`
  String get resetAllConfigurations {
    return Intl.message(
      'Reset all configurations',
      name: 'resetAllConfigurations',
      desc: '',
      args: [],
    );
  }

  /// `Reset Data`
  String get resetData {
    return Intl.message('Reset Data', name: 'resetData', desc: '', args: []);
  }

  /// `Delete all local data`
  String get deleteAllLocalData {
    return Intl.message(
      'Delete all local data',
      name: 'deleteAllLocalData',
      desc: '',
      args: [],
    );
  }

  /// `Edit Name`
  String get editName {
    return Intl.message('Edit Name', name: 'editName', desc: '', args: []);
  }

  /// `Edit Name`
  String get editNameTitle {
    return Intl.message('Edit Name', name: 'editNameTitle', desc: '', args: []);
  }

  /// `Please enter this code to confirm:`
  String get enterCodeToConfirm {
    return Intl.message(
      'Please enter this code to confirm:',
      name: 'enterCodeToConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Data reset.`
  String get dataReset {
    return Intl.message('Data reset.', name: 'dataReset', desc: '', args: []);
  }

  /// `Image selection error: {error}`
  String imageSelectionError(String error) {
    return Intl.message(
      'Image selection error: $error',
      name: 'imageSelectionError',
      desc: '',
      args: [error],
    );
  }

  /// `=== PAGE LANGUE ===`
  String get _LANGUAGE_PAGE {
    return Intl.message(
      '=== PAGE LANGUE ===',
      name: '_LANGUAGE_PAGE',
      desc: '',
      args: [],
    );
  }

  /// `Application Language`
  String get appLanguage {
    return Intl.message(
      'Application Language',
      name: 'appLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Language changed to {language}`
  String languageChangedTo(String language) {
    return Intl.message(
      'Language changed to $language',
      name: 'languageChangedTo',
      desc: '',
      args: [language],
    );
  }

  /// `=== ABOUT PAGE ===`
  String get _ABOUT_PAGE {
    return Intl.message(
      '=== ABOUT PAGE ===',
      name: '_ABOUT_PAGE',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Use`
  String get termsOfUse {
    return Intl.message('Terms of Use', name: 'termsOfUse', desc: '', args: []);
  }

  /// `Privacy policy will be added here.`
  String get privacyPolicyContent {
    return Intl.message(
      'Privacy policy will be added here.',
      name: 'privacyPolicyContent',
      desc: '',
      args: [],
    );
  }

  /// `Terms of use will be added here.`
  String get termsOfUseContent {
    return Intl.message(
      'Terms of use will be added here.',
      name: 'termsOfUseContent',
      desc: '',
      args: [],
    );
  }

  /// `Credits`
  String get credits {
    return Intl.message('Credits', name: 'credits', desc: '', args: []);
  }

  /// `Developed by Health & Tech Team – 2025`
  String get developedBy {
    return Intl.message(
      'Developed by Health & Tech Team – 2025',
      name: 'developedBy',
      desc: '',
      args: [],
    );
  }

  /// `=== PAGE BLUETOOTH ===`
  String get _BLUETOOTH_PAGE {
    return Intl.message(
      '=== PAGE BLUETOOTH ===',
      name: '_BLUETOOTH_PAGE',
      desc: '',
      args: [],
    );
  }

  /// `Bluetooth settings updated`
  String get bluetoothSettingsUpdated {
    return Intl.message(
      'Bluetooth settings updated',
      name: 'bluetoothSettingsUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Apply profile?`
  String get applyProfile {
    return Intl.message(
      'Apply profile?',
      name: 'applyProfile',
      desc: '',
      args: [],
    );
  }

  /// `Connection timeout. Check that the watch is nearby.`
  String get connectionTimeout {
    return Intl.message(
      'Connection timeout. Check that the watch is nearby.',
      name: 'connectionTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Initialization error: {error}`
  String initializationError(String error) {
    return Intl.message(
      'Initialization error: $error',
      name: 'initializationError',
      desc: '',
      args: [error],
    );
  }

  /// `Permissions Required`
  String get permissionsRequired {
    return Intl.message(
      'Permissions Required',
      name: 'permissionsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingsButton {
    return Intl.message('Settings', name: 'settingsButton', desc: '', args: []);
  }

  /// `Auto-connecting to {name}...`
  String autoConnectingTo(String name) {
    return Intl.message(
      'Auto-connecting to $name...',
      name: 'autoConnectingTo',
      desc: '',
      args: [name],
    );
  }

  /// `Please wait between connection attempts`
  String get pleaseWaitBetweenConnections {
    return Intl.message(
      'Please wait between connection attempts',
      name: 'pleaseWaitBetweenConnections',
      desc: '',
      args: [],
    );
  }

  /// `Connecting to {name}...`
  String connectingTo(String name) {
    return Intl.message(
      'Connecting to $name...',
      name: 'connectingTo',
      desc: '',
      args: [name],
    );
  }

  /// `Connection successful!`
  String get connectionSuccessful {
    return Intl.message(
      'Connection successful!',
      name: 'connectionSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `PineTime ({position})`
  String pinetimePosition(String position) {
    return Intl.message(
      'PineTime ($position)',
      name: 'pinetimePosition',
      desc: '',
      args: [position],
    );
  }

  /// `{name} removed from favorites`
  String removedFromFavorites(String name) {
    return Intl.message(
      '$name removed from favorites',
      name: 'removedFromFavorites',
      desc: '',
      args: [name],
    );
  }

  /// `{name} added to favorites`
  String addedToFavorites(String name) {
    return Intl.message(
      '$name added to favorites',
      name: 'addedToFavorites',
      desc: '',
      args: [name],
    );
  }

  /// `Connect`
  String get connect {
    return Intl.message('Connect', name: 'connect', desc: '', args: []);
  }

  /// `Restart Scan`
  String get restartScan {
    return Intl.message(
      'Restart Scan',
      name: 'restartScan',
      desc: '',
      args: [],
    );
  }

  /// `Start Scan`
  String get startScan {
    return Intl.message('Start Scan', name: 'startScan', desc: '', args: []);
  }

  /// `Search Device`
  String get searchDevice {
    return Intl.message(
      'Search Device',
      name: 'searchDevice',
      desc: '',
      args: [],
    );
  }

  /// `=== GESTION MONTRES ===`
  String get _WATCH_MANAGEMENT {
    return Intl.message(
      '=== GESTION MONTRES ===',
      name: '_WATCH_MANAGEMENT',
      desc: '',
      args: [],
    );
  }

  /// `Rename watch`
  String get renameWatch {
    return Intl.message(
      'Rename watch',
      name: 'renameWatch',
      desc: '',
      args: [],
    );
  }

  /// `Vibration tested successfully`
  String get vibrationTested {
    return Intl.message(
      'Vibration tested successfully',
      name: 'vibrationTested',
      desc: '',
      args: [],
    );
  }

  /// `Watch synced`
  String get watchSynced {
    return Intl.message(
      'Watch synced',
      name: 'watchSynced',
      desc: '',
      args: [],
    );
  }

  /// `Current battery: {level}%`
  String currentBattery(int level) {
    return Intl.message(
      'Current battery: $level%',
      name: 'currentBattery',
      desc: '',
      args: [level],
    );
  }

  /// `Checking firmware...`
  String get checkingFirmware {
    return Intl.message(
      'Checking firmware...',
      name: 'checkingFirmware',
      desc: '',
      args: [],
    );
  }

  /// `Firmware is up to date.`
  String get firmwareUpToDate {
    return Intl.message(
      'Firmware is up to date.',
      name: 'firmwareUpToDate',
      desc: '',
      args: [],
    );
  }

  /// `Delete the watch?`
  String get deleteWatchQuestion {
    return Intl.message(
      'Delete the watch?',
      name: 'deleteWatchQuestion',
      desc: '',
      args: [],
    );
  }

  /// `This action is permanent.`
  String get actionIsDefinitive {
    return Intl.message(
      'This action is permanent.',
      name: 'actionIsDefinitive',
      desc: '',
      args: [],
    );
  }

  /// `Watch deleted.`
  String get watchDeleted {
    return Intl.message(
      'Watch deleted.',
      name: 'watchDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Watch {side}`
  String watchLeftRight(String side) {
    return Intl.message(
      'Watch $side',
      name: 'watchLeftRight',
      desc: '',
      args: [side],
    );
  }

  /// `Test vibration`
  String get testVibration {
    return Intl.message(
      'Test vibration',
      name: 'testVibration',
      desc: '',
      args: [],
    );
  }

  /// `Firmware update`
  String get firmwareUpdate {
    return Intl.message(
      'Firmware update',
      name: 'firmwareUpdate',
      desc: '',
      args: [],
    );
  }

  /// `=== PAGE PROFIL ===`
  String get _PROFILE_PAGE {
    return Intl.message(
      '=== PAGE PROFIL ===',
      name: '_PROFILE_PAGE',
      desc: '',
      args: [],
    );
  }

  /// `Name cannot be empty`
  String get nameCannotBeEmpty {
    return Intl.message(
      'Name cannot be empty',
      name: 'nameCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Profile updated successfully`
  String get profileUpdated {
    return Intl.message(
      'Profile updated successfully',
      name: 'profileUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Delete photo`
  String get deletePhoto {
    return Intl.message(
      'Delete photo',
      name: 'deletePhoto',
      desc: '',
      args: [],
    );
  }

  /// `=== PAGE THÈME ===`
  String get _THEME_PAGE {
    return Intl.message(
      '=== PAGE THÈME ===',
      name: '_THEME_PAGE',
      desc: '',
      args: [],
    );
  }

  /// `Theme updated.`
  String get themeUpdated {
    return Intl.message(
      'Theme updated.',
      name: 'themeUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Application Theme`
  String get appTheme {
    return Intl.message(
      'Application Theme',
      name: 'appTheme',
      desc: '',
      args: [],
    );
  }

  /// `System Theme`
  String get systemTheme {
    return Intl.message(
      'System Theme',
      name: 'systemTheme',
      desc: '',
      args: [],
    );
  }

  /// `Light Theme`
  String get lightTheme {
    return Intl.message('Light Theme', name: 'lightTheme', desc: '', args: []);
  }

  /// `Dark Theme`
  String get darkTheme {
    return Intl.message('Dark Theme', name: 'darkTheme', desc: '', args: []);
  }

  /// `Light Gold`
  String get lightGold {
    return Intl.message('Light Gold', name: 'lightGold', desc: '', args: []);
  }

  /// `Dark Gold`
  String get darkGold {
    return Intl.message('Dark Gold', name: 'darkGold', desc: '', args: []);
  }

  /// `Light Mint`
  String get lightMint {
    return Intl.message('Light Mint', name: 'lightMint', desc: '', args: []);
  }

  /// `Dark Mint`
  String get darkMint {
    return Intl.message('Dark Mint', name: 'darkMint', desc: '', args: []);
  }

  /// `Experimental Theme`
  String get experimentalTheme {
    return Intl.message(
      'Experimental Theme',
      name: 'experimentalTheme',
      desc: '',
      args: [],
    );
  }

  /// `=== CHART PREFERENCES ===`
  String get _CHART_PREFERENCES {
    return Intl.message(
      '=== CHART PREFERENCES ===',
      name: '_CHART_PREFERENCES',
      desc: '',
      args: [],
    );
  }

  /// `Chart Preferences`
  String get chartPreferences {
    return Intl.message(
      'Chart Preferences',
      name: 'chartPreferences',
      desc: '',
      args: [],
    );
  }

  /// `=== PAGE CONTACT ===`
  String get _CONTACT_PAGE {
    return Intl.message(
      '=== PAGE CONTACT ===',
      name: '_CONTACT_PAGE',
      desc: '',
      args: [],
    );
  }

  /// `Message sent to support.`
  String get messageSentToSupport {
    return Intl.message(
      'Message sent to support.',
      name: 'messageSentToSupport',
      desc: '',
      args: [],
    );
  }

  /// `=== DIALOGUE FIRMWARE ===`
  String get _FIRMWARE_DIALOG {
    return Intl.message(
      '=== DIALOGUE FIRMWARE ===',
      name: '_FIRMWARE_DIALOG',
      desc: '',
      args: [],
    );
  }

  /// `Firmware for {side}`
  String firmwareFor(String side) {
    return Intl.message(
      'Firmware for $side',
      name: 'firmwareFor',
      desc: '',
      args: [side],
    );
  }

  /// `Loading firmwares...`
  String get loadingFirmwares {
    return Intl.message(
      'Loading firmwares...',
      name: 'loadingFirmwares',
      desc: '',
      args: [],
    );
  }

  /// `No firmware available`
  String get noFirmwareAvailable {
    return Intl.message(
      'No firmware available',
      name: 'noFirmwareAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Reload`
  String get reload {
    return Intl.message('Reload', name: 'reload', desc: '', args: []);
  }

  /// `Install`
  String get install {
    return Intl.message('Install', name: 'install', desc: '', args: []);
  }

  /// `Updating`
  String get updating {
    return Intl.message('Updating', name: 'updating', desc: '', args: []);
  }

  /// `Update Complete`
  String get updateComplete {
    return Intl.message(
      'Update Complete',
      name: 'updateComplete',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get updateFailed {
    return Intl.message('Error', name: 'updateFailed', desc: '', args: []);
  }

  /// `Do not disconnect the watch`
  String get doNotDisconnectWatch {
    return Intl.message(
      'Do not disconnect the watch',
      name: 'doNotDisconnectWatch',
      desc: '',
      args: [],
    );
  }

  /// `Update installed successfully!`
  String get updateInstalledSuccessfully {
    return Intl.message(
      'Update installed successfully!',
      name: 'updateInstalledSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Your watch will restart automatically.`
  String get watchWillRestart {
    return Intl.message(
      'Your watch will restart automatically.',
      name: 'watchWillRestart',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred during the update.`
  String get updateErrorOccurred {
    return Intl.message(
      'An error occurred during the update.',
      name: 'updateErrorOccurred',
      desc: '',
      args: [],
    );
  }

  /// `Please try again or contact support.`
  String get tryAgainOrContact {
    return Intl.message(
      'Please try again or contact support.',
      name: 'tryAgainOrContact',
      desc: '',
      args: [],
    );
  }

  /// `=== CARTE BOUTON MONTRE ===`
  String get _WATCH_BUTTON_CARD {
    return Intl.message(
      '=== CARTE BOUTON MONTRE ===',
      name: '_WATCH_BUTTON_CARD',
      desc: '',
      args: [],
    );
  }

  /// `Metrics`
  String get metrics {
    return Intl.message('Metrics', name: 'metrics', desc: '', args: []);
  }

  /// `Cannot cancel: {error}`
  String cannotCancel(String error) {
    return Intl.message(
      'Cannot cancel: $error',
      name: 'cannotCancel',
      desc: '',
      args: [error],
    );
  }

  /// `System Information`
  String get systemInformation {
    return Intl.message(
      'System Information',
      name: 'systemInformation',
      desc: '',
      args: [],
    );
  }

  /// `Disconnect`
  String get disconnect {
    return Intl.message('Disconnect', name: 'disconnect', desc: '', args: []);
  }

  /// `Reconnect`
  String get reconnect {
    return Intl.message('Reconnect', name: 'reconnect', desc: '', args: []);
  }

  /// `Forget This Watch`
  String get forgetThisWatch {
    return Intl.message(
      'Forget This Watch',
      name: 'forgetThisWatch',
      desc: '',
      args: [],
    );
  }

  /// `Scan a PineTime`
  String get scanPineTime {
    return Intl.message(
      'Scan a PineTime',
      name: 'scanPineTime',
      desc: '',
      args: [],
    );
  }

  /// `=== WIDGETS GRAPHIQUES ===`
  String get _CHART_WIDGETS {
    return Intl.message(
      '=== WIDGETS GRAPHIQUES ===',
      name: '_CHART_WIDGETS',
      desc: '',
      args: [],
    );
  }

  /// `Balance`
  String get balance {
    return Intl.message('Balance', name: 'balance', desc: '', args: []);
  }

  /// `Magnitude`
  String get magnitude {
    return Intl.message('Magnitude', name: 'magnitude', desc: '', args: []);
  }

  /// `Axis`
  String get axis {
    return Intl.message('Axis', name: 'axis', desc: '', args: []);
  }

  /// `=== ONBOARDING ===`
  String get _ONBOARDING {
    return Intl.message(
      '=== ONBOARDING ===',
      name: '_ONBOARDING',
      desc: '',
      args: [],
    );
  }

  /// `New name`
  String get newName {
    return Intl.message('New name', name: 'newName', desc: '', args: []);
  }

  /// `=== TIME PREFERENCES ===`
  String get _TIME_PREFERENCES {
    return Intl.message(
      '=== TIME PREFERENCES ===',
      name: '_TIME_PREFERENCES',
      desc: '',
      args: [],
    );
  }

  /// `Synchronization Settings`
  String get syncSettings {
    return Intl.message(
      'Synchronization Settings',
      name: 'syncSettings',
      desc: '',
      args: [],
    );
  }

  /// `24-hour format`
  String get format24Hours {
    return Intl.message(
      '24-hour format',
      name: 'format24Hours',
      desc: '',
      args: [],
    );
  }

  /// `Phone timezone`
  String get phoneTimezone {
    return Intl.message(
      'Phone timezone',
      name: 'phoneTimezone',
      desc: '',
      args: [],
    );
  }

  /// `Custom timezone`
  String get customTimezone {
    return Intl.message(
      'Custom timezone',
      name: 'customTimezone',
      desc: '',
      args: [],
    );
  }

  /// `Select timezone`
  String get selectTimezone {
    return Intl.message(
      'Select timezone',
      name: 'selectTimezone',
      desc: '',
      args: [],
    );
  }

  /// `Time synchronization`
  String get timeSynchronization {
    return Intl.message(
      'Time synchronization',
      name: 'timeSynchronization',
      desc: '',
      args: [],
    );
  }

  /// `Timezone, time format and synchronization`
  String get timezoneFormatSync {
    return Intl.message(
      'Timezone, time format and synchronization',
      name: 'timezoneFormatSync',
      desc: '',
      args: [],
    );
  }

  /// `=== GOAL SETTINGS ===`
  String get _GOAL_SETTINGS {
    return Intl.message(
      '=== GOAL SETTINGS ===',
      name: '_GOAL_SETTINGS',
      desc: '',
      args: [],
    );
  }

  /// `Goal Configuration`
  String get goalConfiguration {
    return Intl.message(
      'Goal Configuration',
      name: 'goalConfiguration',
      desc: '',
      args: [],
    );
  }

  /// `minutes`
  String get checkFrequencyMinutes {
    return Intl.message(
      'minutes',
      name: 'checkFrequencyMinutes',
      desc: '',
      args: [],
    );
  }

  /// `Fixed Goal`
  String get fixedGoal {
    return Intl.message('Fixed Goal', name: 'fixedGoal', desc: '', args: []);
  }

  /// `Set a fixed ratio to achieve`
  String get fixedGoalDescription {
    return Intl.message(
      'Set a fixed ratio to achieve',
      name: 'fixedGoalDescription',
      desc: '',
      args: [],
    );
  }

  /// `Dynamic Goal`
  String get dynamicGoal {
    return Intl.message(
      'Dynamic Goal',
      name: 'dynamicGoal',
      desc: '',
      args: [],
    );
  }

  /// `Goal Ratio`
  String get goalRatio {
    return Intl.message('Goal Ratio', name: 'goalRatio', desc: '', args: []);
  }

  /// `Number of days in period`
  String get periodDays {
    return Intl.message(
      'Number of days in period',
      name: 'periodDays',
      desc: '',
      args: [],
    );
  }

  /// `days`
  String get periodDaysUnit {
    return Intl.message('days', name: 'periodDaysUnit', desc: '', args: []);
  }

  /// `Daily increase percentage`
  String get dailyIncreasePercent {
    return Intl.message(
      'Daily increase percentage',
      name: 'dailyIncreasePercent',
      desc: '',
      args: [],
    );
  }

  /// `Daily Increase`
  String get dailyIncrease {
    return Intl.message(
      'Daily Increase',
      name: 'dailyIncrease',
      desc: '',
      args: [],
    );
  }

  /// `=== MOVEMENT SAMPLING ===`
  String get _MOVEMENT_SAMPLING {
    return Intl.message(
      '=== MOVEMENT SAMPLING ===',
      name: '_MOVEMENT_SAMPLING',
      desc: '',
      args: [],
    );
  }

  /// `Movement Sampling`
  String get movementSampling {
    return Intl.message(
      'Movement Sampling',
      name: 'movementSampling',
      desc: '',
      args: [],
    );
  }

  /// `Sampling mode`
  String get samplingMode {
    return Intl.message(
      'Sampling mode',
      name: 'samplingMode',
      desc: '',
      args: [],
    );
  }

  /// `Interval`
  String get interval {
    return Intl.message('Interval', name: 'interval', desc: '', args: []);
  }

  /// `ms (seconds)`
  String get intervalMs {
    return Intl.message('ms (seconds)', name: 'intervalMs', desc: '', args: []);
  }

  /// `{value} ms`
  String intervalMsValue(int value) {
    return Intl.message(
      '$value ms',
      name: 'intervalMsValue',
      desc: '',
      args: [value],
    );
  }

  /// `Change threshold`
  String get changeThreshold {
    return Intl.message(
      'Change threshold',
      name: 'changeThreshold',
      desc: '',
      args: [],
    );
  }

  /// `g`
  String get thresholdUnit {
    return Intl.message('g', name: 'thresholdUnit', desc: '', args: []);
  }

  /// `Max samples per flush`
  String get maxSamplesPerFlush {
    return Intl.message(
      'Max samples per flush',
      name: 'maxSamplesPerFlush',
      desc: '',
      args: [],
    );
  }

  /// `samples`
  String get samplesUnit {
    return Intl.message('samples', name: 'samplesUnit', desc: '', args: []);
  }

  /// `=== BLUETOOTH SETTINGS ===`
  String get _BLUETOOTH_SETTINGS {
    return Intl.message(
      '=== BLUETOOTH SETTINGS ===',
      name: '_BLUETOOTH_SETTINGS',
      desc: '',
      args: [],
    );
  }

  /// `Scan duration`
  String get scanDuration {
    return Intl.message(
      'Scan duration',
      name: 'scanDuration',
      desc: '',
      args: [],
    );
  }

  /// `Time to wait to find watches`
  String get scanDurationDescription {
    return Intl.message(
      'Time to wait to find watches',
      name: 'scanDurationDescription',
      desc: '',
      args: [],
    );
  }

  /// `Connection delay`
  String get connectionDelay {
    return Intl.message(
      'Connection delay',
      name: 'connectionDelay',
      desc: '',
      args: [],
    );
  }

  /// `Maximum time to establish connection`
  String get connectionDelayDescription {
    return Intl.message(
      'Maximum time to establish connection',
      name: 'connectionDelayDescription',
      desc: '',
      args: [],
    );
  }

  /// `Reconnection attempts`
  String get reconnectionAttempts {
    return Intl.message(
      'Reconnection attempts',
      name: 'reconnectionAttempts',
      desc: '',
      args: [],
    );
  }

  /// `Number of retries on failure`
  String get reconnectionAttemptsDescription {
    return Intl.message(
      'Number of retries on failure',
      name: 'reconnectionAttemptsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Battery/RSSI frequency`
  String get batteryRssiFrequency {
    return Intl.message(
      'Battery/RSSI frequency',
      name: 'batteryRssiFrequency',
      desc: '',
      args: [],
    );
  }

  /// `Recording interval for basic info`
  String get batteryRssiFrequencyDescription {
    return Intl.message(
      'Recording interval for basic info',
      name: 'batteryRssiFrequencyDescription',
      desc: '',
      args: [],
    );
  }

  /// `Movement frequency`
  String get movementFrequency {
    return Intl.message(
      'Movement frequency',
      name: 'movementFrequency',
      desc: '',
      args: [],
    );
  }

  /// `Recording interval for movement data`
  String get movementFrequencyDescription {
    return Intl.message(
      'Recording interval for movement data',
      name: 'movementFrequencyDescription',
      desc: '',
      args: [],
    );
  }

  /// `=== CHART PREFERENCES PAGE ===`
  String get _CHART_PREFERENCES_PAGE {
    return Intl.message(
      '=== CHART PREFERENCES PAGE ===',
      name: '_CHART_PREFERENCES_PAGE',
      desc: '',
      args: [],
    );
  }

  /// `Asymmetry (Magnitude & Axis)`
  String get asymmetryMagnitudeAxis {
    return Intl.message(
      'Asymmetry (Magnitude & Axis)',
      name: 'asymmetryMagnitudeAxis',
      desc: '',
      args: [],
    );
  }

  /// `Merged gauge chart showing asymmetry - Always enabled`
  String get asymmetryMagnitudeAxisDescription {
    return Intl.message(
      'Merged gauge chart showing asymmetry - Always enabled',
      name: 'asymmetryMagnitudeAxisDescription',
      desc: '',
      args: [],
    );
  }

  /// `Battery level comparison of both watches`
  String get batteryLevelDescription {
    return Intl.message(
      'Battery level comparison of both watches',
      name: 'batteryLevelDescription',
      desc: '',
      args: [],
    );
  }

  /// `Magnitude/axis heatmap for balance tracking`
  String get balanceGoalDescription {
    return Intl.message(
      'Magnitude/axis heatmap for balance tracking',
      name: 'balanceGoalDescription',
      desc: '',
      args: [],
    );
  }

  /// `Movement Asymmetry`
  String get movementAsymmetry {
    return Intl.message(
      'Movement Asymmetry',
      name: 'movementAsymmetry',
      desc: '',
      args: [],
    );
  }

  /// `Asymmetry ratio chart with Magnitude/Axis filter and goal`
  String get movementAsymmetryDescription {
    return Intl.message(
      'Asymmetry ratio chart with Magnitude/Axis filter and goal',
      name: 'movementAsymmetryDescription',
      desc: '',
      args: [],
    );
  }

  /// `Step count comparison between both arms`
  String get stepCountDescription {
    return Intl.message(
      'Step count comparison between both arms',
      name: 'stepCountDescription',
      desc: '',
      args: [],
    );
  }

  /// `=== CONTACT SUPPORT ===`
  String get _CONTACT_SUPPORT {
    return Intl.message(
      '=== CONTACT SUPPORT ===',
      name: '_CONTACT_SUPPORT',
      desc: '',
      args: [],
    );
  }

  /// `Contact Support`
  String get contactSupportTitle {
    return Intl.message(
      'Contact Support',
      name: 'contactSupportTitle',
      desc: '',
      args: [],
    );
  }

  /// `Support Email`
  String get supportEmailLabel {
    return Intl.message(
      'Support Email',
      name: 'supportEmailLabel',
      desc: '',
      args: [],
    );
  }

  /// `Send a message to our support team:`
  String get sendMessageToSupport {
    return Intl.message(
      'Send a message to our support team:',
      name: 'sendMessageToSupport',
      desc: '',
      args: [],
    );
  }

  /// `Subject`
  String get subject {
    return Intl.message('Subject', name: 'subject', desc: '', args: []);
  }

  /// `Message`
  String get message {
    return Intl.message('Message', name: 'message', desc: '', args: []);
  }

  /// `Please enter a subject.`
  String get pleaseEnterSubject {
    return Intl.message(
      'Please enter a subject.',
      name: 'pleaseEnterSubject',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a message.`
  String get pleaseEnterMessage {
    return Intl.message(
      'Please enter a message.',
      name: 'pleaseEnterMessage',
      desc: '',
      args: [],
    );
  }

  /// `Sending...`
  String get sendingInProgress {
    return Intl.message(
      'Sending...',
      name: 'sendingInProgress',
      desc: '',
      args: [],
    );
  }

  /// `Send Message`
  String get sendMessage {
    return Intl.message(
      'Send Message',
      name: 'sendMessage',
      desc: '',
      args: [],
    );
  }

  /// `Email client opened. Send your message.`
  String get emailClientOpened {
    return Intl.message(
      'Email client opened. Send your message.',
      name: 'emailClientOpened',
      desc: '',
      args: [],
    );
  }

  /// `Cannot open email client.`
  String get cannotOpenEmailClient {
    return Intl.message(
      'Cannot open email client.',
      name: 'cannotOpenEmailClient',
      desc: '',
      args: [],
    );
  }

  /// `Contact us at: {email}`
  String contactUsAt(String email) {
    return Intl.message(
      'Contact us at: $email',
      name: 'contactUsAt',
      desc: '',
      args: [email],
    );
  }

  /// `=== PDF EXPORT ===`
  String get _PDF_EXPORT {
    return Intl.message(
      '=== PDF EXPORT ===',
      name: '_PDF_EXPORT',
      desc: '',
      args: [],
    );
  }

  /// `PDF generated successfully`
  String get pdfGeneratedSuccessfully {
    return Intl.message(
      'PDF generated successfully',
      name: 'pdfGeneratedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get preview {
    return Intl.message('Preview', name: 'preview', desc: '', args: []);
  }

  /// `Share`
  String get share {
    return Intl.message('Share', name: 'share', desc: '', args: []);
  }

  /// `PDF generated with {count} chart(s)`
  String pdfGeneratedWithCharts(int count) {
    return Intl.message(
      'PDF generated with $count chart(s)',
      name: 'pdfGeneratedWithCharts',
      desc: '',
      args: [count],
    );
  }

  /// `Error generating PDF: {error}`
  String pdfGenerationError(String error) {
    return Intl.message(
      'Error generating PDF: $error',
      name: 'pdfGenerationError',
      desc: '',
      args: [error],
    );
  }

  /// `=== WATCHFACE INSTALL ===`
  String get _WATCHFACE_INSTALL {
    return Intl.message(
      '=== WATCHFACE INSTALL ===',
      name: '_WATCHFACE_INSTALL',
      desc: '',
      args: [],
    );
  }

  /// `Downloading update file...`
  String get downloadingUpdateFile {
    return Intl.message(
      'Downloading update file...',
      name: 'downloadingUpdateFile',
      desc: '',
      args: [],
    );
  }

  /// `Download in progress...`
  String get downloadInProgress {
    return Intl.message(
      'Download in progress...',
      name: 'downloadInProgress',
      desc: '',
      args: [],
    );
  }

  /// `=== WATCH CARD ===`
  String get _WATCH_CARD {
    return Intl.message(
      '=== WATCH CARD ===',
      name: '_WATCH_CARD',
      desc: '',
      args: [],
    );
  }

  /// `Cancel DFU`
  String get cancelDfu {
    return Intl.message('Cancel DFU', name: 'cancelDfu', desc: '', args: []);
  }

  /// `Delete watch`
  String get deleteWatch {
    return Intl.message(
      'Delete watch',
      name: 'deleteWatch',
      desc: '',
      args: [],
    );
  }

  /// `=== RESET DIALOGS ===`
  String get _RESET_DIALOGS {
    return Intl.message(
      '=== RESET DIALOGS ===',
      name: '_RESET_DIALOGS',
      desc: '',
      args: [],
    );
  }

  /// `Reset data?`
  String get resetDataQuestion {
    return Intl.message(
      'Reset data?',
      name: 'resetDataQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Reset configurations?`
  String get resetConfigurationsQuestion {
    return Intl.message(
      'Reset configurations?',
      name: 'resetConfigurationsQuestion',
      desc: '',
      args: [],
    );
  }

  /// `=== EMPTY STATE ===`
  String get _EMPTY_STATE {
    return Intl.message(
      '=== EMPTY STATE ===',
      name: '_EMPTY_STATE',
      desc: '',
      args: [],
    );
  }

  /// `Sorry, you have no product in your wishlist`
  String get sorryNoProductWishlist {
    return Intl.message(
      'Sorry, you have no product in your wishlist',
      name: 'sorryNoProductWishlist',
      desc: '',
      args: [],
    );
  }

  /// `Start Adding`
  String get startAdding {
    return Intl.message(
      'Start Adding',
      name: 'startAdding',
      desc: '',
      args: [],
    );
  }

  /// `Select charts to display`
  String get selectChartsToDisplay {
    return Intl.message(
      'Select charts to display',
      name: 'selectChartsToDisplay',
      desc: '',
      args: [],
    );
  }

  /// `Disabled charts will not be shown on the main screen`
  String get disabledChartsNotShown {
    return Intl.message(
      'Disabled charts will not be shown on the main screen',
      name: 'disabledChartsNotShown',
      desc: '',
      args: [],
    );
  }

  /// `{count} chart(s) enabled`
  String chartsEnabledCount(int count) {
    return Intl.message(
      '$count chart(s) enabled',
      name: 'chartsEnabledCount',
      desc: '',
      args: [count],
    );
  }

  /// `InfiniTime Sensors`
  String get infiniTimeSensors {
    return Intl.message(
      'InfiniTime Sensors',
      name: 'infiniTimeSensors',
      desc: '',
      args: [],
    );
  }

  /// `Complete tracking of battery, heart rate, steps and other metrics collected from your PineTime watches.`
  String get sensorTrackingDescription {
    return Intl.message(
      'Complete tracking of battery, heart rate, steps and other metrics collected from your PineTime watches.',
      name: 'sensorTrackingDescription',
      desc: '',
      args: [],
    );
  }

  /// `Asymmetry Magnitude & Axis`
  String get asymmetryMagnitudeAndAxis {
    return Intl.message(
      'Asymmetry Magnitude & Axis',
      name: 'asymmetryMagnitudeAndAxis',
      desc: '',
      args: [],
    );
  }

  /// `Movement Asymmetry (Ratio)`
  String get asymmetryMovementRatio {
    return Intl.message(
      'Movement Asymmetry (Ratio)',
      name: 'asymmetryMovementRatio',
      desc: '',
      args: [],
    );
  }

  /// `Balance Goal (Heatmap)`
  String get balanceGoalHeatmap {
    return Intl.message(
      'Balance Goal (Heatmap)',
      name: 'balanceGoalHeatmap',
      desc: '',
      args: [],
    );
  }

  /// `Left watch connected`
  String get leftWatchConnected {
    return Intl.message(
      'Left watch connected',
      name: 'leftWatchConnected',
      desc: '',
      args: [],
    );
  }

  /// `Left watch disconnected`
  String get leftWatchDisconnected {
    return Intl.message(
      'Left watch disconnected',
      name: 'leftWatchDisconnected',
      desc: '',
      args: [],
    );
  }

  /// `Right watch connected`
  String get rightWatchConnected {
    return Intl.message(
      'Right watch connected',
      name: 'rightWatchConnected',
      desc: '',
      args: [],
    );
  }

  /// `Right watch disconnected`
  String get rightWatchDisconnected {
    return Intl.message(
      'Right watch disconnected',
      name: 'rightWatchDisconnected',
      desc: '',
      args: [],
    );
  }

  /// `Connection successful for {side}`
  String connectionSuccessFor(String side) {
    return Intl.message(
      'Connection successful for $side',
      name: 'connectionSuccessFor',
      desc: '',
      args: [side],
    );
  }

  /// `Connection error: {error}`
  String connectionError(String error) {
    return Intl.message(
      'Connection error: $error',
      name: 'connectionError',
      desc: '',
      args: [error],
    );
  }

  /// `Disconnection of {side}`
  String disconnectionOf(String side) {
    return Intl.message(
      'Disconnection of $side',
      name: 'disconnectionOf',
      desc: '',
      args: [side],
    );
  }

  /// `Reconnection in progress for {side}`
  String reconnectionInProgressFor(String side) {
    return Intl.message(
      'Reconnection in progress for $side',
      name: 'reconnectionInProgressFor',
      desc: '',
      args: [side],
    );
  }

  /// `Forget watch {side}?`
  String forgetWatchQuestion(String side) {
    return Intl.message(
      'Forget watch $side?',
      name: 'forgetWatchQuestion',
      desc: '',
      args: [side],
    );
  }

  /// `This action will:\n• Disconnect the watch\n• Delete binding data\n• Clear connection history\n\nYou will need to reconnect it manually.`
  String get forgetWatchDescription {
    return Intl.message(
      'This action will:\n• Disconnect the watch\n• Delete binding data\n• Clear connection history\n\nYou will need to reconnect it manually.',
      name: 'forgetWatchDescription',
      desc: '',
      args: [],
    );
  }

  /// `Deleting watch {side}...`
  String deletingWatch(String side) {
    return Intl.message(
      'Deleting watch $side...',
      name: 'deletingWatch',
      desc: '',
      args: [side],
    );
  }

  /// `Watch {side} forgotten successfully`
  String watchForgottenSuccessfully(String side) {
    return Intl.message(
      'Watch $side forgotten successfully',
      name: 'watchForgottenSuccessfully',
      desc: '',
      args: [side],
    );
  }

  /// `Error forgetting watch {side}`
  String errorForgettingWatch(String side) {
    return Intl.message(
      'Error forgetting watch $side',
      name: 'errorForgettingWatch',
      desc: '',
      args: [side],
    );
  }

  /// `Update watch {side}`
  String updateWatch(String side) {
    return Intl.message(
      'Update watch $side',
      name: 'updateWatch',
      desc: '',
      args: [side],
    );
  }

  /// `Firmware update in progress...`
  String get firmwareUpdateInProgress {
    return Intl.message(
      'Firmware update in progress...',
      name: 'firmwareUpdateInProgress',
      desc: '',
      args: [],
    );
  }

  /// `Device info request for {side}`
  String deviceInfoRequest(String side) {
    return Intl.message(
      'Device info request for $side',
      name: 'deviceInfoRequest',
      desc: '',
      args: [side],
    );
  }

  /// `Never synchronized`
  String get neverSynchronized {
    return Intl.message(
      'Never synchronized',
      name: 'neverSynchronized',
      desc: '',
      args: [],
    );
  }

  /// `{seconds}s ago`
  String agoSeconds(int seconds) {
    return Intl.message(
      '${seconds}s ago',
      name: 'agoSeconds',
      desc: '',
      args: [seconds],
    );
  }

  /// `{minutes}min ago`
  String agoMinutes(int minutes) {
    return Intl.message(
      '${minutes}min ago',
      name: 'agoMinutes',
      desc: '',
      args: [minutes],
    );
  }

  /// `{hours}h ago`
  String agoHours(int hours) {
    return Intl.message(
      '${hours}h ago',
      name: 'agoHours',
      desc: '',
      args: [hours],
    );
  }

  /// `{days}d ago`
  String agoDays(int days) {
    return Intl.message(
      '${days}d ago',
      name: 'agoDays',
      desc: '',
      args: [days],
    );
  }

  /// `Test Mode Only\n\nGenerates fake data to test charts.`
  String get testModeOnly {
    return Intl.message(
      'Test Mode Only\n\nGenerates fake data to test charts.',
      name: 'testModeOnly',
      desc: '',
      args: [],
    );
  }

  /// `Generate {days} days`
  String generateDays(int days) {
    return Intl.message(
      'Generate $days days',
      name: 'generateDays',
      desc: '',
      args: [days],
    );
  }

  /// `Left Dominant ({percent}%)`
  String leftDominant(int percent) {
    return Intl.message(
      'Left Dominant ($percent%)',
      name: 'leftDominant',
      desc: '',
      args: [percent],
    );
  }

  /// `Right Dominant ({percent}%)`
  String rightDominant(int percent) {
    return Intl.message(
      'Right Dominant ($percent%)',
      name: 'rightDominant',
      desc: '',
      args: [percent],
    );
  }

  /// `Balanced (50/50)`
  String get balanced {
    return Intl.message(
      'Balanced (50/50)',
      name: 'balanced',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete ALL data?\n\nThis action is irreversible.`
  String get deleteAllDataWarning {
    return Intl.message(
      'Are you sure you want to delete ALL data?\n\nThis action is irreversible.',
      name: 'deleteAllDataWarning',
      desc: '',
      args: [],
    );
  }

  /// `Generating {days} days of data...`
  String generatingDaysData(int days) {
    return Intl.message(
      'Generating $days days of data...',
      name: 'generatingDaysData',
      desc: '',
      args: [days],
    );
  }

  /// `{days} days of data generated!`
  String daysDataGenerated(int days) {
    return Intl.message(
      '$days days of data generated!',
      name: 'daysDataGenerated',
      desc: '',
      args: [days],
    );
  }

  /// `Generating with asymmetry ({percent}% left)...`
  String generatingAsymmetry(String percent) {
    return Intl.message(
      'Generating with asymmetry ($percent% left)...',
      name: 'generatingAsymmetry',
      desc: '',
      args: [percent],
    );
  }

  /// `Asymmetric data generated!`
  String get asymmetricDataGenerated {
    return Intl.message(
      'Asymmetric data generated!',
      name: 'asymmetricDataGenerated',
      desc: '',
      args: [],
    );
  }

  /// `Deletion in progress...`
  String get deletionInProgress {
    return Intl.message(
      'Deletion in progress...',
      name: 'deletionInProgress',
      desc: '',
      args: [],
    );
  }

  /// `All data deleted`
  String get allDataDeleted {
    return Intl.message(
      'All data deleted',
      name: 'allDataDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Stats displayed in console`
  String get statsDisplayedInConsole {
    return Intl.message(
      'Stats displayed in console',
      name: 'statsDisplayedInConsole',
      desc: '',
      args: [],
    );
  }

  /// `Export data`
  String get exportData {
    return Intl.message('Export data', name: 'exportData', desc: '', args: []);
  }

  /// `Today`
  String get today {
    return Intl.message('Today', name: 'today', desc: '', args: []);
  }

  /// `7 days`
  String get sevenDays {
    return Intl.message('7 days', name: 'sevenDays', desc: '', args: []);
  }

  /// `30 days`
  String get thirtyDays {
    return Intl.message('30 days', name: 'thirtyDays', desc: '', args: []);
  }

  /// `All`
  String get allData {
    return Intl.message('All', name: 'allData', desc: '', args: []);
  }

  /// `Custom`
  String get custom {
    return Intl.message('Custom', name: 'custom', desc: '', args: []);
  }

  /// `Error: {error}`
  String errorLabel(String error) {
    return Intl.message(
      'Error: $error',
      name: 'errorLabel',
      desc: '',
      args: [error],
    );
  }

  /// `Yesterday`
  String get yesterday {
    return Intl.message('Yesterday', name: 'yesterday', desc: '', args: []);
  }

  /// `{count} events`
  String eventsCount(int count) {
    return Intl.message(
      '$count events',
      name: 'eventsCount',
      desc: '',
      args: [count],
    );
  }

  /// `Battery`
  String get battery {
    return Intl.message('Battery', name: 'battery', desc: '', args: []);
  }

  /// `Steps`
  String get steps {
    return Intl.message('Steps', name: 'steps', desc: '', args: []);
  }

  /// `Connections`
  String get connections {
    return Intl.message('Connections', name: 'connections', desc: '', args: []);
  }

  /// `Movements`
  String get movements {
    return Intl.message('Movements', name: 'movements', desc: '', args: []);
  }

  /// `Events`
  String get events {
    return Intl.message('Events', name: 'events', desc: '', args: []);
  }

  /// `{count} steps`
  String stepsUnit(int count) {
    return Intl.message(
      '$count steps',
      name: 'stepsUnit',
      desc: '',
      args: [count],
    );
  }

  /// `Battery level`
  String get batteryLevelLabel {
    return Intl.message(
      'Battery level',
      name: 'batteryLevelLabel',
      desc: '',
      args: [],
    );
  }

  /// `Excellent`
  String get batteryExcellent {
    return Intl.message(
      'Excellent',
      name: 'batteryExcellent',
      desc: '',
      args: [],
    );
  }

  /// `Good`
  String get batteryGood {
    return Intl.message('Good', name: 'batteryGood', desc: '', args: []);
  }

  /// `Low`
  String get batteryLow {
    return Intl.message('Low', name: 'batteryLow', desc: '', args: []);
  }

  /// `Critical`
  String get batteryCritical {
    return Intl.message(
      'Critical',
      name: 'batteryCritical',
      desc: '',
      args: [],
    );
  }

  /// `Activity detected`
  String get activityDetected {
    return Intl.message(
      'Activity detected',
      name: 'activityDetected',
      desc: '',
      args: [],
    );
  }

  /// `Connected`
  String get connected {
    return Intl.message('Connected', name: 'connected', desc: '', args: []);
  }

  /// `Disconnected`
  String get disconnected {
    return Intl.message(
      'Disconnected',
      name: 'disconnected',
      desc: '',
      args: [],
    );
  }

  /// `Duration: {duration}`
  String duration(String duration) {
    return Intl.message(
      'Duration: $duration',
      name: 'duration',
      desc: '',
      args: [duration],
    );
  }

  /// `Battery: {level}%`
  String batteryAt(int level) {
    return Intl.message(
      'Battery: $level%',
      name: 'batteryAt',
      desc: '',
      args: [level],
    );
  }

  /// `Movement`
  String get movement {
    return Intl.message('Movement', name: 'movement', desc: '', args: []);
  }

  /// `Intense`
  String get intense {
    return Intl.message('Intense', name: 'intense', desc: '', args: []);
  }

  /// `Moderate`
  String get moderate {
    return Intl.message('Moderate', name: 'moderate', desc: '', args: []);
  }

  /// `Light`
  String get light {
    return Intl.message('Light', name: 'light', desc: '', args: []);
  }

  /// `Rest`
  String get rest {
    return Intl.message('Rest', name: 'rest', desc: '', args: []);
  }

  /// `Active: {time}`
  String active(String time) {
    return Intl.message(
      'Active: $time',
      name: 'active',
      desc: '',
      args: [time],
    );
  }

  /// `Magnitude: {value}`
  String magnitudeValue(String value) {
    return Intl.message(
      'Magnitude: $value',
      name: 'magnitudeValue',
      desc: '',
      args: [value],
    );
  }

  /// `Last 7 days`
  String get last7Days {
    return Intl.message('Last 7 days', name: 'last7Days', desc: '', args: []);
  }

  /// `Last 30 days`
  String get last30Days {
    return Intl.message('Last 30 days', name: 'last30Days', desc: '', args: []);
  }

  /// `All data`
  String get allDataLabel {
    return Intl.message('All data', name: 'allDataLabel', desc: '', args: []);
  }

  /// `Custom period`
  String get customPeriod {
    return Intl.message(
      'Custom period',
      name: 'customPeriod',
      desc: '',
      args: [],
    );
  }

  /// `From {start} to {end}`
  String fromToDate(String start, String end) {
    return Intl.message(
      'From $start to $end',
      name: 'fromToDate',
      desc: '',
      args: [start, end],
    );
  }

  /// `Select a date range`
  String get selectDateRange {
    return Intl.message(
      'Select a date range',
      name: 'selectDateRange',
      desc: '',
      args: [],
    );
  }

  /// `Start date`
  String get startDate {
    return Intl.message('Start date', name: 'startDate', desc: '', args: []);
  }

  /// `End date`
  String get endDate {
    return Intl.message('End date', name: 'endDate', desc: '', args: []);
  }

  /// `Apply`
  String get applyButton {
    return Intl.message('Apply', name: 'applyButton', desc: '', args: []);
  }

  /// `Select start date`
  String get selectStartDate {
    return Intl.message(
      'Select start date',
      name: 'selectStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Select end date`
  String get selectEndDate {
    return Intl.message(
      'Select end date',
      name: 'selectEndDate',
      desc: '',
      args: [],
    );
  }

  /// `=== CHART LABELS ===`
  String get _CHART_LABELS {
    return Intl.message(
      '=== CHART LABELS ===',
      name: '_CHART_LABELS',
      desc: '',
      args: [],
    );
  }

  /// `Day`
  String get periodDay {
    return Intl.message('Day', name: 'periodDay', desc: '', args: []);
  }

  /// `Week`
  String get periodWeek {
    return Intl.message('Week', name: 'periodWeek', desc: '', args: []);
  }

  /// `Month`
  String get periodMonth {
    return Intl.message('Month', name: 'periodMonth', desc: '', args: []);
  }

  /// `Period: {period}`
  String periodLabel(String period) {
    return Intl.message(
      'Period: $period',
      name: 'periodLabel',
      desc: '',
      args: [period],
    );
  }

  /// `Period: {period} • Type: {type}`
  String typeLabel(String period, String type) {
    return Intl.message(
      'Period: $period • Type: $type',
      name: 'typeLabel',
      desc: '',
      args: [period, type],
    );
  }

  /// `Loading error`
  String get errorLoadingData {
    return Intl.message(
      'Loading error',
      name: 'errorLoadingData',
      desc: '',
      args: [],
    );
  }

  /// `Balanced`
  String get balancedStatus {
    return Intl.message('Balanced', name: 'balancedStatus', desc: '', args: []);
  }

  /// `Right dominance`
  String get rightDominanceStatus {
    return Intl.message(
      'Right dominance',
      name: 'rightDominanceStatus',
      desc: '',
      args: [],
    );
  }

  /// `Left dominance`
  String get leftDominanceStatus {
    return Intl.message(
      'Left dominance',
      name: 'leftDominanceStatus',
      desc: '',
      args: [],
    );
  }

  /// `Actual ratio`
  String get actualRatio {
    return Intl.message(
      'Actual ratio',
      name: 'actualRatio',
      desc: '',
      args: [],
    );
  }

  /// `Goal`
  String get goal {
    return Intl.message('Goal', name: 'goal', desc: '', args: []);
  }

  /// `Avg: {value} {unit}`
  String averageLabel(String value, String unit) {
    return Intl.message(
      'Avg: $value $unit',
      name: 'averageLabel',
      desc: '',
      args: [value, unit],
    );
  }

  /// `No data available for this day`
  String get noDataForDay {
    return Intl.message(
      'No data available for this day',
      name: 'noDataForDay',
      desc: '',
      args: [],
    );
  }

  /// `{count} records`
  String recordsCount(int count) {
    return Intl.message(
      '$count records',
      name: 'recordsCount',
      desc: '',
      args: [count],
    );
  }

  /// `Ratio:`
  String get ratioLabel {
    return Intl.message('Ratio:', name: 'ratioLabel', desc: '', args: []);
  }

  /// `Goal of the day:`
  String get goalOfTheDay {
    return Intl.message(
      'Goal of the day:',
      name: 'goalOfTheDay',
      desc: '',
      args: [],
    );
  }

  /// `Goal reached`
  String get goalReached {
    return Intl.message(
      'Goal reached',
      name: 'goalReached',
      desc: '',
      args: [],
    );
  }

  /// `Goal not reached (gap: {gap}%)`
  String goalNotReached(String gap) {
    return Intl.message(
      'Goal not reached (gap: $gap%)',
      name: 'goalNotReached',
      desc: '',
      args: [gap],
    );
  }

  /// `Type: {type}`
  String typeDisplay(String type) {
    return Intl.message(
      'Type: $type',
      name: 'typeDisplay',
      desc: '',
      args: [type],
    );
  }

  /// `None`
  String get noLegendData {
    return Intl.message('None', name: 'noLegendData', desc: '', args: []);
  }

  /// `Unbalanced`
  String get unbalanced {
    return Intl.message('Unbalanced', name: 'unbalanced', desc: '', args: []);
  }

  /// `Close`
  String get closeToGoal {
    return Intl.message('Close', name: 'closeToGoal', desc: '', args: []);
  }

  /// `Mon`
  String get weekdayMon {
    return Intl.message('Mon', name: 'weekdayMon', desc: '', args: []);
  }

  /// `Tue`
  String get weekdayTue {
    return Intl.message('Tue', name: 'weekdayTue', desc: '', args: []);
  }

  /// `Wed`
  String get weekdayWed {
    return Intl.message('Wed', name: 'weekdayWed', desc: '', args: []);
  }

  /// `Thu`
  String get weekdayThu {
    return Intl.message('Thu', name: 'weekdayThu', desc: '', args: []);
  }

  /// `Fri`
  String get weekdayFri {
    return Intl.message('Fri', name: 'weekdayFri', desc: '', args: []);
  }

  /// `Sat`
  String get weekdaySat {
    return Intl.message('Sat', name: 'weekdaySat', desc: '', args: []);
  }

  /// `Sun`
  String get weekdaySun {
    return Intl.message('Sun', name: 'weekdaySun', desc: '', args: []);
  }

  /// `=== CONNECTION ERRORS ===`
  String get _CONNECTION_ERRORS {
    return Intl.message(
      '=== CONNECTION ERRORS ===',
      name: '_CONNECTION_ERRORS',
      desc: '',
      args: [],
    );
  }

  /// `Connection timeout. Please make sure the device is nearby and try again.`
  String get connectionErrorTimeout {
    return Intl.message(
      'Connection timeout. Please make sure the device is nearby and try again.',
      name: 'connectionErrorTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Bluetooth communication error. Please restart Bluetooth and try again.`
  String get connectionErrorGatt {
    return Intl.message(
      'Bluetooth communication error. Please restart Bluetooth and try again.',
      name: 'connectionErrorGatt',
      desc: '',
      args: [],
    );
  }

  /// `Bluetooth error. Please check that Bluetooth is enabled.`
  String get connectionErrorBluetooth {
    return Intl.message(
      'Bluetooth error. Please check that Bluetooth is enabled.',
      name: 'connectionErrorBluetooth',
      desc: '',
      args: [],
    );
  }

  /// `Bluetooth permission required. Please grant permissions in settings.`
  String get connectionErrorPermission {
    return Intl.message(
      'Bluetooth permission required. Please grant permissions in settings.',
      name: 'connectionErrorPermission',
      desc: '',
      args: [],
    );
  }

  /// `Connection failed. Please try again.`
  String get connectionErrorUnknown {
    return Intl.message(
      'Connection failed. Please try again.',
      name: 'connectionErrorUnknown',
      desc: '',
      args: [],
    );
  }

  /// `Retrying... (attempt {current}/{max})`
  String connectionRetrying(int current, int max) {
    return Intl.message(
      'Retrying... (attempt $current/$max)',
      name: 'connectionRetrying',
      desc: '',
      args: [current, max],
    );
  }

  /// `Maximum connection attempts reached`
  String get connectionMaxRetriesReached {
    return Intl.message(
      'Maximum connection attempts reached',
      name: 'connectionMaxRetriesReached',
      desc: '',
      args: [],
    );
  }

  /// `=== TIME PREFERENCES PAGE ===`
  String get _TIME_PREFERENCES_PAGE {
    return Intl.message(
      '=== TIME PREFERENCES PAGE ===',
      name: '_TIME_PREFERENCES_PAGE',
      desc: '',
      args: [],
    );
  }

  /// `Time configuration`
  String get timeConfiguration {
    return Intl.message(
      'Time configuration',
      name: 'timeConfiguration',
      desc: '',
      args: [],
    );
  }

  /// `Customize time synchronization settings with your watches`
  String get timeConfigurationDescription {
    return Intl.message(
      'Customize time synchronization settings with your watches',
      name: 'timeConfigurationDescription',
      desc: '',
      args: [],
    );
  }

  /// `Use phone timezone`
  String get usePhoneTimezone {
    return Intl.message(
      'Use phone timezone',
      name: 'usePhoneTimezone',
      desc: '',
      args: [],
    );
  }

  /// `Use custom timezone`
  String get useCustomTimezone {
    return Intl.message(
      'Use custom timezone',
      name: 'useCustomTimezone',
      desc: '',
      args: [],
    );
  }

  /// `Sync now`
  String get syncNow {
    return Intl.message('Sync now', name: 'syncNow', desc: '', args: []);
  }

  /// `Syncing...`
  String get syncing {
    return Intl.message('Syncing...', name: 'syncing', desc: '', args: []);
  }

  /// `No watch connected.\nConnect at least one watch to sync time.`
  String get noWatchConnected {
    return Intl.message(
      'No watch connected.\nConnect at least one watch to sync time.',
      name: 'noWatchConnected',
      desc: '',
      args: [],
    );
  }

  /// `Time synced for: {watches}\nTimezone: {timezone}`
  String timeSyncedFor(String watches, String timezone) {
    return Intl.message(
      'Time synced for: $watches\nTimezone: $timezone',
      name: 'timeSyncedFor',
      desc: '',
      args: [watches, timezone],
    );
  }

  /// `Information`
  String get information {
    return Intl.message('Information', name: 'information', desc: '', args: []);
  }

  /// `Time is automatically synced on each watch connection. Use manual sync after traveling to a different timezone or during daylight saving time changes (summer/winter).`
  String get timeSyncInfo {
    return Intl.message(
      'Time is automatically synced on each watch connection. Use manual sync after traveling to a different timezone or during daylight saving time changes (summer/winter).',
      name: 'timeSyncInfo',
      desc: '',
      args: [],
    );
  }

  /// `=== GOAL SETTINGS PAGE ===`
  String get _GOAL_SETTINGS_PAGE {
    return Intl.message(
      '=== GOAL SETTINGS PAGE ===',
      name: '_GOAL_SETTINGS_PAGE',
      desc: '',
      args: [],
    );
  }

  /// `Periodic check frequency`
  String get periodicCheckFrequency {
    return Intl.message(
      'Periodic check frequency',
      name: 'periodicCheckFrequency',
      desc: '',
      args: [],
    );
  }

  /// `Set how often the system checks if the goal is reached.`
  String get periodicCheckFrequencyDescription {
    return Intl.message(
      'Set how often the system checks if the goal is reached.',
      name: 'periodicCheckFrequencyDescription',
      desc: '',
      args: [],
    );
  }

  /// `Goal type`
  String get goalType {
    return Intl.message('Goal type', name: 'goalType', desc: '', args: []);
  }

  /// `Fixed goal configuration`
  String get fixedGoalConfig {
    return Intl.message(
      'Fixed goal configuration',
      name: 'fixedGoalConfig',
      desc: '',
      args: [],
    );
  }

  /// `Set the goal ratio to achieve directly.`
  String get fixedGoalConfigDescription {
    return Intl.message(
      'Set the goal ratio to achieve directly.',
      name: 'fixedGoalConfigDescription',
      desc: '',
      args: [],
    );
  }

  /// `Dynamic goal configuration`
  String get dynamicGoalConfig {
    return Intl.message(
      'Dynamic goal configuration',
      name: 'dynamicGoalConfig',
      desc: '',
      args: [],
    );
  }

  /// `The goal will be calculated based on the last X days with a daily increase of Y%.`
  String get dynamicGoalConfigDescription {
    return Intl.message(
      'The goal will be calculated based on the last X days with a daily increase of Y%.',
      name: 'dynamicGoalConfigDescription',
      desc: '',
      args: [],
    );
  }

  /// `The goal will be automatically recalculated each day based on your progress.`
  String get dynamicGoalInfo {
    return Intl.message(
      'The goal will be automatically recalculated each day based on your progress.',
      name: 'dynamicGoalInfo',
      desc: '',
      args: [],
    );
  }

  /// `Frequency (minutes)`
  String get frequencyLabel {
    return Intl.message(
      'Frequency (minutes)',
      name: 'frequencyLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter a value`
  String get enterValue {
    return Intl.message(
      'Enter a value',
      name: 'enterValue',
      desc: '',
      args: [],
    );
  }

  /// `Ratio (%)`
  String get ratioPercent {
    return Intl.message('Ratio (%)', name: 'ratioPercent', desc: '', args: []);
  }

  /// `Enter a value between 0 and 100`
  String get enterValueBetween0And100 {
    return Intl.message(
      'Enter a value between 0 and 100',
      name: 'enterValueBetween0And100',
      desc: '',
      args: [],
    );
  }

  /// `Number of days`
  String get numberOfDays {
    return Intl.message(
      'Number of days',
      name: 'numberOfDays',
      desc: '',
      args: [],
    );
  }

  /// `Percentage (%)`
  String get percentageDecimal {
    return Intl.message(
      'Percentage (%)',
      name: 'percentageDecimal',
      desc: '',
      args: [],
    );
  }

  /// `Enter a decimal value`
  String get enterDecimalValue {
    return Intl.message(
      'Enter a decimal value',
      name: 'enterDecimalValue',
      desc: '',
      args: [],
    );
  }

  /// `Calculated over last days with daily increase`
  String get dynamicGoalDescription {
    return Intl.message(
      'Calculated over last days with daily increase',
      name: 'dynamicGoalDescription',
      desc: '',
      args: [],
    );
  }

  /// `=== BLUETOOTH SETTINGS PAGE ===`
  String get _BLUETOOTH_SETTINGS_PAGE {
    return Intl.message(
      '=== BLUETOOTH SETTINGS PAGE ===',
      name: '_BLUETOOTH_SETTINGS_PAGE',
      desc: '',
      args: [],
    );
  }

  /// `Adjust Bluetooth settings to optimize connection and battery consumption`
  String get adjustBluetoothSettings {
    return Intl.message(
      'Adjust Bluetooth settings to optimize connection and battery consumption',
      name: 'adjustBluetoothSettings',
      desc: '',
      args: [],
    );
  }

  /// `Connection`
  String get connection {
    return Intl.message('Connection', name: 'connection', desc: '', args: []);
  }

  /// `seconds`
  String get seconds {
    return Intl.message('seconds', name: 'seconds', desc: '', args: []);
  }

  /// `attempts`
  String get attempts {
    return Intl.message('attempts', name: 'attempts', desc: '', args: []);
  }

  /// `Data recording`
  String get dataRecording {
    return Intl.message(
      'Data recording',
      name: 'dataRecording',
      desc: '',
      args: [],
    );
  }

  /// `minutes`
  String get minutes {
    return Intl.message('minutes', name: 'minutes', desc: '', args: []);
  }

  /// `Preset profiles`
  String get presetProfiles {
    return Intl.message(
      'Preset profiles',
      name: 'presetProfiles',
      desc: '',
      args: [],
    );
  }

  /// `Power Saving`
  String get powerSaving {
    return Intl.message(
      'Power Saving',
      name: 'powerSaving',
      desc: '',
      args: [],
    );
  }

  /// `Spaced connections to preserve battery`
  String get powerSavingDescription {
    return Intl.message(
      'Spaced connections to preserve battery',
      name: 'powerSavingDescription',
      desc: '',
      args: [],
    );
  }

  /// `Balanced`
  String get balancedProfile {
    return Intl.message(
      'Balanced',
      name: 'balancedProfile',
      desc: '',
      args: [],
    );
  }

  /// `Recommended default settings`
  String get balancedProfileDescription {
    return Intl.message(
      'Recommended default settings',
      name: 'balancedProfileDescription',
      desc: '',
      args: [],
    );
  }

  /// `Performance`
  String get performanceProfile {
    return Intl.message(
      'Performance',
      name: 'performanceProfile',
      desc: '',
      args: [],
    );
  }

  /// `Fast connections and frequent data`
  String get performanceProfileDescription {
    return Intl.message(
      'Fast connections and frequent data',
      name: 'performanceProfileDescription',
      desc: '',
      args: [],
    );
  }

  /// `Apply profile?`
  String get applyProfileQuestion {
    return Intl.message(
      'Apply profile?',
      name: 'applyProfileQuestion',
      desc: '',
      args: [],
    );
  }

  /// `This will modify all your Bluetooth settings according to the selected profile.`
  String get applyProfileDescription {
    return Intl.message(
      'This will modify all your Bluetooth settings according to the selected profile.',
      name: 'applyProfileDescription',
      desc: '',
      args: [],
    );
  }

  /// `=== SETTINGS SCREEN EXTRA ===`
  String get _SETTINGS_SCREEN_EXTRA {
    return Intl.message(
      '=== SETTINGS SCREEN EXTRA ===',
      name: '_SETTINGS_SCREEN_EXTRA',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get appearance {
    return Intl.message('Appearance', name: 'appearance', desc: '', args: []);
  }

  /// `Notifications & Vibrations`
  String get notificationsAndVibrations {
    return Intl.message(
      'Notifications & Vibrations',
      name: 'notificationsAndVibrations',
      desc: '',
      args: [],
    );
  }

  /// `Therapy Configuration`
  String get therapyConfiguration {
    return Intl.message(
      'Therapy Configuration',
      name: 'therapyConfiguration',
      desc: '',
      args: [],
    );
  }

  /// `Watches`
  String get watches {
    return Intl.message('Watches', name: 'watches', desc: '', args: []);
  }

  /// `Support`
  String get support {
    return Intl.message('Support', name: 'support', desc: '', args: []);
  }

  /// `Local data`
  String get localData {
    return Intl.message('Local data', name: 'localData', desc: '', args: []);
  }

  /// `Reset app and settings`
  String get resetAppAndSettings {
    return Intl.message(
      'Reset app and settings',
      name: 'resetAppAndSettings',
      desc: '',
      args: [],
    );
  }

  /// `Goal Settings`
  String get goalSettings {
    return Intl.message(
      'Goal Settings',
      name: 'goalSettings',
      desc: '',
      args: [],
    );
  }

  /// `Define goals and verification`
  String get defineGoalsAndVerification {
    return Intl.message(
      'Define goals and verification',
      name: 'defineGoalsAndVerification',
      desc: '',
      args: [],
    );
  }

  /// `Arm to vibrate`
  String get armToVibrate {
    return Intl.message(
      'Arm to vibrate',
      name: 'armToVibrate',
      desc: '',
      args: [],
    );
  }

  /// `Vibration type`
  String get vibrationType {
    return Intl.message(
      'Vibration type',
      name: 'vibrationType',
      desc: '',
      args: [],
    );
  }

  /// `Affected side`
  String get affectedSide {
    return Intl.message(
      'Affected side',
      name: 'affectedSide',
      desc: '',
      args: [],
    );
  }

  /// `Status: {status}`
  String watchStatus(String status) {
    return Intl.message(
      'Status: $status',
      name: 'watchStatus',
      desc: '',
      args: [status],
    );
  }

  /// `Install firmware on both watches`
  String get installFirmwareOnBothWatches {
    return Intl.message(
      'Install firmware on both watches',
      name: 'installFirmwareOnBothWatches',
      desc: '',
      args: [],
    );
  }

  /// `Vibration count`
  String get vibrationCount {
    return Intl.message(
      'Vibration count',
      name: 'vibrationCount',
      desc: '',
      args: [],
    );
  }

  /// `The watch will vibrate this many times for each notification.`
  String get vibrationCountDescription {
    return Intl.message(
      'The watch will vibrate this many times for each notification.',
      name: 'vibrationCountDescription',
      desc: '',
      args: [],
    );
  }

  /// `Custom Vibration`
  String get customVibration {
    return Intl.message(
      'Custom Vibration',
      name: 'customVibration',
      desc: '',
      args: [],
    );
  }

  /// `Full name`
  String get fullName {
    return Intl.message('Full name', name: 'fullName', desc: '', args: []);
  }

  /// `All your local data will be deleted.\nThis action is **irreversible**.`
  String get allLocalDataWillBeDeleted {
    return Intl.message(
      'All your local data will be deleted.\nThis action is **irreversible**.',
      name: 'allLocalDataWillBeDeleted',
      desc: '',
      args: [],
    );
  }

  /// `All your configurations will be reset.\nThis action is **irreversible**.`
  String get allConfigurationsWillBeReset {
    return Intl.message(
      'All your configurations will be reset.\nThis action is **irreversible**.',
      name: 'allConfigurationsWillBeReset',
      desc: '',
      args: [],
    );
  }

  /// `Enter the code above`
  String get enterCodeAbove {
    return Intl.message(
      'Enter the code above',
      name: 'enterCodeAbove',
      desc: '',
      args: [],
    );
  }

  /// `Vibration test in progress...`
  String get vibrationTestInProgress {
    return Intl.message(
      'Vibration test in progress...',
      name: 'vibrationTestInProgress',
      desc: '',
      args: [],
    );
  }

  /// `Number must be between 1 and 10`
  String get numberMustBeBetween1And10 {
    return Intl.message(
      'Number must be between 1 and 10',
      name: 'numberMustBeBetween1And10',
      desc: '',
      args: [],
    );
  }

  /// `Profile photo updated!`
  String get profilePhotoUpdated {
    return Intl.message(
      'Profile photo updated!',
      name: 'profilePhotoUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Reset error: {error}`
  String resetError(String error) {
    return Intl.message(
      'Reset error: $error',
      name: 'resetError',
      desc: '',
      args: [error],
    );
  }

  /// `Settings not loaded. Cannot export.`
  String get settingsNotLoaded {
    return Intl.message(
      'Settings not loaded. Cannot export.',
      name: 'settingsNotLoaded',
      desc: '',
      args: [],
    );
  }

  /// `Data exported successfully ({size} bytes)`
  String dataExportedSuccessfully(int size) {
    return Intl.message(
      'Data exported successfully ($size bytes)',
      name: 'dataExportedSuccessfully',
      desc: '',
      args: [size],
    );
  }

  /// `Export error: {error}`
  String exportError(String error) {
    return Intl.message(
      'Export error: $error',
      name: 'exportError',
      desc: '',
      args: [error],
    );
  }

  /// `File not found`
  String get fileNotFound {
    return Intl.message(
      'File not found',
      name: 'fileNotFound',
      desc: '',
      args: [],
    );
  }

  /// `File is empty`
  String get fileIsEmpty {
    return Intl.message(
      'File is empty',
      name: 'fileIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Settings imported successfully!`
  String get settingsImportedSuccessfully {
    return Intl.message(
      'Settings imported successfully!',
      name: 'settingsImportedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Invalid file format: {error}`
  String invalidFileFormat(String error) {
    return Intl.message(
      'Invalid file format: $error',
      name: 'invalidFileFormat',
      desc: '',
      args: [error],
    );
  }

  /// `Import error: {error}`
  String importError(String error) {
    return Intl.message(
      'Import error: $error',
      name: 'importError',
      desc: '',
      args: [error],
    );
  }

  /// `=== LANGUAGE SETTINGS PAGE ===`
  String get _LANGUAGE_SETTINGS_PAGE {
    return Intl.message(
      '=== LANGUAGE SETTINGS PAGE ===',
      name: '_LANGUAGE_SETTINGS_PAGE',
      desc: '',
      args: [],
    );
  }

  /// `App Language`
  String get appLanguageTitle {
    return Intl.message(
      'App Language',
      name: 'appLanguageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Language changed to {name}`
  String languageChangedToName(String name) {
    return Intl.message(
      'Language changed to $name',
      name: 'languageChangedToName',
      desc: '',
      args: [name],
    );
  }

  /// `=== MOVEMENT SAMPLING PAGE ===`
  String get _MOVEMENT_SAMPLING_PAGE {
    return Intl.message(
      '=== MOVEMENT SAMPLING PAGE ===',
      name: '_MOVEMENT_SAMPLING_PAGE',
      desc: '',
      args: [],
    );
  }

  /// `Movement Sampling`
  String get movementSamplingTitle {
    return Intl.message(
      'Movement Sampling',
      name: 'movementSamplingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Recording frequency`
  String get recordingFrequency {
    return Intl.message(
      'Recording frequency',
      name: 'recordingFrequency',
      desc: '',
      args: [],
    );
  }

  /// `Reduce the volume of stored movement data. Less frequent sampling saves storage space.`
  String get recordingFrequencyDescription {
    return Intl.message(
      'Reduce the volume of stored movement data. Less frequent sampling saves storage space.',
      name: 'recordingFrequencyDescription',
      desc: '',
      args: [],
    );
  }

  /// `Current mode: {mode}`
  String currentMode(String mode) {
    return Intl.message(
      'Current mode: $mode',
      name: 'currentMode',
      desc: '',
      args: [mode],
    );
  }

  /// `Presets`
  String get presets {
    return Intl.message('Presets', name: 'presets', desc: '', args: []);
  }

  /// `Per time unit`
  String get perTimeUnit {
    return Intl.message(
      'Per time unit',
      name: 'perTimeUnit',
      desc: '',
      args: [],
    );
  }

  /// `Define the number of records per hour/minute/second`
  String get perTimeUnitDescription {
    return Intl.message(
      'Define the number of records per hour/minute/second',
      name: 'perTimeUnitDescription',
      desc: '',
      args: [],
    );
  }

  /// `Number of records`
  String get numberOfRecords {
    return Intl.message(
      'Number of records',
      name: 'numberOfRecords',
      desc: '',
      args: [],
    );
  }

  /// `Per`
  String get per {
    return Intl.message('Per', name: 'per', desc: '', args: []);
  }

  /// `Select this mode`
  String get selectThisMode {
    return Intl.message(
      'Select this mode',
      name: 'selectThisMode',
      desc: '',
      args: [],
    );
  }

  /// `Classic modes`
  String get classicModes {
    return Intl.message(
      'Classic modes',
      name: 'classicModes',
      desc: '',
      args: [],
    );
  }

  /// `Max Economy`
  String get economyMax {
    return Intl.message('Max Economy', name: 'economyMax', desc: '', args: []);
  }

  /// `1 sample / 5s (~12/min)`
  String get economyMaxDescription {
    return Intl.message(
      '1 sample / 5s (~12/min)',
      name: 'economyMaxDescription',
      desc: '',
      args: [],
    );
  }

  /// `Economy`
  String get economy {
    return Intl.message('Economy', name: 'economy', desc: '', args: []);
  }

  /// `1 sample / 2s (~30/min)`
  String get economyDescription {
    return Intl.message(
      '1 sample / 2s (~30/min)',
      name: 'economyDescription',
      desc: '',
      args: [],
    );
  }

  /// `Normal`
  String get normal {
    return Intl.message('Normal', name: 'normal', desc: '', args: []);
  }

  /// `1 sample / second (~60/min)`
  String get normalDescription {
    return Intl.message(
      '1 sample / second (~60/min)',
      name: 'normalDescription',
      desc: '',
      args: [],
    );
  }

  /// `Precise`
  String get precise {
    return Intl.message('Precise', name: 'precise', desc: '', args: []);
  }

  /// `2 samples / second (~120/min)`
  String get preciseDescription {
    return Intl.message(
      '2 samples / second (~120/min)',
      name: 'preciseDescription',
      desc: '',
      args: [],
    );
  }

  /// `Maximum`
  String get maximum {
    return Intl.message('Maximum', name: 'maximum', desc: '', args: []);
  }

  /// `Record everything (~600/min)`
  String get maximumDescription {
    return Intl.message(
      'Record everything (~600/min)',
      name: 'maximumDescription',
      desc: '',
      args: [],
    );
  }

  /// `Advanced settings`
  String get advancedSettings {
    return Intl.message(
      'Advanced settings',
      name: 'advancedSettings',
      desc: '',
      args: [],
    );
  }

  /// `Sampling mode`
  String get samplingModeLabel {
    return Intl.message(
      'Sampling mode',
      name: 'samplingModeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Interval`
  String get intervalLabel {
    return Intl.message('Interval', name: 'intervalLabel', desc: '', args: []);
  }

  /// `Change threshold`
  String get changeThresholdLabel {
    return Intl.message(
      'Change threshold',
      name: 'changeThresholdLabel',
      desc: '',
      args: [],
    );
  }

  /// `Max samples per flush`
  String get maxSamplesPerFlushLabel {
    return Intl.message(
      'Max samples per flush',
      name: 'maxSamplesPerFlushLabel',
      desc: '',
      args: [],
    );
  }

  /// `{count} samples`
  String samplesPerFlushUnit(int count) {
    return Intl.message(
      '$count samples',
      name: 'samplesPerFlushUnit',
      desc: '',
      args: [count],
    );
  }

  /// `All`
  String get modeAll {
    return Intl.message('All', name: 'modeAll', desc: '', args: []);
  }

  /// `Interval`
  String get modeInterval {
    return Intl.message('Interval', name: 'modeInterval', desc: '', args: []);
  }

  /// `Threshold`
  String get modeThreshold {
    return Intl.message('Threshold', name: 'modeThreshold', desc: '', args: []);
  }

  /// `Average`
  String get modeAggregate {
    return Intl.message('Average', name: 'modeAggregate', desc: '', args: []);
  }

  /// `Per unit`
  String get modePerUnit {
    return Intl.message('Per unit', name: 'modePerUnit', desc: '', args: []);
  }

  /// `Records all received data`
  String get modeAllDescription {
    return Intl.message(
      'Records all received data',
      name: 'modeAllDescription',
      desc: '',
      args: [],
    );
  }

  /// `Keeps one sample per time interval`
  String get modeIntervalDescription {
    return Intl.message(
      'Keeps one sample per time interval',
      name: 'modeIntervalDescription',
      desc: '',
      args: [],
    );
  }

  /// `Records only during significant changes`
  String get modeThresholdDescription {
    return Intl.message(
      'Records only during significant changes',
      name: 'modeThresholdDescription',
      desc: '',
      args: [],
    );
  }

  /// `Calculates average over interval`
  String get modeAggregateDescription {
    return Intl.message(
      'Calculates average over interval',
      name: 'modeAggregateDescription',
      desc: '',
      args: [],
    );
  }

  /// `Number of records per hour/minute/second`
  String get modePerUnitDescription {
    return Intl.message(
      'Number of records per hour/minute/second',
      name: 'modePerUnitDescription',
      desc: '',
      args: [],
    );
  }

  /// `Second`
  String get timeUnitSecond {
    return Intl.message('Second', name: 'timeUnitSecond', desc: '', args: []);
  }

  /// `Minute`
  String get timeUnitMinute {
    return Intl.message('Minute', name: 'timeUnitMinute', desc: '', args: []);
  }

  /// `Hour`
  String get timeUnitHour {
    return Intl.message('Hour', name: 'timeUnitHour', desc: '', args: []);
  }

  /// `Storage estimate`
  String get storageEstimate {
    return Intl.message(
      'Storage estimate',
      name: 'storageEstimate',
      desc: '',
      args: [],
    );
  }

  /// `~{count} samples/hour`
  String samplesPerHour(int count) {
    return Intl.message(
      '~$count samples/hour',
      name: 'samplesPerHour',
      desc: '',
      args: [count],
    );
  }

  /// `~{value} MB/day (8h usage, 2 watches)`
  String mbPerDay(String value) {
    return Intl.message(
      '~$value MB/day (8h usage, 2 watches)',
      name: 'mbPerDay',
      desc: '',
      args: [value],
    );
  }

  /// `About {count} samples/min per watch`
  String samplesPerMinutePerWatch(int count) {
    return Intl.message(
      'About $count samples/min per watch',
      name: 'samplesPerMinutePerWatch',
      desc: '',
      args: [count],
    );
  }

  /// `{count} samples/hour per watch`
  String samplesPerHourPerWatch(int count) {
    return Intl.message(
      '$count samples/hour per watch',
      name: 'samplesPerHourPerWatch',
      desc: '',
      args: [count],
    );
  }

  /// `=== PRIVACY POLICY PAGE ===`
  String get _PRIVACY_POLICY_PAGE {
    return Intl.message(
      '=== PRIVACY POLICY PAGE ===',
      name: '_PRIVACY_POLICY_PAGE',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicyTitle {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Last updated: {date}`
  String lastUpdated(String date) {
    return Intl.message(
      'Last updated: $date',
      name: 'lastUpdated',
      desc: '',
      args: [date],
    );
  }

  /// `1. Introduction`
  String get introductionTitle {
    return Intl.message(
      '1. Introduction',
      name: 'introductionTitle',
      desc: '',
      args: [],
    );
  }

  /// `We are committed to protecting your privacy. This policy explains what data we collect, why, and how it is used within our application.`
  String get introductionContent {
    return Intl.message(
      'We are committed to protecting your privacy. This policy explains what data we collect, why, and how it is used within our application.',
      name: 'introductionContent',
      desc: '',
      args: [],
    );
  }

  /// `2. Data Collected`
  String get dataCollectedTitle {
    return Intl.message(
      '2. Data Collected',
      name: 'dataCollectedTitle',
      desc: '',
      args: [],
    );
  }

  /// `We collect data related to your activity in the application, including your name, preferences, rehabilitation goals, and data from connected watches. This information is only used to improve your experience and provide personalized tracking.`
  String get dataCollectedContent {
    return Intl.message(
      'We collect data related to your activity in the application, including your name, preferences, rehabilitation goals, and data from connected watches. This information is only used to improve your experience and provide personalized tracking.',
      name: 'dataCollectedContent',
      desc: '',
      args: [],
    );
  }

  /// `3. Data Usage`
  String get dataUsageTitle {
    return Intl.message(
      '3. Data Usage',
      name: 'dataUsageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Data is used to display your progress, notify you when you reach your goals, and personalize app features. No data is shared with third parties without your consent.`
  String get dataUsageContent {
    return Intl.message(
      'Data is used to display your progress, notify you when you reach your goals, and personalize app features. No data is shared with third parties without your consent.',
      name: 'dataUsageContent',
      desc: '',
      args: [],
    );
  }

  /// `4. Security`
  String get securityTitle {
    return Intl.message(
      '4. Security',
      name: 'securityTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your data is stored locally on your device. We do not transmit any information to remote servers without your explicit authorization.`
  String get securityContent {
    return Intl.message(
      'Your data is stored locally on your device. We do not transmit any information to remote servers without your explicit authorization.',
      name: 'securityContent',
      desc: '',
      args: [],
    );
  }

  /// `5. Your Rights`
  String get yourRightsTitle {
    return Intl.message(
      '5. Your Rights',
      name: 'yourRightsTitle',
      desc: '',
      args: [],
    );
  }

  /// `You can view, modify, or delete your data at any time from the application. For any specific request, you can contact our support.`
  String get yourRightsContent {
    return Intl.message(
      'You can view, modify, or delete your data at any time from the application. For any specific request, you can contact our support.',
      name: 'yourRightsContent',
      desc: '',
      args: [],
    );
  }

  /// `6. Contact`
  String get contactTitle {
    return Intl.message('6. Contact', name: 'contactTitle', desc: '', args: []);
  }

  /// `For any questions regarding this policy, please contact: {email}.`
  String contactPolicyContent(String email) {
    return Intl.message(
      'For any questions regarding this policy, please contact: $email.',
      name: 'contactPolicyContent',
      desc: '',
      args: [email],
    );
  }

  /// `Thank you for using our application!`
  String get thankYouForUsing {
    return Intl.message(
      'Thank you for using our application!',
      name: 'thankYouForUsing',
      desc: '',
      args: [],
    );
  }

  /// `=== PROFILE HEADER ===`
  String get _PROFILE_HEADER {
    return Intl.message(
      '=== PROFILE HEADER ===',
      name: '_PROFILE_HEADER',
      desc: '',
      args: [],
    );
  }

  /// `Hello! `
  String get hello {
    return Intl.message('Hello! ', name: 'hello', desc: '', args: []);
  }

  /// `User`
  String get defaultUserName {
    return Intl.message('User', name: 'defaultUserName', desc: '', args: []);
  }

  /// `Ready to take the next steps in your rehabilitation?`
  String get readyForRehabilitation {
    return Intl.message(
      'Ready to take the next steps in your rehabilitation?',
      name: 'readyForRehabilitation',
      desc: '',
      args: [],
    );
  }

  /// `Every day counts!`
  String get everyDayCounts {
    return Intl.message(
      'Every day counts!',
      name: 'everyDayCounts',
      desc: '',
      args: [],
    );
  }

  /// `=== THEME SETTINGS PAGE ===`
  String get _THEME_SETTINGS_PAGE {
    return Intl.message(
      '=== THEME SETTINGS PAGE ===',
      name: '_THEME_SETTINGS_PAGE',
      desc: '',
      args: [],
    );
  }

  /// `App Theme`
  String get appThemeTitle {
    return Intl.message('App Theme', name: 'appThemeTitle', desc: '', args: []);
  }

  /// `Gold (Light)`
  String get themeGoldLight {
    return Intl.message(
      'Gold (Light)',
      name: 'themeGoldLight',
      desc: '',
      args: [],
    );
  }

  /// `Elegant light theme with gold accents`
  String get themeGoldLightDescription {
    return Intl.message(
      'Elegant light theme with gold accents',
      name: 'themeGoldLightDescription',
      desc: '',
      args: [],
    );
  }

  /// `Mint (Light)`
  String get themeMintLight {
    return Intl.message(
      'Mint (Light)',
      name: 'themeMintLight',
      desc: '',
      args: [],
    );
  }

  /// `Light theme with a mint green tint`
  String get themeMintLightDescription {
    return Intl.message(
      'Light theme with a mint green tint',
      name: 'themeMintLightDescription',
      desc: '',
      args: [],
    );
  }

  /// `Gold (Dark)`
  String get themeGoldDark {
    return Intl.message(
      'Gold (Dark)',
      name: 'themeGoldDark',
      desc: '',
      args: [],
    );
  }

  /// `Elegant dark theme with gold accents`
  String get themeGoldDarkDescription {
    return Intl.message(
      'Elegant dark theme with gold accents',
      name: 'themeGoldDarkDescription',
      desc: '',
      args: [],
    );
  }

  /// `Mint (Dark)`
  String get themeMintDark {
    return Intl.message(
      'Mint (Dark)',
      name: 'themeMintDark',
      desc: '',
      args: [],
    );
  }

  /// `Dark theme with a mint tint`
  String get themeMintDarkDescription {
    return Intl.message(
      'Dark theme with a mint tint',
      name: 'themeMintDarkDescription',
      desc: '',
      args: [],
    );
  }

  /// `Follow System`
  String get themeSystem {
    return Intl.message(
      'Follow System',
      name: 'themeSystem',
      desc: '',
      args: [],
    );
  }

  /// `Automatically adapts theme to device settings`
  String get themeSystemDescription {
    return Intl.message(
      'Automatically adapts theme to device settings',
      name: 'themeSystemDescription',
      desc: '',
      args: [],
    );
  }

  /// `Experimental`
  String get themeExperimental {
    return Intl.message(
      'Experimental',
      name: 'themeExperimental',
      desc: '',
      args: [],
    );
  }

  /// `Advanced visual mode for testing`
  String get themeExperimentalDescription {
    return Intl.message(
      'Advanced visual mode for testing',
      name: 'themeExperimentalDescription',
      desc: '',
      args: [],
    );
  }

  /// `Version {version} (build {buildNumber})`
  String versionBuild(String version, String buildNumber) {
    return Intl.message(
      'Version $version (build $buildNumber)',
      name: 'versionBuild',
      desc: '',
      args: [version, buildNumber],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicyMenuItem {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicyMenuItem',
      desc: '',
      args: [],
    );
  }

  /// `The privacy policy will be added here.`
  String get privacyPolicyWillBeAdded {
    return Intl.message(
      'The privacy policy will be added here.',
      name: 'privacyPolicyWillBeAdded',
      desc: '',
      args: [],
    );
  }

  /// `The terms of use will be added here.`
  String get termsOfUseWillBeAdded {
    return Intl.message(
      'The terms of use will be added here.',
      name: 'termsOfUseWillBeAdded',
      desc: '',
      args: [],
    );
  }

  /// `=== PROFILE SETTINGS PAGE ===`
  String get _PROFILE_SETTINGS_PAGE {
    return Intl.message(
      '=== PROFILE SETTINGS PAGE ===',
      name: '_PROFILE_SETTINGS_PAGE',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profileTitle {
    return Intl.message('Profile', name: 'profileTitle', desc: '', args: []);
  }

  /// `Error selecting image: {error}`
  String imageSelectionErrorMessage(String error) {
    return Intl.message(
      'Error selecting image: $error',
      name: 'imageSelectionErrorMessage',
      desc: '',
      args: [error],
    );
  }

  /// `Profile updated successfully`
  String get profileUpdatedSuccessfully {
    return Intl.message(
      'Profile updated successfully',
      name: 'profileUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Tap to change photo`
  String get tapToChangePhoto {
    return Intl.message(
      'Tap to change photo',
      name: 'tapToChangePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get userName {
    return Intl.message('Username', name: 'userName', desc: '', args: []);
  }

  /// `Enter your name`
  String get enterYourName {
    return Intl.message(
      'Enter your name',
      name: 'enterYourName',
      desc: '',
      args: [],
    );
  }

  /// `=== WATCH MANAGEMENT PAGE ===`
  String get _WATCH_MANAGEMENT_PAGE {
    return Intl.message(
      '=== WATCH MANAGEMENT PAGE ===',
      name: '_WATCH_MANAGEMENT_PAGE',
      desc: '',
      args: [],
    );
  }

  /// `Watch {side}`
  String watchSide(String side) {
    return Intl.message(
      'Watch $side',
      name: 'watchSide',
      desc: '',
      args: [side],
    );
  }

  /// `Connected`
  String get watchConnected {
    return Intl.message(
      'Connected',
      name: 'watchConnected',
      desc: '',
      args: [],
    );
  }

  /// `Not connected`
  String get watchNotConnected {
    return Intl.message(
      'Not connected',
      name: 'watchNotConnected',
      desc: '',
      args: [],
    );
  }

  /// `{minutes} minutes ago`
  String syncedAgo(int minutes) {
    return Intl.message(
      '$minutes minutes ago',
      name: 'syncedAgo',
      desc: '',
      args: [minutes],
    );
  }

  /// `Never synced`
  String get neverSynced {
    return Intl.message(
      'Never synced',
      name: 'neverSynced',
      desc: '',
      args: [],
    );
  }

  /// `Vibration tested successfully`
  String get vibrationTestedSuccessfully {
    return Intl.message(
      'Vibration tested successfully',
      name: 'vibrationTestedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Synced just now`
  String get syncedJustNow {
    return Intl.message(
      'Synced just now',
      name: 'syncedJustNow',
      desc: '',
      args: [],
    );
  }

  /// `This action is permanent.`
  String get thisActionIsPermanent {
    return Intl.message(
      'This action is permanent.',
      name: 'thisActionIsPermanent',
      desc: '',
      args: [],
    );
  }

  /// `=== WATCHFACE INSTALL SHEET ===`
  String get _WATCHFACE_INSTALL_SHEET {
    return Intl.message(
      '=== WATCHFACE INSTALL SHEET ===',
      name: '_WATCHFACE_INSTALL_SHEET',
      desc: '',
      args: [],
    );
  }

  /// `Watchface Installation`
  String get watchfaceInstallation {
    return Intl.message(
      'Watchface Installation',
      name: 'watchfaceInstallation',
      desc: '',
      args: [],
    );
  }

  /// `{count} watch(es) connected will be updated with the new watchface.`
  String watchesWillBeUpdated(int count) {
    return Intl.message(
      '$count watch(es) connected will be updated with the new watchface.',
      name: 'watchesWillBeUpdated',
      desc: '',
      args: [count],
    );
  }

  /// `Downloading...`
  String get downloadingInProgress {
    return Intl.message(
      'Downloading...',
      name: 'downloadingInProgress',
      desc: '',
      args: [],
    );
  }

  /// `Device {current}/{total} - {percent}%`
  String deviceProgress(int current, int total, int percent) {
    return Intl.message(
      'Device $current/$total - $percent%',
      name: 'deviceProgress',
      desc: '',
      args: [current, total, percent],
    );
  }

  /// `Speed: {speed} KB/s`
  String speedKbps(String speed) {
    return Intl.message(
      'Speed: $speed KB/s',
      name: 'speedKbps',
      desc: '',
      args: [speed],
    );
  }

  /// `Cancel`
  String get cancelInstallation {
    return Intl.message(
      'Cancel',
      name: 'cancelInstallation',
      desc: '',
      args: [],
    );
  }

  /// `Installation cancelled by user.`
  String get installationCancelledByUser {
    return Intl.message(
      'Installation cancelled by user.',
      name: 'installationCancelledByUser',
      desc: '',
      args: [],
    );
  }

  /// `Install on watch`
  String get installOnWatch {
    return Intl.message(
      'Install on watch',
      name: 'installOnWatch',
      desc: '',
      args: [],
    );
  }

  /// `Install on {count} watches`
  String installOnWatches(int count) {
    return Intl.message(
      'Install on $count watches',
      name: 'installOnWatches',
      desc: '',
      args: [count],
    );
  }

  /// `Installing on device {current}/{total}...`
  String installingOnDevice(int current, int total) {
    return Intl.message(
      'Installing on device $current/$total...',
      name: 'installingOnDevice',
      desc: '',
      args: [current, total],
    );
  }

  /// `=== ONBOARDING SCREEN ===`
  String get _ONBOARDING_SCREEN {
    return Intl.message(
      '=== ONBOARDING SCREEN ===',
      name: '_ONBOARDING_SCREEN',
      desc: '',
      args: [],
    );
  }

  /// `Welcome!`
  String get welcomeTitle {
    return Intl.message('Welcome!', name: 'welcomeTitle', desc: '', args: []);
  }

  /// `Let's configure your profile`
  String get letsConfigureProfile {
    return Intl.message(
      'Let\'s configure your profile',
      name: 'letsConfigureProfile',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get backButton {
    return Intl.message('Back', name: 'backButton', desc: '', args: []);
  }

  /// `Next`
  String get nextButton {
    return Intl.message('Next', name: 'nextButton', desc: '', args: []);
  }

  /// `Start`
  String get startButton {
    return Intl.message('Start', name: 'startButton', desc: '', args: []);
  }

  /// `What is your name?`
  String get whatIsYourName {
    return Intl.message(
      'What is your name?',
      name: 'whatIsYourName',
      desc: '',
      args: [],
    );
  }

  /// `Your first name`
  String get yourFirstName {
    return Intl.message(
      'Your first name',
      name: 'yourFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Ex: Marie`
  String get firstNameExample {
    return Intl.message(
      'Ex: Marie',
      name: 'firstNameExample',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your first name`
  String get pleaseEnterFirstName {
    return Intl.message(
      'Please enter your first name',
      name: 'pleaseEnterFirstName',
      desc: '',
      args: [],
    );
  }

  /// `First name must be at least 2 characters`
  String get firstNameMinLength {
    return Intl.message(
      'First name must be at least 2 characters',
      name: 'firstNameMinLength',
      desc: '',
      args: [],
    );
  }

  /// `Which is your affected side?`
  String get whichSideAffected {
    return Intl.message(
      'Which is your affected side?',
      name: 'whichSideAffected',
      desc: '',
      args: [],
    );
  }

  /// `This information will help us personalize your rehabilitation tracking`
  String get sideInfoDescription {
    return Intl.message(
      'This information will help us personalize your rehabilitation tracking',
      name: 'sideInfoDescription',
      desc: '',
      args: [],
    );
  }

  /// `Left`
  String get leftSide {
    return Intl.message('Left', name: 'leftSide', desc: '', args: []);
  }

  /// `Right`
  String get rightSide {
    return Intl.message('Right', name: 'rightSide', desc: '', args: []);
  }

  /// `=== SPLASH SCREEN ===`
  String get _SPLASH_SCREEN {
    return Intl.message(
      '=== SPLASH SCREEN ===',
      name: '_SPLASH_SCREEN',
      desc: '',
      args: [],
    );
  }

  /// `Loading is taking longer than expected...\nPlease wait or restart the app.`
  String get loadingTakingLonger {
    return Intl.message(
      'Loading is taking longer than expected...\nPlease wait or restart the app.',
      name: 'loadingTakingLonger',
      desc: '',
      args: [],
    );
  }

  /// `=== EMPTY SAVE PAGE ===`
  String get _EMPTY_SAVE_PAGE {
    return Intl.message(
      '=== EMPTY SAVE PAGE ===',
      name: '_EMPTY_SAVE_PAGE',
      desc: '',
      args: [],
    );
  }

  /// `Oops!`
  String get oops {
    return Intl.message('Oops!', name: 'oops', desc: '', args: []);
  }

  /// `Sorry, you have no product in your wishlist`
  String get noProductInWishlist {
    return Intl.message(
      'Sorry, you have no product in your wishlist',
      name: 'noProductInWishlist',
      desc: '',
      args: [],
    );
  }

  /// `Start Adding`
  String get startAddingButton {
    return Intl.message(
      'Start Adding',
      name: 'startAddingButton',
      desc: '',
      args: [],
    );
  }

  /// `=== SEARCH FILTER SCREEN ===`
  String get _SEARCH_FILTER_SCREEN {
    return Intl.message(
      '=== SEARCH FILTER SCREEN ===',
      name: '_SEARCH_FILTER_SCREEN',
      desc: '',
      args: [],
    );
  }

  /// `Filter by date or period`
  String get filterByDateOrPeriod {
    return Intl.message(
      'Filter by date or period',
      name: 'filterByDateOrPeriod',
      desc: '',
      args: [],
    );
  }

  /// `Choose a single date`
  String get chooseSingleDate {
    return Intl.message(
      'Choose a single date',
      name: 'chooseSingleDate',
      desc: '',
      args: [],
    );
  }

  /// `Choose a period`
  String get chooseAPeriod {
    return Intl.message(
      'Choose a period',
      name: 'chooseAPeriod',
      desc: '',
      args: [],
    );
  }

  /// `Reset the filter`
  String get resetTheFilter {
    return Intl.message(
      'Reset the filter',
      name: 'resetTheFilter',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
