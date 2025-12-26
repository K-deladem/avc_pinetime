import 'dart:convert';
import 'package:flutter_bloc_app_template/generated/l10n.dart';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Imports de l'application
import 'package:flutter_bloc_app_template/app/app_database.dart';
import 'package:flutter_bloc_app_template/app/lang_helper.dart';
import 'package:flutter_bloc_app_template/app/theme_helper.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_event.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';
import 'package:flutter_bloc_app_template/bloc/watch/watch_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/watch/watch_event.dart';
import 'package:flutter_bloc_app_template/bloc/watch/watch_state.dart';
import 'package:flutter_bloc_app_template/extension/notification_strategy.dart';
import 'package:flutter_bloc_app_template/extension/vibration_arm.dart';
import 'package:flutter_bloc_app_template/extension/vibration_mode.dart';
import 'package:flutter_bloc_app_template/models/app_settings.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/models/chart_preferences.dart';
import 'package:flutter_bloc_app_template/models/goal_config.dart';
import 'package:flutter_bloc_app_template/models/time_preferences.dart';
import 'package:flutter_bloc_app_template/models/watch_device.dart';
import 'package:flutter_bloc_app_template/ui/setting/page/movement_sampling_page.dart';
import 'package:flutter_bloc_app_template/routes/app_routes.dart';
import 'package:flutter_bloc_app_template/service/goal_check_service.dart';
import 'package:flutter_bloc_app_template/constants/app_constants.dart';
import 'package:flutter_bloc_app_template/ui/setting/page/watchface_Install_Page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ============================================================================
  // VARIABLES D'ÉTAT LOCALES (synchronisées avec le BLoC)
  // ============================================================================

  // Profil utilisateur
  String userName = "Your Name";
  File? profileImage;

  // Préférences générales
  bool notificationsEnabled = true;
  AppLanguage language = AppLanguage.fr;
  AppTheme themeMode = AppTheme.lightGold;

  // Configuration de l'application
  int collectionFrequency = 30;
  int dailyObjective = 80;
  int checkFrequencyMin = 10;
  ArmSide affectedSide = ArmSide.left;

  // Configuration des vibrations
  VibrationArm vibrationTargetArm = VibrationArm.both;
  VibrationMode vibrationMode = VibrationMode.doubleShort;
  int customRepeat = 2;

  // Configuration des montres
  String leftWatchName = 'PineTime L';
  String rightWatchName = 'PineTime R';

  // Paramètres Bluetooth
  int bluetoothScanTimeout = 15;
  int bluetoothConnectionTimeout = 30;
  int bluetoothMaxRetries = 5;
  int dataRecordInterval = 2;
  int movementRecordInterval = 30;

  // Paramètres avancés
  int checkRatioFrequencyMin = 30;
  GoalConfig goalConfig = const GoalConfig.fixed(ratio: 80);
  ChartPreferences chartPreferences = const ChartPreferences();
  TimePreferences timePreferences = const TimePreferences();

  // Timestamp pour forcer la mise à jour de l'image
  int _imageTimestamp = DateTime.now().millisecondsSinceEpoch;

  // ============================================================================
  // CYCLE DE VIE DU WIDGET
  // ============================================================================

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(LoadSettings());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return _buildScaffoldContent(context, state);
      },
    );
  }

  // ============================================================================
  // CONSTRUCTION DE L'INTERFACE
  // ============================================================================

  Widget _buildScaffoldContent(BuildContext context, SettingsState state) {
    if (state is SettingsInitial || state is SettingsLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is SettingsError) {
      return Scaffold(
        appBar: AppBar(title: Text(S.of(context).error)),
        body: Center(child: Text(state.message)),
      );
    }

    if (state is SettingsLoaded) {
      _applySettings(state.settings);
      return _buildMainScaffold(context);
    }

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildMainScaffold(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileSection(),
          _buildAppearanceSection(),
          _buildNotificationsSection(),
          _buildTherapyConfigSection(),
          _buildWatchesSection(),
          _buildDataSection(),
          _buildSupportSection(),
          _buildResetSection(),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(S.of(context).settings),
      elevation: 0,
      scrolledUnderElevation: 3,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      centerTitle: true,
    );
  }

  // ============================================================================
  // SECTIONS DE L'INTERFACE
  // ============================================================================

  Widget _buildProfileSection() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          _buildProfileAvatar(theme),
          const SizedBox(height: 12),
          _buildProfileInfo(theme),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(ThemeData theme) {
    return Stack(
      children: [
        //   PURE BLOC: AnimatedSwitcher + Key unique pour forcer rebuild
        // OPTIMISÉ: Pas de File.existsSync() bloquant - utilise errorBuilder
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: CircleAvatar(
            key: ValueKey(
                'avatar_${profileImage?.path ?? 'no_image'}_$_imageTimestamp'),
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
            onBackgroundImageError: profileImage != null
                ? (exception, stackTrace) {
                    // Image invalide, sera traité par le child icon
                  }
                : null,
            child: profileImage == null
                ? Icon(Icons.person, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant)
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(ThemeData theme) {
    return Column(
      children: [
        Text(
          userName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton.icon(
          onPressed: _showNameDialog,
          icon: Icon(
            Icons.edit,
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
          label: Text(
            S.of(context).editName,
            style: TextStyle(
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(S.of(context).appearance),
        _buildLanguageNavigation(),
        _buildThemeNavigation(),
        _buildChartPreferencesNavigation(),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(S.of(context).notificationsAndVibrations),
        _buildNotificationSwitch(),
        _buildVibrationTypeDropdown(),
        _buildVibrationArmDropdown(),
        _buildTestVibrationButton(),
      ],
    );
  }

  Widget _buildTherapyConfigSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(S.of(context).therapyConfiguration),
        _buildAffectedSideSelector(),
        _buildGoalSettingsNavigation(),
        _buildBluetoothNavigation(),
      ],
    );
  }

  Widget _buildWatchesSection() {
    final watchState = context.watch<WatchBloc>().state;
    WatchDevice? leftWatch;
    WatchDevice? rightWatch;

    if (watchState is WatchLoaded) {
      for (final device in watchState.devices) {
        if (device.armSide == ArmSide.left) {
          leftWatch = device;
        } else if (device.armSide == ArmSide.right) {
          rightWatch = device;
        }
      }
    }

    // Vérifier si une mise à jour est nécessaire (version < 1.20.0)
    final needsUpdate = _needsFirmwareUpdate(leftWatch, rightWatch);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(S.of(context).watches),
        _buildSyncTile(),
        if (leftWatch != null) _buildLeftWatchTile(leftWatch),
        if (rightWatch != null) _buildRightWatchTile(rightWatch),
        if (needsUpdate) _buildUpdateWatchesTile(),
      ],
    );
  }

  /// Vérifie si au moins une montre nécessite une mise à jour firmware
  bool _needsFirmwareUpdate(WatchDevice? leftWatch, WatchDevice? rightWatch) {
    const targetVersion = '1.20.0';

    if (leftWatch != null && _isVersionBelow(leftWatch.firmwareVersion, targetVersion)) {
      return true;
    }
    if (rightWatch != null && _isVersionBelow(rightWatch.firmwareVersion, targetVersion)) {
      return true;
    }
    return false;
  }

  /// Compare deux versions sémantiques (X.Y.Z)
  /// Retourne true si version < targetVersion
  bool _isVersionBelow(String? version, String targetVersion) {
    if (version == null || version.isEmpty) {
      // Si pas de version connue, on considère qu'une mise à jour est nécessaire
      return true;
    }

    try {
      final vParts = version.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final tParts = targetVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      // Compléter avec des zéros si nécessaire
      while (vParts.length < 3) vParts.add(0);
      while (tParts.length < 3) tParts.add(0);

      // Comparaison composant par composant
      for (int i = 0; i < 3; i++) {
        if (vParts[i] < tParts[i]) return true;
        if (vParts[i] > tParts[i]) return false;
      }

      // Versions égales
      return false;
    } catch (e) {
      // En cas d'erreur de parsing, on considère qu'une mise à jour est nécessaire
      return true;
    }
  }

  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(S.of(context).support),
        _buildPrivacyTile(),
        _buildAboutTile(),
        _buildContactTile(),
      ],
    );
  }

  Widget _buildDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(S.of(context).localData),
        _buildMovementSamplingTile(),
        _buildShareDataTile(),
        _buildImportDataTile(),
        _buildExportDataTile(),
      ],
    );
  }

  Widget _buildResetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(S.of(context).resetAppAndSettings),
        _buildResetConfigTile(),
        _buildResetDataTile(),
      ],
    );
  }

  // ============================================================================
  // WIDGETS RÉUTILISABLES
  // ============================================================================

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final theme = Theme.of(context);
    return SwitchListTile(
      secondary: Icon(
        icon,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        S.of(context).receiveDailyReminders,
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: theme.colorScheme.primary,
    );
  }

  Widget _buildNavTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            )
          : null,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  // ============================================================================
  // TILES SPÉCIFIQUES
  // ============================================================================

  Widget _buildNotificationSwitch() {
    return _buildSwitchTile(
      Icons.notifications_active_outlined,
      S.of(context).notifications,
      notificationsEnabled,
      (v) {
        //   PURE BLOC: Mise à jour directe puis BLoC
        notificationsEnabled = v;
        _saveSettings();
      },
    );
  }

  Widget _buildLanguageNavigation() {
    return _buildNavTile(
      Icons.language,
      S.of(context).language,
      language.displayName,
      () async {
        final selected = await Navigator.pushNamed(context, AppRoutes.language);
        if (!mounted) return;
        if (selected is AppLanguage && selected != language) {
          language = selected;
          _saveSettings();
        }
      },
    );
  }

  Widget _buildThemeNavigation() {
    return _buildNavTile(
      Icons.dark_mode_outlined,
      S.of(context).theme,
      themeMode.label,
      () async {
        final selected =
            await Navigator.pushNamed(context, AppRoutes.themeSettings);
        if (!mounted) return;
        if (selected is AppTheme && selected != themeMode) {
          themeMode = selected;
          _saveSettings();
        }
      },
    );
  }

  Widget _buildBluetoothNavigation() {
    return _buildNavTile(
      Icons.bluetooth_outlined,
      S.of(context).bluetoothSettings,
      S.of(context).connectionAndDataRecording,
      () async {
        await Navigator.pushNamed(context, AppRoutes.bluetoothSettings);
        // Recharger les paramètres après modification
        if (!mounted) return;
        context.read<SettingsBloc>().add(LoadSettings());
      },
    );
  }

  Widget _buildChartPreferencesNavigation() {
    return _buildNavTile(
      Icons.assessment_outlined,
      S.of(context).displayedCharts,
      S.of(context).chooseChartsToDisplay,
      () async {
        await Navigator.pushNamed(context, AppRoutes.chartPreferences);
        // Recharger les paramètres après modification
        if (!mounted) return;
        context.read<SettingsBloc>().add(LoadSettings());
      },
    );
  }

  Widget _buildGoalSettingsNavigation() {
    return _buildNavTile(
      Icons.flag_outlined,
      S.of(context).goalSettings,
      S.of(context).defineGoalsAndVerification,
      () async {
        await Navigator.pushNamed(context, AppRoutes.goalSettings);
        // Recharger les paramètres après modification
        if (!mounted) return;
        context.read<SettingsBloc>().add(LoadSettings());
      },
    );
  }

  Widget _buildVibrationArmDropdown() {
    return _buildDropdownTile(
      Icons.back_hand_outlined,
      S.of(context).armToVibrate,
      vibrationTargetArm.label,
      VibrationArm.values.map((e) => e.label).toList(),
      (v) {
        final selected = VibrationArmExtension.fromLabel(v);
        if (selected != vibrationTargetArm) {
          vibrationTargetArm = selected;
          _saveSettings();
        }
      },
    );
  }

  Widget _buildTestVibrationButton() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () async {
          _showSuccessSnackBar(S.of(context).vibrationTestInProgress);
          await GoalCheckService().testVibration();
        },
        icon: const Icon(Icons.vibration),
        label: Text(S.of(context).testVibration),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildVibrationTypeDropdown() {
    // Utiliser uniquement les modes disponibles (sans les obsolètes)
    final availableLabels = VibrationModeExtension.availableModes.map((e) => e.label).toList();

    return _buildDropdownTile(
      Icons.vibration,
      S.of(context).vibrationType,
      vibrationMode.label,
      availableLabels,
      (v) {
        final selected = VibrationModeExtension.fromLabel(v);
        if (selected == VibrationMode.custom) {
          // Toujours ouvrir le dialogue pour custom, même si déjà sélectionné
          vibrationMode = selected;
          Future.delayed(const Duration(milliseconds: 200), () {
            _showCustomVibrationDialog();
          });
        } else if (selected != vibrationMode) {
          vibrationMode = selected;
          _saveSettings();
        }
      },
    );
  }

  Widget _buildDropdownTile(
    IconData icon,
    String title,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    final theme = Theme.of(context);
    final isVibrationType = title == 'Type de vibration';
    final isCustomSelected =
        isVibrationType && value == 'Personnalisé';
    final customSubtitle = '$customRepeat vibration${customRepeat > 1 ? 's' : ''}';

    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        isCustomSelected ? customSubtitle : value,
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
      ),
      trailing: Icon(
        Icons.arrow_drop_down,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                // Options
                ...options.map((opt) {
                  final isSelected = opt == value;
                  return ListTile(
                    leading: isSelected
                        ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                        : const SizedBox(width: 24),
                    title: Text(
                      opt,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onChanged(opt);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAffectedSideSelector() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.accessibility_new,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                S.of(context).affectedSide,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButton<ArmSide>(
            value: affectedSide,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: theme.colorScheme.surface,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 15,
            ),
            icon: Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.primary,
            ),
            items: [
              DropdownMenuItem(
                value: ArmSide.left,
                child: Text(
                  S.of(context).left,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
              DropdownMenuItem(
                value: ArmSide.right,
                child: Text(
                  S.of(context).right,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
            ],
            onChanged: (val) {
              affectedSide = val!;
              _saveSettings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLeftWatchTile(WatchDevice leftWatch) {
    return _buildNavTile(
      Icons.watch,
      S.of(context).leftWatch,
      S.of(context).watchStatus(leftWatch.isLastConnected ? S.of(context).connected : S.of(context).disconnected),
      () => Navigator.pushNamed(
        context,
        AppRoutes.watchLeft,
        arguments: leftWatch,
      ),
    );
  }

  Widget _buildRightWatchTile(WatchDevice rightWatch) {
    return _buildNavTile(
      Icons.watch_outlined,
      S.of(context).rightWatch,
      S.of(context).watchStatus(rightWatch.isLastConnected ? S.of(context).connected : S.of(context).disconnected),
      () => Navigator.pushNamed(
        context,
        AppRoutes.watchRight,
        arguments: rightWatch,
      ),
    );
  }

  Widget _buildUpdateWatchesTile() {
    return _buildNavTile(
      Icons.system_update,
      S.of(context).updateWatches,
      S.of(context).installFirmwareOnBothWatches,
      () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => const WatchfaceInstallSheet(
          deviceIds: ['D3:4B:7A:01:02:03', 'F1:2C:8E:AA:BB:CC'],
          firmwareUrl: 'https://tonserveur.com/firmware/dfu_package.zip',
        ),
      ),
    );
  }

  Widget _buildSyncTile() {
    return _buildNavTile(
      Icons.sync_outlined,
      S.of(context).timeSynchronization,
      S.of(context).timezoneFormatSync,
      () => Navigator.pushNamed(context, AppRoutes.timePreferences),
    );
  }

  Widget _buildPrivacyTile() {
    return _buildNavTile(
      Icons.privacy_tip_outlined,
      S.of(context).privacyPolicy,
      '',
      () => Navigator.pushNamed(context, AppRoutes.privacy),
    );
  }

  Widget _buildAboutTile() {
    return _buildNavTile(
      Icons.info_outline,
      S.of(context).about,
      '',
      () => Navigator.pushNamed(context, AppRoutes.about),
    );
  }

  Widget _buildContactTile() {
    return _buildNavTile(
      Icons.email_outlined,
      S.of(context).contactSupport,
      AppConfig.supportEmail,
      () => Navigator.pushNamed(context, AppRoutes.contact),
    );
  }

  Widget _buildMovementSamplingTile() {
    final settingsState = context.watch<SettingsBloc>().state;
    String samplingDescription = 'Normal';
    if (settingsState is SettingsLoaded) {
      samplingDescription = settingsState.settings.movementSampling.presetName;
    }

    return _buildNavTile(
      Icons.speed,
      S.of(context).movementSampling,
      samplingDescription,
      () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MovementSamplingPage()),
      ),
    );
  }

  Widget _buildShareDataTile() {
    return _buildNavTile(
      Icons.share_outlined,
      S.of(context).shareMyData,
      '',
      _shareLocalData,
    );
  }

  Widget _buildImportDataTile() {
    return _buildNavTile(
      Icons.download_outlined,
      S.of(context).importData,
      '',
      _importLocalData,
    );
  }

  Widget _buildExportDataTile() {
    return _buildNavTile(
      Icons.upload_file,
      S.of(context).exportMyData,
      S.of(context).saveToFile,
      _shareLocalData,
    );
  }

  Widget _buildResetConfigTile() {
    return ListTile(
      leading: const Icon(Icons.settings_backup_restore, color: Colors.orange),
      title: Text(
        S.of(context).resetSettings,
        style: const TextStyle(color: Colors.orange),
      ),
      subtitle: Text(S.of(context).resetAllConfigurations),
      onTap: _resetConfig,
    );
  }

  Widget _buildResetDataTile() {
    return ListTile(
      leading: const Icon(Icons.data_saver_off_sharp, color: Colors.red),
      title: Text(
        S.of(context).resetData,
        style: const TextStyle(color: Colors.red),
      ),
      subtitle: Text(S.of(context).deleteAllLocalData),
      onTap: _resetData,
    );
  }

  // ============================================================================
  // LOGIQUE MÉTIER (100% BLOC)
  // ============================================================================

  void _saveSettings() {
    context.read<SettingsBloc>().add(UpdateSettings(AppSettings(
          userName: userName,
          profileImagePath: profileImage?.path,
          collectionFrequency: collectionFrequency,
          dailyObjective: dailyObjective,
          affectedSide: affectedSide,
          vibrationMode: vibrationMode,
          vibrationTargetArm: vibrationTargetArm,
          checkFrequencyMin: checkFrequencyMin,
          notificationStrategy: NotificationStrategy.normal, // Valeur par défaut (non modifiable)
          notificationsEnabled: notificationsEnabled,
          vibrationOnMs: 200, // Valeur par défaut (non modifiable)
          vibrationOffMs: 300, // Valeur par défaut (non modifiable)
          vibrationRepeat: customRepeat,
          leftWatchName: leftWatchName,
          rightWatchName: rightWatchName,
          language: language,
          themeMode: themeMode,
          bluetoothScanTimeout: bluetoothScanTimeout,
          bluetoothConnectionTimeout: bluetoothConnectionTimeout,
          bluetoothMaxRetries: bluetoothMaxRetries,
          dataRecordInterval: dataRecordInterval,
          movementRecordInterval: movementRecordInterval,
          checkRatioFrequencyMin: checkRatioFrequencyMin,
          goalConfig: goalConfig,
          chartPreferences: chartPreferences,
          timePreferences: timePreferences,
        )));
  }

  void _applySettings(AppSettings settings) {
    //   PURE BLOC: Comparaison pour détecter les changements d'image
    final oldImagePath = profileImage?.path;
    final newImagePath = settings.profileImagePath;
    final hasImageChanged = oldImagePath != newImagePath;

    //   PURE BLOC: Nettoyer le cache seulement si l'image a changé
    if (hasImageChanged && profileImage != null) {
      final oldImageProvider = FileImage(profileImage!);
      oldImageProvider.evict();
    }

    userName = settings.userName;
    // OPTIMISÉ: Pas de File.existsSync() bloquant
    // On crée le File et laisse FileImage/Image.file gérer les erreurs
    profileImage = (settings.profileImagePath != null &&
            settings.profileImagePath!.isNotEmpty)
        ? File(settings.profileImagePath!)
        : null;

    //   PURE BLOC: Mettre à jour le timestamp seulement si nécessaire
    if (hasImageChanged) {
      _imageTimestamp = DateTime.now().millisecondsSinceEpoch;
    }

    collectionFrequency = settings.collectionFrequency;
    dailyObjective = settings.dailyObjective;
    checkFrequencyMin = settings.checkFrequencyMin;
    vibrationTargetArm = settings.vibrationTargetArm;
    vibrationMode = settings.vibrationMode;
    customRepeat = settings.vibrationRepeat;
    affectedSide = settings.affectedSide;
    language = settings.language;
    notificationsEnabled = settings.notificationsEnabled;
    themeMode = settings.themeMode;
    bluetoothScanTimeout = settings.bluetoothScanTimeout;
    bluetoothConnectionTimeout = settings.bluetoothConnectionTimeout;
    bluetoothMaxRetries = settings.bluetoothMaxRetries;
    dataRecordInterval = settings.dataRecordInterval;
    movementRecordInterval = settings.movementRecordInterval;

    // Paramètres avancés
    leftWatchName = settings.leftWatchName;
    rightWatchName = settings.rightWatchName;
    checkRatioFrequencyMin = settings.checkRatioFrequencyMin;
    goalConfig = settings.goalConfig;
    chartPreferences = settings.chartPreferences;
    timePreferences = settings.timePreferences;
  }

  // ============================================================================
  // DIALOGS ET BOTTOM SHEETS
  // ============================================================================

  void _showCustomVibrationDialog() {
    final repCtrl = TextEditingController(text: customRepeat.toString());
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildCustomVibrationHeader(),
                const SizedBox(height: 24),
                _buildCustomField(
                    S.of(context).vibrationCount, repCtrl, Icons.repeat),
                const SizedBox(height: 8),
                Text(
                  S.of(context).vibrationCountDescription,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSimpleCustomVibrationActions(ctx, repCtrl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomVibrationHeader() {
    final theme = Theme.of(context);
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.vibration, size: 24, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            S.of(context).customVibration,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleCustomVibrationActions(
    BuildContext ctx,
    TextEditingController repCtrl,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(ctx),
            icon: const Icon(Icons.close),
            label: Text(S.of(context).cancel),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: theme.colorScheme.outline),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Mettre à jour uniquement le nombre de répétitions
              final newRepeat = int.tryParse(repCtrl.text);
              if (newRepeat != null && newRepeat >= 1 && newRepeat <= 10) {
                customRepeat = newRepeat;
                Navigator.pop(ctx);
                _saveSettings();
              } else {
                // Fermer le bottom sheet d'abord, puis afficher l'erreur
                Navigator.pop(ctx);
                _showErrorSnackBar(S.of(context).numberMustBeBetween1And10);
              }
            },
            icon: const Icon(Icons.check),
            label: Text(S.of(context).save),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  void _showNameDialog() {
    final ctrl = TextEditingController(text: userName);
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(S.of(context).editNameTitle),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: S.of(context).fullName,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              //   PURE BLOC: Mise à jour directe puis BLoC
              userName = ctrl.text;
              Navigator.pop(ctx);
              _saveSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(S.of(context).save),
          ),
        ],
      ),
    );
  }

  void _resetData() {
    _showResetDialog(
      title: S.of(context).resetDataQuestion,
      content: S.of(context).allLocalDataWillBeDeleted,
      onConfirm: _performDataReset,
    );
  }

  void _resetConfig() {
    _showResetDialog(
      title: S.of(context).resetConfigurationsQuestion,
      content: S.of(context).allConfigurationsWillBeReset,
      onConfirm: _performConfigReset,
    );
  }

  void _showResetDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    final confirmController = TextEditingController();
    final confirmationCode = _generateRandomCode(5);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isValid = confirmController.text.trim() == confirmationCode;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(content),
                  const SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      text: '${S.of(context).enterCodeToConfirm} ',
                      children: [
                        TextSpan(
                          text: confirmationCode,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: confirmController,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      labelText: S.of(context).enterCodeAbove,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(S.of(context).cancel),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isValid
                      ? () {
                          Navigator.pop(ctx);
                          onConfirm();
                          _showSuccessSnackBar(S.of(context).dataReset);
                        }
                      : null,
                  child: Text(S.of(context).confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _performDataReset() async {
    try {
      await _resetAppData(context);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(S.of(context).resetError(e.toString()));
    }
  }

  void _performConfigReset() {
    final defaultSettings = AppDatabase.defaultSettings;

    //   PURE BLOC: Supprimer l'image de profil et nettoyer le cache
    if (profileImage != null && profileImage!.existsSync()) {
      final oldImageProvider = FileImage(profileImage!);
      oldImageProvider.evict();
      profileImage!
          .delete()
          .catchError((e) => print('Erreur suppression image: $e'));
    }

    //   PURE BLOC: Mise à jour directe puis BLoC
    userName = defaultSettings.userName;
    profileImage = null;
    notificationsEnabled = true;
    language = defaultSettings.language;
    themeMode = defaultSettings.themeMode;
    collectionFrequency = defaultSettings.collectionFrequency;
    dailyObjective = defaultSettings.dailyObjective;
    checkFrequencyMin = defaultSettings.checkFrequencyMin;
    vibrationTargetArm = defaultSettings.vibrationTargetArm;
    vibrationMode = defaultSettings.vibrationMode;
    customRepeat = defaultSettings.vibrationRepeat;
    affectedSide = defaultSettings.affectedSide;
    _imageTimestamp = DateTime.now().millisecondsSinceEpoch;

    _saveSettings();
  }

  String _generateRandomCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(
      length,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  // ============================================================================
  // GESTION DES IMAGES (100% BLOC)
  // ============================================================================

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (picked == null) return;

      //   PURE BLOC: Nettoyer le cache AVANT la mise à jour
      await _clearImageCache();

      if (!mounted) return;

      //   PURE BLOC: Sauvegarder avec nom unique
      final saved = await _saveImagePermanently(File(picked.path));

      if (!mounted) return;

      //   PURE BLOC: Mise à jour UNIQUEMENT via BLoC
      profileImage = saved;
      _imageTimestamp = DateTime.now().millisecondsSinceEpoch;
      _saveSettings();

      _showSuccessSnackBar(S.of(context).profilePhotoUpdated);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(S.of(context).imageSelectionError(e.toString()));
    }
  }

  Future<void> _clearImageCache() async {
    try {
      if (profileImage != null && profileImage!.existsSync()) {
        final oldImageProvider = FileImage(profileImage!);
        await oldImageProvider.evict();
      }
    } catch (e) {
      print('Erreur lors du nettoyage du cache: $e');
    }
  }

  Future<File> _saveImagePermanently(File image) async {
    final directory = await getApplicationDocumentsDirectory();

    //   PURE BLOC: Supprimer l'ancienne image d'abord
    if (profileImage != null && profileImage!.existsSync()) {
      try {
        await profileImage!.delete();
        await Future.delayed(const Duration(milliseconds: 50));
      } catch (e) {
        print('Erreur suppression ancienne image: $e');
      }
    }

    //   PURE BLOC: Nom unique avec timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'profile_$timestamp.jpg';
    final newPath = '${directory.path}/$fileName';

    final newFile = await image.copy(newPath);

    if (!await newFile.exists()) {
      throw Exception('Impossible de sauvegarder l\'image');
    }

    return newFile;
  }

  // ============================================================================
  // GESTION DES DONNÉES
  // ============================================================================

  Future<void> _resetAppData(BuildContext context) async {
    final db = AppDatabase.instance;
    await db.deleteAppDatabase();
    await db.reloadDatabase();

    // Recharge les blocs après la réinitialisation de la base
    if (context.mounted) {
      context.read<WatchBloc>().add(LoadWatchDevices());
      context.read<SettingsBloc>().add(LoadSettings());
    }
  }

  Future<void> _shareLocalData() async {
    try {
      final bloc = context.read<SettingsBloc>();
      final state = bloc.state;

      if (state is! SettingsLoaded) {
        _showErrorSnackBar(S.of(context).settingsNotLoaded);
        return;
      }

      final settingsJson = _convertSettingsToSerializable(state.settings);

      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0',
        'settings': settingsJson,
        'userData': {
          'userName': userName,
          'profileImageExists': profileImage?.existsSync() ?? false,
          'hasCustomVibration':
              vibrationMode.name.toLowerCase().contains('custom'),
        }
      };

      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'parametres_export_$timestamp.json';
      final file = File('${dir.path}/$fileName');

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      await file.writeAsString(jsonString);

      if (!await file.exists()) {
        throw Exception('Le fichier n\'a pas pu être créé');
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('Le fichier exporté est vide');
      }

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Export des paramètres PineTime ($fileName)',
        subject: 'Sauvegarde paramètres PineTime',
      );

      if (!mounted) return;

      _showSuccessSnackBar(S.of(context).dataExportedSuccessfully(fileSize));
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(S.of(context).exportError(e.toString()));
    }
  }

  Map<String, dynamic> _convertSettingsToSerializable(AppSettings settings) {
    return {
      'userName': settings.userName,
      'profileImagePath': settings.profileImagePath,
      'collectionFrequency': settings.collectionFrequency,
      'dailyObjective': settings.dailyObjective,
      'affectedSide': settings.affectedSide.label,
      'vibrationMode': settings.vibrationMode.name,
      'vibrationTargetArm': settings.vibrationTargetArm.name,
      'checkFrequencyMin': settings.checkFrequencyMin,
      'notificationStrategy': settings.notificationStrategy.name,
      'notificationsEnabled': settings.notificationsEnabled,
      'vibrationOnMs': settings.vibrationOnMs,
      'vibrationOffMs': settings.vibrationOffMs,
      'vibrationRepeat': settings.vibrationRepeat,
      'leftWatchName': settings.leftWatchName,
      'rightWatchName': settings.rightWatchName,
      'language': settings.language.name,
      'themeMode': settings.themeMode.name,
      'bluetoothScanTimeout': settings.bluetoothScanTimeout,
      'bluetoothConnectionTimeout': settings.bluetoothConnectionTimeout,
      'bluetoothMaxRetries': settings.bluetoothMaxRetries,
      'dataRecordInterval': settings.dataRecordInterval,
      'movementRecordInterval': settings.movementRecordInterval,
      'checkRatioFrequencyMin': settings.checkRatioFrequencyMin,
      'goalConfig': settings.goalConfig.toJson(),
      'chartPreferences': settings.chartPreferences.toJson(),
      'timePreferences': settings.timePreferences.toJson(),
    };
  }

  Future<void> _importLocalData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result?.files.single.path == null) {
        return;
      }

      final file = File(result!.files.single.path!);

      if (!await file.exists()) {
        if (!mounted) return;
        _showErrorSnackBar(S.of(context).fileNotFound);
        return;
      }

      final jsonStr = await file.readAsString();

      if (jsonStr.isEmpty) {
        if (!mounted) return;
        _showErrorSnackBar(S.of(context).fileIsEmpty);
        return;
      }

      final jsonData = jsonDecode(jsonStr);
      Map<String, dynamic> settingsData;

      if (jsonData.containsKey('settings')) {
        settingsData = Map<String, dynamic>.from(jsonData['settings']);
      } else {
        settingsData = Map<String, dynamic>.from(jsonData);
      }

      final settings = _convertSerializableToSettings(settingsData);

      if (!mounted) return;

      context.read<SettingsBloc>().add(UpdateSettings(settings));

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      context.read<SettingsBloc>().add(LoadSettings());

      _showSuccessSnackBar(S.of(context).settingsImportedSuccessfully);
    } on FormatException catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(S.of(context).invalidFileFormat(e.message));
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(S.of(context).importError(e.toString()));
    }
  }

  // ============================================================================
  // HELPERS POUR ENUM PARSING
  // ============================================================================

  T _parseEnum<T extends Enum>(
      dynamic value, List<T> enumValues, T defaultValue) {
    if (value == null) return defaultValue;

    for (final enumValue in enumValues) {
      if (enumValue.name == value.toString()) {
        return enumValue;
      }
    }
    return defaultValue;
  }

  AppSettings _convertSerializableToSettings(Map<String, dynamic> data) {
    return AppSettings(
      userName: data['userName'] ?? 'Your Name',
      profileImagePath: data['profileImagePath'],
      collectionFrequency: data['collectionFrequency'] ?? 30,
      dailyObjective: data['dailyObjective'] ?? 80,
      affectedSide: data['affectedSide'] is String
          ? ArmSideExtension.fromLabel(data['affectedSide'])
          : ArmSide.left,
      vibrationMode: _parseEnum(
        data['vibrationMode'],
        VibrationMode.values,
        VibrationMode.doubleShort,
      ),
      vibrationTargetArm: _parseEnum(
        data['vibrationTargetArm'],
        VibrationArm.values,
        VibrationArm.both,
      ),
      checkFrequencyMin: data['checkFrequencyMin'] ?? 10,
      notificationStrategy: _parseEnum(
        data['notificationStrategy'],
        NotificationStrategy.values,
        NotificationStrategy.normal,
      ),
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      vibrationOnMs: data['vibrationOnMs'] ?? 200,
      vibrationOffMs: data['vibrationOffMs'] ?? 100,
      vibrationRepeat: data['vibrationRepeat'] ?? 2,
      leftWatchName: data['leftWatchName'] ?? 'PineTime L',
      rightWatchName: data['rightWatchName'] ?? 'PineTime R',
      language: _parseEnum(
        data['language'],
        AppLanguage.values,
        AppLanguage.fr,
      ),
      themeMode: _parseEnum(
        data['themeMode'],
        AppTheme.values,
        AppTheme.lightGold,
      ),
      bluetoothScanTimeout: data['bluetoothScanTimeout'] ?? 15,
      bluetoothConnectionTimeout: data['bluetoothConnectionTimeout'] ?? 30,
      bluetoothMaxRetries: data['bluetoothMaxRetries'] ?? 5,
      dataRecordInterval: data['dataRecordInterval'] ?? 2,
      movementRecordInterval: data['movementRecordInterval'] ?? 30,
      checkRatioFrequencyMin: data['checkRatioFrequencyMin'] ?? 30,
      goalConfig: data['goalConfig'] != null
          ? GoalConfig.fromJson(Map<String, dynamic>.from(data['goalConfig']))
          : const GoalConfig.fixed(ratio: 80),
      chartPreferences: data['chartPreferences'] != null
          ? ChartPreferences.fromJson(Map<String, dynamic>.from(data['chartPreferences']))
          : const ChartPreferences(),
      timePreferences: data['timePreferences'] != null
          ? TimePreferences.fromJson(Map<String, dynamic>.from(data['timePreferences']))
          : const TimePreferences(),
    );
  }

  // ============================================================================
  // UTILITAIRES
  // ============================================================================

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
