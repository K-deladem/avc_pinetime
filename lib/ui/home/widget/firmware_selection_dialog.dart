import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/device/device.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/ui/home/widget/firmware_update_dialog.dart';

/// Dialog pour sélectionner et installer un firmware
class FirmwareSelectionDialogScreen extends StatefulWidget {
  final ArmSide side;

  const FirmwareSelectionDialogScreen({
    super.key,
    required this.side,
  });

  @override
  State<FirmwareSelectionDialogScreen> createState() =>
      _FirmwareSelectionDialogScreenState();
}

class _FirmwareSelectionDialogScreenState
    extends State<FirmwareSelectionDialogScreen> {
  // Track sélection locale du firmware
  dynamic _selectedFirmware;
  bool _isUpdating = false;
  bool _dialogShown = false;
  int _lastPercent = 0;

  @override
  void initState() {
    super.initState();
    // ÉTAPE 1: Charger la liste des firmwares au démarrage du dialog
    _loadFirmwares();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("Firmware pour ${widget.side.name}"),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ÉTAPE 4: Listener pour suivre progression, erreurs, succès
                BlocListener<DeviceBloc, DeviceState>(
                  listener: _handleBlocListener,
                  // Le child est la liste des firmwares
                  child: Expanded(
                    // ÉTAPE 2: Builder pour afficher la liste des firmwares
                    child: BlocBuilder<DeviceBloc, DeviceState>(
                      builder: _buildFirmwareListUI,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // ÉTAPE 5: Boutons d'action (Annuler/Installer)
                if (!_isUpdating) _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ================== ÉTAPE 1: CHARGER LA LISTE ==================
  void _loadFirmwares() {
    context.read<DeviceBloc>().loadAvailableFirmwares();
  }

  /// ================== ÉTAPE 4: LISTENER POUR PROGRESSION ==================
  void _handleBlocListener(BuildContext context, DeviceState state) {
    final arm = widget.side == ArmSide.left ? state.left : state.right;

    // EN COURS DE MISE À JOUR (DFU running)
    if (arm.dfuRunning) {
      if (!_isUpdating) {
        setState(() => _isUpdating = true);
      }

      _logFirmwareUpdating(
        side: widget.side.name,
        percent: arm.dfuPercent,
        phase: arm.dfuPhase ?? '',
      );

      // Afficher le dialog une seule fois
      if (!_dialogShown && arm.dfuPercent >= 0) {
        _dialogShown = true;
        _showProgressDialog(context);
      }

      // Mettre à jour le pourcentage
      if (arm.dfuPercent != _lastPercent) {
        _lastPercent = arm.dfuPercent;
      }
    }
    // MISE À JOUR TERMINÉE (DFU finished)
    else if (_isUpdating && !arm.dfuRunning) {
      setState(() {
        _isUpdating = false;
        _dialogShown = false;
      });

      if (mounted) {
        // Fermer tous les dialogs ouverts
        Navigator.of(context).popUntil((route) => route.isFirst || !route.willHandlePopInternally);

        // Afficher le dialog de succès
        _showSuccessDialog(context);
      }
    }
  }

  void _logFirmwareUpdating({
    required String side,
    required int percent,
    required String phase,
  }) {
    debugPrint('Mise à jour $side:');
    debugPrint('Progression: $percent%');
    debugPrint('Phase: $phase');
  }

  /// ================== ÉTAPE 2: AFFICHER LA LISTE ==================
  Widget _buildFirmwareListUI(BuildContext context, DeviceState state) {
    final availableFirmwares = state.availableFirmwares;

    // Chargement
    if (state.loadingFirmwares && availableFirmwares.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Chargement des firmwares..."),
          ],
        ),
      );
    }

    // Liste vide
    if (availableFirmwares.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text("Aucun firmware disponible"),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadFirmwares,
              icon: const Icon(Icons.refresh_outlined),
              label: Text(S.of(context).reload),
            ),
          ],
        ),
      );
    }

    // Liste chargée
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: availableFirmwares.length,
      itemBuilder: (context, index) {
        final firmware = availableFirmwares[index];
        final isSelected =
            _selectedFirmware != null &&
                _selectedFirmware.fileName == firmware.fileName;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                : null,
          ),
          child: ListTile(
            leading: _buildSelectionIndicator(isSelected),
            title: Text(
              firmware.fileName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Taille: ${_formatFileSize(firmware.sizeBytes)}',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            trailing: _buildValidationIcon(firmware),
            onTap: () {
              setState(() {
                _selectedFirmware = firmware;
              });
            },
          ),
        );
      },
    );
  }

  /// ================== ÉTAPE 3: LANCER LA MISE À JOUR ==================
  void _startFirmwareUpdate(String firmwarePath) {
    debugPrint('Démarrage mise à jour: $firmwarePath');

    context.read<DeviceBloc>().updateSystemFirmware(
      widget.side,
      firmwarePath,
    );

    setState(() => _isUpdating = true);
  }

  /// ================== ÉTAPE 5: AFFICHER BARRE DE PROGRESSION ==================
  void _showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false, // Empêcher fermeture avec back
          child: BlocBuilder<DeviceBloc, DeviceState>(
            builder: (context, state) {
              final arm = widget.side == ArmSide.left ? state.left : state.right;

              return FirmwareUpdateDialog(
                percent: arm.dfuPercent,
                status: arm.dfuPhase ?? '',
                onCancel: () {
                  // Annuler la mise à jour
                  context.read<DeviceBloc>().abortSystemFirmwareUpdate(
                    widget.side,
                  );
                  setState(() {
                    _isUpdating = false;
                    _dialogShown = false;
                  });
                  Navigator.of(dialogContext).pop();
                },
              );
            },
          ),
        );
      },
    );
  }

  /// Afficher le dialog de succès
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return FirmwareUpdateDialog(
          percent: 100,
          status: 'Mise à jour terminée',
          isCompleted: true,
          onCancel: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pop(); // Fermer aussi le dialog de sélection
          },
        );
      },
    );
  }

  /// ================== WIDGETS UTILITAIRES ==================

  /// Indicateur de sélection (radio button)
  Widget _buildSelectionIndicator(bool isSelected) {
    final theme = Theme.of(context);
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
          width: 2,
        ),
        color: isSelected ? theme.colorScheme.primary : Colors.transparent,
      ),
      child: isSelected
          ? Icon(Icons.check, color: theme.colorScheme.onPrimary, size: 16)
          : null,
    );
  }

  /// Icône de validation
  Widget _buildValidationIcon(dynamic firmware) {
    return Icon(
      Icons.check_circle,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  /// Formate la taille du fichier
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// ================== ÉTAPE 5: BOUTONS D'ACTION ==================
  Widget _buildActionButtons() {
    final isButtonEnabled = _selectedFirmware != null;

    return Row(
      children: [
        // Bouton Annuler
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(S.of(context).cancel),
          ),
        ),
        const SizedBox(width: 16),
        // Bouton Installer
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isButtonEnabled
                ? () => _showConfirmationDialog()
                : null,
            icon: const Icon(Icons.download),
            label: Text(S.of(context).install),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  /// Affiche le dialogue de confirmation avant la mise à jour
  void _showConfirmationDialog() {
    final theme = Theme.of(context);
    final firmware = _selectedFirmware;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: theme.colorScheme.error,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Confirmer la mise à jour'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.memory,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firmware.fileName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Taille: ${_formatFileSize(firmware.sizeBytes)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Attention :',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            _buildWarningItem(
              theme,
              Icons.battery_alert,
              'Assurez-vous que la montre a suffisamment de batterie (> 30%)',
            ),
            const SizedBox(height: 8),
            _buildWarningItem(
              theme,
              Icons.bluetooth_disabled,
              'Ne déconnectez pas la montre pendant la mise à jour',
            ),
            const SizedBox(height: 8),
            _buildWarningItem(
              theme,
              Icons.timer,
              'La mise à jour peut prendre plusieurs minutes',
            ),
            const SizedBox(height: 8),
            _buildWarningItem(
              theme,
              Icons.restart_alt,
              'La montre redémarrera automatiquement à la fin',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _startFirmwareUpdate(firmware.assetPath);
            },
            icon: const Icon(Icons.system_update),
            label: const Text('Démarrer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(ThemeData theme, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}