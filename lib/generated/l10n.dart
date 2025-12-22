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
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
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
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
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
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Empty list`
  String get emptyList {
    return Intl.message(
      'Empty list',
      name: 'emptyList',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get apply {
    return Intl.message(
      'Apply',
      name: 'apply',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `Finish`
  String get finish {
    return Intl.message(
      'Finish',
      name: 'finish',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message(
      'Refresh',
      name: 'refresh',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get clear {
    return Intl.message(
      'Clear',
      name: 'clear',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Home',
      name: 'navHome',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get navHistory {
    return Intl.message(
      'History',
      name: 'navHistory',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get navProfile {
    return Intl.message(
      'Profile',
      name: 'navProfile',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get navSettings {
    return Intl.message(
      'Settings',
      name: 'navSettings',
      desc: '',
      args: [],
    );
  }

  /// `=== ÉCRAN ACCUEIL ===`
  String get _HOME_SCREEN {
    return Intl.message(
      '=== ÉCRAN ACCUEIL ===',
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

  /// `Learn More`
  String get learnMore {
    return Intl.message(
      'Learn More',
      name: 'learnMore',
      desc: '',
      args: [],
    );
  }

  /// `Asymmetry`
  String get asymmetry {
    return Intl.message(
      'Asymmetry',
      name: 'asymmetry',
      desc: '',
      args: [],
    );
  }

  /// `Battery Level`
  String get batteryLevel {
    return Intl.message(
      'Battery Level',
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
    return Intl.message(
      'Step Count',
      name: 'stepCount',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Forget',
      name: 'forget',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Firmware',
      name: 'firmware',
      desc: '',
      args: [],
    );
  }

  /// `Simulator`
  String get simulator {
    return Intl.message(
      'Simulator',
      name: 'simulator',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Show Stats',
      name: 'showStats',
      desc: '',
      args: [],
    );
  }

  /// `Delete All`
  String get deleteAll {
    return Intl.message(
      'Delete All',
      name: 'deleteAll',
      desc: '',
      args: [],
    );
  }

  /// `Confirm deletion`
  String get confirmDeletion {
    return Intl.message(
      'Confirm deletion',
      name: 'confirmDeletion',
      desc: '',
      args: [],
    );
  }

  /// `=== ÉCRAN HISTORIQUE ===`
  String get _HISTORY_SCREEN {
    return Intl.message(
      '=== ÉCRAN HISTORIQUE ===',
      name: '_HISTORY_SCREEN',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get history {
    return Intl.message(
      'History',
      name: 'history',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `Left`
  String get left {
    return Intl.message(
      'Left',
      name: 'left',
      desc: '',
      args: [],
    );
  }

  /// `Right`
  String get right {
    return Intl.message(
      'Right',
      name: 'right',
      desc: '',
      args: [],
    );
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

  /// `Export in development...`
  String get exportInDevelopment {
    return Intl.message(
      'Export in development...',
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
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Daily Goal',
      name: 'dailyGoal',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Left Watch',
      name: 'leftWatch',
      desc: '',
      args: [],
    );
  }

  /// `Right Watch`
  String get rightWatch {
    return Intl.message(
      'Right Watch',
      name: 'rightWatch',
      desc: '',
      args: [],
    );
  }

  /// `Push Update`
  String get pushUpdate {
    return Intl.message(
      'Push Update',
      name: 'pushUpdate',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
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

  /// `support@monapp.com`
  String get supportEmail {
    return Intl.message(
      'support@monapp.com',
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
    return Intl.message(
      'Import Data',
      name: 'importData',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Save to file',
      name: 'saveToFile',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Reset Data',
      name: 'resetData',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Edit Name',
      name: 'editName',
      desc: '',
      args: [],
    );
  }

  /// `Edit Name`
  String get editNameTitle {
    return Intl.message(
      'Edit Name',
      name: 'editNameTitle',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Data reset.',
      name: 'dataReset',
      desc: '',
      args: [],
    );
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

  /// `=== PAGE À PROPOS ===`
  String get _ABOUT_PAGE {
    return Intl.message(
      '=== PAGE À PROPOS ===',
      name: '_ABOUT_PAGE',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Use`
  String get termsOfUse {
    return Intl.message(
      'Terms of Use',
      name: 'termsOfUse',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Credits',
      name: 'credits',
      desc: '',
      args: [],
    );
  }

  /// `Developed by Health & Tech team – 2025`
  String get developedBy {
    return Intl.message(
      'Developed by Health & Tech team – 2025',
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
    return Intl.message(
      'Settings',
      name: 'settingsButton',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Connect',
      name: 'connect',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Start Scan',
      name: 'startScan',
      desc: '',
      args: [],
    );
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

  /// `Rename Watch`
  String get renameWatch {
    return Intl.message(
      'Rename Watch',
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

  /// `Watch synchronized`
  String get watchSynced {
    return Intl.message(
      'Watch synchronized',
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

  /// `Firmware up to date.`
  String get firmwareUpToDate {
    return Intl.message(
      'Firmware up to date.',
      name: 'firmwareUpToDate',
      desc: '',
      args: [],
    );
  }

  /// `Delete watch?`
  String get deleteWatchQuestion {
    return Intl.message(
      'Delete watch?',
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

  /// `Test Vibration`
  String get testVibration {
    return Intl.message(
      'Test Vibration',
      name: 'testVibration',
      desc: '',
      args: [],
    );
  }

  /// `Firmware Update`
  String get firmwareUpdate {
    return Intl.message(
      'Firmware Update',
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

  /// `Delete Photo`
  String get deletePhoto {
    return Intl.message(
      'Delete Photo',
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
    return Intl.message(
      'Light Theme',
      name: 'lightTheme',
      desc: '',
      args: [],
    );
  }

  /// `Dark Theme`
  String get darkTheme {
    return Intl.message(
      'Dark Theme',
      name: 'darkTheme',
      desc: '',
      args: [],
    );
  }

  /// `Light Gold`
  String get lightGold {
    return Intl.message(
      'Light Gold',
      name: 'lightGold',
      desc: '',
      args: [],
    );
  }

  /// `Dark Gold`
  String get darkGold {
    return Intl.message(
      'Dark Gold',
      name: 'darkGold',
      desc: '',
      args: [],
    );
  }

  /// `Light Mint`
  String get lightMint {
    return Intl.message(
      'Light Mint',
      name: 'lightMint',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mint`
  String get darkMint {
    return Intl.message(
      'Dark Mint',
      name: 'darkMint',
      desc: '',
      args: [],
    );
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

  /// `=== PRÉFÉRENCES GRAPHIQUES ===`
  String get _CHART_PREFERENCES {
    return Intl.message(
      '=== PRÉFÉRENCES GRAPHIQUES ===',
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
    return Intl.message(
      'Reload',
      name: 'reload',
      desc: '',
      args: [],
    );
  }

  /// `Install`
  String get install {
    return Intl.message(
      'Install',
      name: 'install',
      desc: '',
      args: [],
    );
  }

  /// `Updating`
  String get updating {
    return Intl.message(
      'Updating',
      name: 'updating',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Error',
      name: 'updateFailed',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Metrics',
      name: 'metrics',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Disconnect',
      name: 'disconnect',
      desc: '',
      args: [],
    );
  }

  /// `Reconnect`
  String get reconnect {
    return Intl.message(
      'Reconnect',
      name: 'reconnect',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Balance',
      name: 'balance',
      desc: '',
      args: [],
    );
  }

  /// `Magnitude`
  String get magnitude {
    return Intl.message(
      'Magnitude',
      name: 'magnitude',
      desc: '',
      args: [],
    );
  }

  /// `Axis`
  String get axis {
    return Intl.message(
      'Axis',
      name: 'axis',
      desc: '',
      args: [],
    );
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

  /// `New Name`
  String get newName {
    return Intl.message(
      'New Name',
      name: 'newName',
      desc: '',
      args: [],
    );
  }

  /// `=== ÉTATS VIDES ===`
  String get _EMPTY_STATE {
    return Intl.message(
      '=== ÉTATS VIDES ===',
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
