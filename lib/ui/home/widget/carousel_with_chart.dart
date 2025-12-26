import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';
import 'package:flutter_bloc_app_template/service/pdf_export_service.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CarouselWithChart extends StatefulWidget {
  final List<Widget> carouselItems;
  final IconData infoIcon;
  final bool autoPlay;
  final bool enableInfiniteScroll;
  final double viewportFraction;
  final List<GlobalKey>? chartKeys;
  final List<String>? chartTitles;

  const CarouselWithChart({
    super.key,
    required this.carouselItems,
    this.infoIcon = Icons.remove_red_eye,
    this.autoPlay = false,
    this.enableInfiniteScroll = false,
    this.viewportFraction = 1,
    this.chartKeys,
    this.chartTitles,
  });

  @override
  _CarouselWithChartState createState() => _CarouselWithChartState();
}

class _CarouselWithChartState extends State<CarouselWithChart> {
  int activeIndex = 0;
  bool _isExporting = false;

  // Lazy loading: garde trace des graphiques qui ont été chargés
  final Set<int> _loadedIndices = {};

  @override
  void initState() {
    super.initState();
    // Charger le premier graphique immédiatement
    _loadedIndices.add(0);
    // Charger le graphique suivant après un délai pour éviter ANR
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && widget.carouselItems.length > 1) {
        setState(() {
          _loadedIndices.add(1);
        });
      }
    });
  }

  /// Construit un widget avec lazy loading
  Widget _buildLazyItem(int index) {
    // Si le graphique n'a pas encore été chargé, afficher un placeholder
    if (!_loadedIndices.contains(index)) {
      return const SizedBox(
        height: 400,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return widget.carouselItems[index];
  }

  /// Précharge les graphiques adjacents avec un délai pour éviter ANR
  void _preloadAdjacentCharts(int currentIndex) {
    // Charger le graphique courant s'il n'est pas déjà chargé
    if (!_loadedIndices.contains(currentIndex)) {
      setState(() {
        _loadedIndices.add(currentIndex);
      });
    }

    // Précharger le graphique suivant après un court délai
    final nextIndex = currentIndex + 1;
    if (nextIndex < widget.carouselItems.length && !_loadedIndices.contains(nextIndex)) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _loadedIndices.add(nextIndex);
          });
        }
      });
    }

    // Précharger le graphique précédent après un délai plus long
    final prevIndex = currentIndex - 1;
    if (prevIndex >= 0 && !_loadedIndices.contains(prevIndex)) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _loadedIndices.add(prevIndex);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPdfExport = widget.chartKeys != null &&
                         widget.chartKeys!.isNotEmpty &&
                         widget.chartTitles != null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CarouselSlider.builder(
          itemCount: widget.carouselItems.length,
          itemBuilder: (context, index, realIndex) {
            return _buildLazyItem(index);
          },
          options: CarouselOptions(
            height: 400,
            enlargeCenterPage: true,
            enlargeFactor: 0.12,
            enableInfiniteScroll: widget.enableInfiniteScroll,
            animateToClosest: false,
            scrollDirection: Axis.horizontal,
            autoPlay: widget.autoPlay,
            viewportFraction: widget.viewportFraction,
            pageSnapping: true,
            scrollPhysics: const BouncingScrollPhysics(),
            onPageChanged: (index, reason) {
              setState(() {
                activeIndex = index;
              });
              // Lazy loading: charger le graphique courant et le suivant
              _preloadAdjacentCharts(index);
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSmoothIndicator(
              activeIndex: activeIndex,
              count: widget.carouselItems.length + 1,
              effect: ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: theme.colorScheme.primary.withValues(alpha: 0.6),
                dotColor: Colors.grey,
              ),
            ),
            if (hasPdfExport) ...[
              const SizedBox(width: 16),
              _buildPdfButton(theme),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPdfButton(ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isExporting ? null : _exportToPdf,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isExporting)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
              const SizedBox(width: 4),
              Text(
                _isExporting ? '...' : 'PDF',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportToPdf() async {
    if (widget.chartKeys == null || widget.chartTitles == null) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final settingsBloc = context.read<SettingsBloc>();
      String userName = 'Utilisateur';

      if (settingsBloc.state is SettingsLoaded) {
        final settings = (settingsBloc.state as SettingsLoaded).settings;
        userName = settings.userName.isNotEmpty ? settings.userName : 'Utilisateur';
      }

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

      final screenshots = <String, Uint8List>{};

      for (int i = 0; i < widget.chartKeys!.length; i++) {
        final key = widget.chartKeys![i];
        final title = widget.chartTitles![i];

        try {
          final imageData = await _captureChart(key);
          if (imageData != null) {
            screenshots[title] = imageData;
          }
        } catch (e) {
          debugPrint('Erreur capture graphique $title: $e');
        }

        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (screenshots.isEmpty) {
        throw Exception('Aucun graphique n\'a pu être capturé');
      }

      final dateRange = _getDateRange();
      final pdfFile = await PdfExportService.generateChartsPdf(
        chartScreenshots: screenshots,
        userName: userName,
        dateRange: dateRange,
      );

      if (!mounted) return;
      Navigator.of(context).pop();

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF généré avec ${screenshots.length} graphique(s)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

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
        debugPrint('Boundary null pour key: $key');
        return null;
      }

      await Future.delayed(const Duration(milliseconds: 50));

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Erreur capture: $e');
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