import 'package:flutter/material.dart';

class WatchfaceInstallSheet extends StatefulWidget {
  final List<String> deviceIds;
  final String firmwareUrl;

  const WatchfaceInstallSheet({
    super.key,
    required this.deviceIds,
    required this.firmwareUrl,
  });

  @override
  State<WatchfaceInstallSheet> createState() => _WatchfaceInstallSheetState();
}

class _WatchfaceInstallSheetState extends State<WatchfaceInstallSheet> {
  String? messageText;
  Color? messageColor;
  int currentDeviceIndex = 0;
  bool isDownloading = false;
  bool isInstalling = false;
  double progress = 0.0;
  double? speed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHandle(),
            _buildIcon(),
            const SizedBox(height: 24),
            _buildTitle(),
            const SizedBox(height: 8),
            _buildDescription(theme),
            const SizedBox(height: 24),
            _buildMessageCard(),
            _buildProgressSection(),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      ),
      child: Icon(
        Icons.watch_outlined,
        size: 40,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      "Installation de la Watchface",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      "${widget.deviceIds.length} montre(s) connectée(s) vont être mises à jour avec la nouvelle watchface.",
      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessageCard() {
    if (messageText == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: messageColor?.withValues(alpha: 0.1),
        border: Border.all(color: messageColor ?? Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        messageText!,
        style: TextStyle(color: messageColor, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildProgressSection() {
    if (!isInstalling && !isDownloading) {
      return const SizedBox.shrink();
    }

    if (isDownloading) {
      return const Column(
        children: [
          LinearProgressIndicator(
            color: Colors.blueAccent,
            backgroundColor: Colors.blue,
          ),
          SizedBox(height: 12),
          Text(
            "Téléchargement en cours...",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 28),
        ],
      );
    }

    if (isInstalling) {
      return Column(
        children: [
          LinearProgressIndicator(
            value: progress / 100,
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Text(
            "Appareil ${currentDeviceIndex + 1}/${widget.deviceIds.length} - ${progress.toInt()}%",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (speed != null) ...[
            const SizedBox(height: 4),
            Text(
              "Vitesse: ${speed!.toStringAsFixed(1)} KB/s",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.stop, size: 16),
              label: const Text("Annuler", style: TextStyle(fontSize: 14)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Action d'annulation
                setState(() {
                  isInstalling = false;
                  messageText = "Installation annulée par l'utilisateur.";
                  messageColor = Colors.orange;
                });
              },
            ),
          ),
          const SizedBox(height: 28),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButton() {
    if (isInstalling || isDownloading) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.cloud_download_outlined),
        label: Text(
          widget.deviceIds.length == 1
              ? "Installer sur la montre"
              : "Installer sur ${widget.deviceIds.length} montres",
          style: const TextStyle(fontSize: 14),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),
        onPressed: () {
          // Simulation du démarrage de l'installation
          setState(() {
            messageText = "Téléchargement du fichier de mise à jour en cours...";
            messageColor = Colors.blueAccent;
            isDownloading = true;
          });

          // Simulation pour la démo
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                isDownloading = false;
                isInstalling = true;
                messageText = "Installation sur l'appareil 1/${widget.deviceIds.length}...";
                messageColor = Colors.blueAccent;
                progress = 0;
              });
            }
          });
        },
      ),
    );
  }
}