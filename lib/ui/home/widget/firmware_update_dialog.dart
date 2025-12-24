import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';

/// Dialog moderne pour afficher la progression de la mise à jour firmware
class FirmwareUpdateDialog extends StatelessWidget {
  final int percent;
  final String status;
  final VoidCallback? onCancel;
  final bool isCompleted;
  final bool hasError;
  final String? errorMessage;

  const FirmwareUpdateDialog({
    super.key,
    required this.percent,
    required this.status,
    this.onCancel,
    this.isCompleted = false,
    this.hasError = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withValues(alpha: 0.95),
                  ]
                : [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône de statut
            _buildStatusIcon(theme),
            const SizedBox(height: 20),

            // Titre
            Text(
              _getTitle(context),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Contenu conditionnel
            if (hasError)
              _buildErrorContent(context, theme)
            else if (isCompleted)
              _buildSuccessContent(context, theme)
            else
              _buildProgressContent(context, theme),

            const SizedBox(height: 24),

            // Boutons d'action
            _buildActions(context, theme),
          ],
        ),
      ),
    );
  }

  String _getTitle(BuildContext context) {
    if (hasError) return S.of(context).updateFailed;
    if (isCompleted) return S.of(context).updateComplete;
    return S.of(context).updating;
  }

  Widget _buildStatusIcon(ThemeData theme) {
    if (hasError) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.shade50,
        ),
        child: Icon(
          Icons.error_outline,
          size: 50,
          color: Colors.red.shade600,
        ),
      );
    }

    if (isCompleted) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green.shade50,
        ),
        child: Icon(
          Icons.check_circle_outline,
          size: 50,
          color: Colors.green.shade600,
        ),
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: percent / 100,
              strokeWidth: 5,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          Icon(
            Icons.system_update_alt,
            size: 30,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressContent(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // Barre de progression linéaire
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade200,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Pourcentage
        Text(
          '$percent%',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),

        // Status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Avertissement
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orange.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  S.of(context).doNotDisconnectWatch,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            S.of(context).updateInstalledSuccessfully,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.green.shade900,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).watchWillRestart,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            errorMessage ?? S.of(context).updateErrorOccurred,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade900,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).tryAgainOrContact,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme) {
    if (hasError || isCompleted) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onCancel,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: Text(
            S.of(context).close,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              S.of(context).cancel,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
