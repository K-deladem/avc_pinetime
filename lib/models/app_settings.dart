import 'package:flutter_bloc_app_template/app/lang_helper.dart';
import 'package:flutter_bloc_app_template/app/theme_helper.dart';
import 'package:flutter_bloc_app_template/extension/notification_strategy.dart';
import 'package:flutter_bloc_app_template/extension/vibration_arm.dart';
import 'package:flutter_bloc_app_template/extension/vibration_mode.dart';

import 'arm_side.dart';
import 'chart_preferences.dart';
import 'goal_config.dart';
import 'movement_sampling_settings.dart';
import 'time_preferences.dart';

class AppSettings {
  final bool isFirstLaunch;
  final String userName;
  final String? profileImagePath;
  final int collectionFrequency;
  final int dailyObjective;
  final ArmSide affectedSide;
  final VibrationMode vibrationMode;
  final VibrationArm vibrationTargetArm;
  final int checkFrequencyMin;
  final NotificationStrategy notificationStrategy;
  final bool notificationsEnabled;
  final int vibrationOnMs;
  final int vibrationOffMs;
  final String leftWatchName;
  final String rightWatchName;
  final int vibrationRepeat;
  final AppLanguage language;
  final AppTheme themeMode;
  final ChartPreferences chartPreferences;

  // ========== PARAMÈTRES BLUETOOTH ==========
  final int bluetoothScanTimeout; // Durée de scan (secondes)
  final int bluetoothConnectionTimeout; // Délai de connexion (secondes)
  final int bluetoothMaxRetries; // Tentatives de reconnexion
  final int dataRecordInterval; // Intervalle enregistrement données (minutes)
  final int
      movementRecordInterval; // Intervalle enregistrement mouvement (secondes)

  // ========== NOUVEAUX PARAMÈTRES ==========
  final int checkRatioFrequencyMin; // Fréquence de vérification périodique du ratio (minutes)
  final GoalConfig goalConfig; // Configuration de l'objectif (fixe ou dynamique)
  final TimePreferences timePreferences; // Préférences de synchronisation de l'heure
  final MovementSamplingSettings movementSampling; // Paramètres d'échantillonnage mouvement

  AppSettings({
    this.isFirstLaunch = true,
    required this.userName,
    this.profileImagePath,
    required this.collectionFrequency,
    required this.dailyObjective,
    required this.affectedSide,
    required this.vibrationMode,
    required this.vibrationTargetArm,
    required this.checkFrequencyMin,
    required this.notificationStrategy,
    required this.notificationsEnabled,
    required this.vibrationOnMs,
    required this.vibrationOffMs,
    required this.vibrationRepeat,
    required this.leftWatchName,
    required this.rightWatchName,
    required this.language,
    required this.themeMode,
    this.chartPreferences = const ChartPreferences(),
    required this.bluetoothScanTimeout,
    required this.bluetoothConnectionTimeout,
    required this.bluetoothMaxRetries,
    required this.dataRecordInterval,
    required this.movementRecordInterval,
    required this.checkRatioFrequencyMin,
    required this.goalConfig,
    this.timePreferences = const TimePreferences(),
    this.movementSampling = const MovementSamplingSettings(),
  });

