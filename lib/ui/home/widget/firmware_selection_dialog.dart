import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/infinitime/dual_infinitime_state.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/ui/home/widget/firmware_update_dialog.dart';
import '../../../bloc/infinitime/dual_infinitime_bloc.dart';

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
                BlocListener<DualInfiniTimeBloc, DualInfiniTimeState>(
                  listener: _handleBlocListener,
                  // Le child est la liste des firmwares
                  child: Expanded(
                    // ÉTAPE 2: Builder pour afficher la liste des firmwares
                    child: BlocBuilder<DualInfiniTimeBloc, DualInfiniTimeState>(
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
    context.read<DualInfiniTimeBloc>().loadAvailableFirmwares();
  }

  /// ================== ÉTAPE 4: LISTENER POUR PROGRESSION ==================
  void _handleBlocListener(BuildContext context, DualInfiniTimeState state) {
    final arm = widget.side == ArmSide.left ? state.left : state.right;

    // EN COURS DE MISE À JOUR (DFU running)
    if (arm.dfuRunning) {
      if (!_isUpdating) {
        setState(() => _isUpdating = true);
      }

      _logFirmwareUpdating(
        side: widget.side.name,
        percent: arm.dfuPercent,
        phase: arm.dfuPhase,
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
  Widget _buildFirmwareListUI(BuildContext context, DualInfiniTimeState state) {
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

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: isSelected ? 4 : 1,
          color: isSelected ? Colors.purple.shade50 : null,
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
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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

    context.read<DualInfiniTimeBloc>().updateSystemFirmware(
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
          child: BlocBuilder<DualInfiniTimeBloc, DualInfiniTimeState>(
            builder: (context, state) {
              final arm = widget.side == ArmSide.left ? state.left : state.right;

              return FirmwareUpdateDialog(
                percent: arm.dfuPercent,
                status: arm.dfuPhase,
                onCancel: () {
                  // Annuler la mise à jour
                  context.read<DualInfiniTimeBloc>().abortSystemFirmwareUpdate(
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
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.purple.shade600 : Colors.grey[400]!,
          width: 2,
        ),
        color: isSelected ? Colors.purple.shade600 : Colors.transparent,
      ),
      child: isSelected
          ? const Icon(Icons.check, color: Colors.white, size: 16)
          : null,
    );
  }

  /// Icône de validation
  Widget _buildValidationIcon(dynamic firmware) {
    return Icon(
      Icons.check_circle,
      color: Colors.green.shade600,
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
            child: Text(S.of(context).cancel),
          ),
        ),
        const SizedBox(width: 16),
        // Bouton Installer
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isButtonEnabled
                ? () {
              // ÉTAPE 3: Lancer la mise à jour
              _startFirmwareUpdate(_selectedFirmware.assetPath);
            }
                : null,
            icon: const Icon(Icons.download),
            label: Text(S.of(context).install),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}