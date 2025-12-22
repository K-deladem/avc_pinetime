import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchFiltreScreen extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?) onFilterChanged;

  const SearchFiltreScreen({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onFilterChanged,
  });

  String _getLabel() {
    if (startDate == null) return '';
    if (endDate == null) {
      return DateFormat('dd/MM/yyyy').format(startDate!);
    } else {
      return "${DateFormat('dd/MM/yyyy').format(startDate!)} → ${DateFormat('dd/MM/yyyy').format(endDate!)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () => _showDateFilterDialog(context),
        child: AbsorbPointer(
          child: TextField(
            controller: TextEditingController(text: _getLabel()),
            readOnly: true,
            decoration: InputDecoration(
              labelText: "Filtrer par date ou période",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () { },)  ,//const Icon(Icons.date_range_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  void _showDateFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text("Choisir une date unique"),
              onTap: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                  locale: const Locale('fr', 'FR'),
                );
                if (selected != null) {
                  Navigator.pop(ctx);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onFilterChanged(selected, null);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text("Choisir une période"),
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                  locale: const Locale('fr', 'FR'),
                );
                if (picked != null) {
                  Navigator.pop(ctx);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onFilterChanged(picked.start, picked.end);
                  });
                }
              },
            ),
            if (startDate != null)
              TextButton.icon(
                onPressed: () {
                  onFilterChanged(null, null);
                  Navigator.pop(ctx);
                },
                icon: const Icon(Icons.clear),
                label: const Text("Réinitialiser le filtre"),
              ),
          ],
        ),
      ),
    );
  }
}