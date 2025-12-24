import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';
import 'package:flutter_bloc_app_template/service/pdf_export_service.dart';
import 'package:intl/intl.dart';

class PdfExportButton extends StatefulWidget {
  final List<GlobalKey> chartKeys;
  final List<String> chartTitles;

  const PdfExportButton({
    super.key,
    required this.chartKeys,
    required this.chartTitles,
  });

  @override
  State<PdfExportButton> createState() => _PdfExportButtonState();
}

class _PdfExportButtonState extends State<PdfExportButton> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton.extended(
      onPressed: _isExporting ? null : _exportToPdf,
      icon: _isExporting
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onPrimary,
                ),
              ),
            )
          : const Icon(Icons.picture_as_pdf),
      label: Text(_isExporting ? 'Export...' : 'Exporter PDF'),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
    );
  }

  Future<void> _exportToPdf() async {
    setState(() {
      _isExporting = true;
    });

    try {
      // Récupérer les informations de l'utilisateur
      final settingsBloc = context.read<SettingsBloc>();
      String userName = 'Utilisateur';
      if (settingsBloc.state is SettingsLoaded) {
        userName = (settingsBloc.state as SettingsLoaded).settings.userName;
      }

      // Afficher dialogue de progression
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Génération du PDF en cours...\nCapture des graphiques',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );

      // Capturer tous les graphiques
      final screenshots = <String, Uint8List>{};

      for (int i = 0; i < widget.chartKeys.length; i++) {
        final key = widget.chartKeys[i];
        final title = widget.chartTitles[i];

        try {
          final imageData = await _captureChart(key);
          if (imageData != null) {
            screenshots[title] = imageData;
          }
        } catch (e) {
          print('Erreur capture graphique $title: $e');
        }

        // Petite pause pour laisser le rendering se faire
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (screenshots.isEmpty) {
        throw Exception('Aucun graphique n\'a pu être capturé');
      }

      // Générer le PDF
      final dateRange = _getDateRange();
      final pdfFile = await PdfExportService.generateChartsPdf(
        chartScreenshots: screenshots,
        userName: userName,
        dateRange: dateRange,
      );

      // Fermer dialogue de progression
      if (!mounted) return;
      Navigator.of(context).pop();

      // Afficher dialogue de choix
      if (!mounted) return;
      final action = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('PDF généré avec succès'),
          content: Text(
            'Le rapport contient ${screenshots.length} graphique(s).\n\n'
            'Que souhaitez-vous faire ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: const Text('Fermer'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'preview'),
              child: const Text('Prévisualiser'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'share'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Partager'),
            ),
          ],
        ),
      );

      if (action == 'preview') {
        if (!mounted) return;
        await PdfExportService.previewPdf(context, pdfFile, userName);
      } else if (action == 'share') {
        await PdfExportService.sharePdf(pdfFile);
      }

      // Afficher succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF généré avec ${screenshots.length} graphique(s)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Fermer dialogue de progression si ouvert
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Afficher erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération du PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<Uint8List?> _captureChart(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        print('Boundary null pour key: $key');
        return null;
      }

      // Attendre que le rendering soit complet
      await Future.delayed(const Duration(milliseconds: 50));

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Erreur capture: $e');
      return null;
    }
  }

  String _getDateRange() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final format = DateFormat('dd/MM/yyyy');
    return '${format.format(startOfWeek)} - ${format.format(endOfWeek)}';
  }
}