  Map<String, dynamic> toMap() => {
        'isFirstLaunch': isFirstLaunch ? 1 : 0,
        'userName': userName,
        'profileImagePath': profileImagePath,
        'collectionFrequency': collectionFrequency,
        'dailyObjective': dailyObjective,
        'affectedSide': affectedSide.label,
        'vibrationMode': vibrationMode.label,
        'vibrationTargetArm': vibrationTargetArm.label,
        'checkFrequencyMin': checkFrequencyMin,
        'notificationStrategy': notificationStrategy.label,
        'notificationsEnabled': notificationsEnabled ? 1 : 0,
        'vibrationOnMs': vibrationOnMs,
        'vibrationOffMs': vibrationOffMs,
        'vibrationRepeat': vibrationRepeat,
        'leftWatchName': leftWatchName,
        'rightWatchName': rightWatchName,
        'language': language.code,
        'themeMode': themeMode.toJson(), // correction ici
        ...chartPreferences.toMap(),
        'bluetoothScanTimeout': bluetoothScanTimeout,
        'bluetoothConnectionTimeout': bluetoothConnectionTimeout,
        'bluetoothMaxRetries': bluetoothMaxRetries,
        'dataRecordInterval': dataRecordInterval,
        'movementRecordInterval': movementRecordInterval,
        'checkRatioFrequencyMin': checkRatioFrequencyMin,
        ...goalConfig.toMap(),
        ...timePreferences.toMap(),
        ...movementSampling.toMap(),
      };

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
        isFirstLaunch: (map['isFirstLaunch'] as int? ?? 1) == 1,
        userName: map['userName'] as String? ?? '',
        profileImagePath: map['profileImagePath'] as String?,
        collectionFrequency: map['collectionFrequency'] as int? ?? 60,
        dailyObjective: map['dailyObjective'] as int? ?? 10000,
        affectedSide: ArmSideExtension.fromLabel(
            map['affectedSide'] as String? ?? 'Gauche'),
        vibrationMode: VibrationModeExtension.fromLabel(
            map['vibrationMode'] as String? ?? 'none'),
        vibrationTargetArm: VibrationArmExtension.fromLabel(
            map['vibrationTargetArm'] as String? ?? 'both'),
        checkFrequencyMin: map['checkFrequencyMin'] as int? ?? 30,
        notificationStrategy: NotificationStrategyExtension.fromLabel(
            map['notificationStrategy'] as String? ?? 'balanced'),
        notificationsEnabled: (map['notificationsEnabled'] as int? ?? 0) == 1,
        vibrationOnMs: map['vibrationOnMs'] as int? ?? 300,
        vibrationOffMs: map['vibrationOffMs'] as int? ?? 200,
        vibrationRepeat: map['vibrationRepeat'] as int? ?? 3,
        leftWatchName: map['leftWatchName'] as String? ?? 'Left Watch',
        rightWatchName: map['rightWatchName'] as String? ?? 'Right Watch',
        language:
            AppLanguageExtension.fromCode(map['language'] as String? ?? 'fr'),
        themeMode: AppThemeJsonExtension.fromJson(
            map['themeMode'] as String? ?? 'system'),
        chartPreferences: ChartPreferences.fromMap(map),
        bluetoothScanTimeout: map['bluetoothScanTimeout'] as int? ?? 15,
        bluetoothConnectionTimeout:
            map['bluetoothConnectionTimeout'] as int? ?? 30,
        bluetoothMaxRetries: map['bluetoothMaxRetries'] as int? ?? 5,
        dataRecordInterval: map['dataRecordInterval'] as int? ?? 2,
        movementRecordInterval: map['movementRecordInterval'] as int? ?? 30,
        checkRatioFrequencyMin: map['checkRatioFrequencyMin'] as int? ?? 30,
        goalConfig: GoalConfig.fromMap(map),
        timePreferences: TimePreferences.fromMap(map),
        movementSampling: MovementSamplingSettings.fromMap(map),
      );

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        isFirstLaunch: json['isFirstLaunch'] is bool
            ? json['isFirstLaunch'] as bool
            : (json['isFirstLaunch'] as int? ?? 1) == 1,
        userName: json['userName'] as String? ?? '',
        profileImagePath: json['profileImagePath'] as String?,
        collectionFrequency: json['collectionFrequency'] as int? ?? 60,
        dailyObjective: json['dailyObjective'] as int? ?? 10000,
        affectedSide: ArmSideExtension.fromLabel(
            json['affectedSide'] as String? ?? 'Gauche'),
        vibrationMode: VibrationModeExtension.fromLabel(
            json['vibrationMode'] as String? ?? 'none'),
        vibrationTargetArm: VibrationArmExtension.fromLabel(
            json['vibrationTargetArm'] as String? ?? 'both'),
        checkFrequencyMin: json['checkFrequencyMin'] as int? ?? 30,
        notificationStrategy: NotificationStrategyExtension.fromLabel(
            json['notificationStrategy'] as String? ?? 'balanced'),
        notificationsEnabled: json['notificationsEnabled'] is bool
            ? json['notificationsEnabled'] as bool
            : (json['notificationsEnabled'] as int? ?? 0) == 1,
        vibrationOnMs: json['vibrationOnMs'] as int? ?? 300,
        vibrationOffMs: json['vibrationOffMs'] as int? ?? 200,
        vibrationRepeat: json['vibrationRepeat'] as int? ?? 3,
        leftWatchName: json['leftWatchName'] as String? ?? 'Left Watch',
        rightWatchName: json['rightWatchName'] as String? ?? 'Right Watch',
        language:
            AppLanguageExtension.fromCode(json['language'] as String? ?? 'fr'),
        themeMode: AppThemeJsonExtension.fromJson(
            json['themeMode'] as String? ?? 'system'),
        chartPreferences: ChartPreferences.fromJson(json),
        bluetoothScanTimeout: json['bluetoothScanTimeout'] as int? ?? 15,
        bluetoothConnectionTimeout:
            json['bluetoothConnectionTimeout'] as int? ?? 30,
        bluetoothMaxRetries: json['bluetoothMaxRetries'] as int? ?? 5,
        dataRecordInterval: json['dataRecordInterval'] as int? ?? 2,
        movementRecordInterval: json['movementRecordInterval'] as int? ?? 30,
        checkRatioFrequencyMin: json['checkRatioFrequencyMin'] as int? ?? 30,
        goalConfig: GoalConfig.fromJson(json),
        timePreferences: TimePreferences.fromJson(json),
        movementSampling: MovementSamplingSettings.fromJson(json),
      );

  Map<String, dynamic> toJson() => {
        'isFirstLaunch': isFirstLaunch,
        'userName': userName,
        'profileImagePath': profileImagePath,
        'collectionFrequency': collectionFrequency,
        'dailyObjective': dailyObjective,
        'affectedSide': affectedSide.label,
        'vibrationMode': vibrationMode.label,
        'vibrationTargetArm': vibrationTargetArm.label,
        'checkFrequencyMin': checkFrequencyMin,
        'notificationStrategy': notificationStrategy.label,
        'notificationsEnabled': notificationsEnabled,
        'vibrationOnMs': vibrationOnMs,
        'vibrationOffMs': vibrationOffMs,
        'vibrationRepeat': vibrationRepeat,
        'leftWatchName': leftWatchName,
        'rightWatchName': rightWatchName,
        'language': language.code,
        'themeMode': themeMode,
        ...chartPreferences.toJson(),
        'bluetoothScanTimeout': bluetoothScanTimeout,
        'bluetoothConnectionTimeout': bluetoothConnectionTimeout,
        'bluetoothMaxRetries': bluetoothMaxRetries,
        'dataRecordInterval': dataRecordInterval,
        'movementRecordInterval': movementRecordInterval,
        'checkRatioFrequencyMin': checkRatioFrequencyMin,
        ...goalConfig.toJson(),
        ...timePreferences.toJson(),
        ...movementSampling.toJson(),
      };

  AppSettings copyWith({
    bool? isFirstLaunch,
    String? userName,
    String? profileImagePath,
    int? collectionFrequency,
    int? dailyObjective,
    ArmSide? affectedSide,
    VibrationMode? vibrationMode,
    VibrationArm? vibrationTargetArm,
    int? checkFrequencyMin,
    NotificationStrategy? notificationStrategy,
    bool? notificationsEnabled,
    int? vibrationOnMs,
    int? vibrationOffMs,
    int? vibrationRepeat,
    String? leftWatchName,
    String? rightWatchName,
    AppLanguage? language,
    AppTheme? themeMode,
    ChartPreferences? chartPreferences,
    int? bluetoothScanTimeout,
    int? bluetoothConnectionTimeout,
    int? bluetoothMaxRetries,
    int? dataRecordInterval,
    int? movementRecordInterval,
    int? checkRatioFrequencyMin,
    GoalConfig? goalConfig,
    TimePreferences? timePreferences,
    MovementSamplingSettings? movementSampling,
  }) {
    return AppSettings(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      userName: userName ?? this.userName,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      collectionFrequency: collectionFrequency ?? this.collectionFrequency,
      dailyObjective: dailyObjective ?? this.dailyObjective,
      affectedSide: affectedSide ?? this.affectedSide,
      vibrationMode: vibrationMode ?? this.vibrationMode,
      vibrationTargetArm: vibrationTargetArm ?? this.vibrationTargetArm,
      checkFrequencyMin: checkFrequencyMin ?? this.checkFrequencyMin,
      notificationStrategy: notificationStrategy ?? this.notificationStrategy,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      vibrationOnMs: vibrationOnMs ?? this.vibrationOnMs,
      vibrationOffMs: vibrationOffMs ?? this.vibrationOffMs,
      vibrationRepeat: vibrationRepeat ?? this.vibrationRepeat,
      leftWatchName: leftWatchName ?? this.leftWatchName,
      rightWatchName: rightWatchName ?? this.rightWatchName,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      chartPreferences: chartPreferences ?? this.chartPreferences,
      bluetoothScanTimeout: bluetoothScanTimeout ?? this.bluetoothScanTimeout,
      bluetoothConnectionTimeout:
          bluetoothConnectionTimeout ?? this.bluetoothConnectionTimeout,
      bluetoothMaxRetries: bluetoothMaxRetries ?? this.bluetoothMaxRetries,
      dataRecordInterval: dataRecordInterval ?? this.dataRecordInterval,
      movementRecordInterval:
          movementRecordInterval ?? this.movementRecordInterval,
      checkRatioFrequencyMin:
          checkRatioFrequencyMin ?? this.checkRatioFrequencyMin,
      goalConfig: goalConfig ?? this.goalConfig,
      timePreferences: timePreferences ?? this.timePreferences,
      movementSampling: movementSampling ?? this.movementSampling,
    );
  }
}
