// ui/home/widget/chart_controls.dart

import 'package:flutter/material.dart';

/// Widget de sélection de période réutilisable pour les graphiques
class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final List<String> availablePeriods;
  final Function(String) onPeriodChanged;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.availablePeriods,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: availablePeriods.map((period) {
          final isSelected = period == selectedPeriod;
          return GestureDetector(
            onTap: () => onPeriodChanged(period),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                period,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Widget de toggle de mode pour les graphiques (barre/ligne)
class ChartModeToggle extends StatelessWidget {
  final bool isBarMode;
  final VoidCallback onToggle;

  const ChartModeToggle({
    super.key,
    required this.isBarMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isBarMode ? Icons.show_chart : Icons.bar_chart,
        color: Colors.blue,
        size: 20,
      ),
      onPressed: onToggle,
      tooltip: isBarMode ? 'Graphique en ligne' : 'Graphique en barres',
    );
  }
}

/// Widget de toggle de type d'asymétrie (magnitude/axis)
class AsymmetryTypeToggle extends StatelessWidget {
  final bool isMagnitudeMode;
  final VoidCallback onToggle;

  const AsymmetryTypeToggle({
    super.key,
    required this.isMagnitudeMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleItem('Magnitude', isMagnitudeMode, onToggle),
          _buildToggleItem('Axis', !isMagnitudeMode, onToggle),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
