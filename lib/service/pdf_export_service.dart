import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:intl/intl.dart';

class PdfExportService {
  /// Génère un PDF contenant tous les graphiques capturés
  ///
  /// [chartScreenshots] : Map des titres de graphiques et leurs captures d'écran
  /// [userName] : Nom de l'utilisateur pour personnalisation
  /// [dateRange] : Période couverte par les graphiques
  static Future<File> generateChartsPdf({
    required Map<String, Uint8List> chartScreenshots,
    required String userName,
    String? dateRange,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Page de garde
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue, width: 2),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Rapport d\'Analyse de Mouvement',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Application AVC PineTime',
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 40),

              // Informations du rapport
              _buildInfoRow('Patient', userName),
              pw.SizedBox(height: 10),
              _buildInfoRow('Date de génération', dateFormat.format(now)),
              if (dateRange != null) ...[
                pw.SizedBox(height: 10),
                _buildInfoRow('Période analysée', dateRange),
              ],
              pw.SizedBox(height: 10),
              _buildInfoRow('Nombre de graphiques', '${chartScreenshots.length}'),

              pw.SizedBox(height: 40),

              // Introduction
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Text(
                  'Ce rapport présente une analyse détaillée de votre activité physique '
                  'et de l\'asymétrie de mouvement entre vos deux bras. Les graphiques '
                  'ci-après illustrent vos progrès et permettent un suivi précis de '
                  'votre rééducation.',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey800,
                  ),
                  textAlign: pw.TextAlign.justify,
                ),
              ),

              pw.Spacer(),

              // Pied de page
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Généré automatiquement',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                  pw.Text(
                    'Page 1/${chartScreenshots.length + 1}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Pages des graphiques
    int pageNumber = 2;
    for (final entry in chartScreenshots.entries) {
      final chartTitle = entry.key;
      final imageData = entry.value;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // En-tête de page
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue100,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 4,
                        height: 20,
                        color: PdfColors.blue,
                      ),
                      pw.SizedBox(width: 10),
                      pw.Text(
                        chartTitle,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Graphique
                pw.Expanded(
                  child: pw.Center(
                    child: pw.Image(
                      pw.MemoryImage(imageData),
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                ),

                pw.SizedBox(height: 20),

                // Pied de page
                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      dateFormat.format(now),
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      'Page $pageNumber/${chartScreenshots.length + 1}',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
      pageNumber++;
    }

    // Sauvegarder le PDF
    final output = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(now);
    final file = File('${output.path}/rapport_graphiques_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  /// Construit une ligne d'information pour la page de garde
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 150,
          child: pw.Text(
            '$label :',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
        ),
      ],
    );
  }

  /// Partage le PDF via email ou autres apps
  static Future<void> sharePdf(File pdfFile) async {
    await Printing.sharePdf(
      bytes: await pdfFile.readAsBytes(),
      filename: pdfFile.path.split('/').last,
    );
  }

  /// Ouvre une prévisualisation du PDF avant partage
  static Future<void> previewPdf(
    BuildContext context,
    File pdfFile,
    String userName,
  ) async {
    final pdfBytes = await pdfFile.readAsBytes();

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Rapport ${userName.isNotEmpty ? userName : "Graphiques"}',
      format: PdfPageFormat.a4,
    );
  }

  /// Capture un screenshot d'un widget spécifique
  static Future<Uint8List> captureWidget(
    GlobalKey screenshotKey,
    ScreenshotController controller,
  ) async {
    try {
      final image = await controller.captureFromWidget(
        Container(
          color: Colors.white,
          child: screenshotKey.currentWidget ?? Container(),
        ),
        delay: const Duration(milliseconds: 100),
      );
      return image;
    } catch (e) {
      print('Erreur lors de la capture: $e');
      rethrow;
    }
  }
}
