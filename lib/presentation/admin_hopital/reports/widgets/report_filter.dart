// 📁 lib/presentation/admin_hopital/reports/widgets/report_filter.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_dropdown.dart';
import '../../../common/widgets/admin_date_picker.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class ReportFilter extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onApply;
  final Map<String, dynamic>? initialFilters;

  const ReportFilter({
    Key? key,
    required this.onApply,
    this.initialFilters,
  }) : super(key: key);

  @override
  ConsumerState<ReportFilter> createState() => _ReportFilterState();
}

class _ReportFilterState extends ConsumerState<ReportFilter> {
  // Valeurs
  String _period = 'month';
  DateTime? _startDate;
  DateTime? _endDate;
  String _service = 'all';
  String _doctor = 'all';
  String _department = 'all';
  String _patient = 'all';

  final List<String> _periods = ['day', 'week', 'month', 'quarter', 'year', 'custom'];
  final List<String> _services = ['all', 'Cardiologie', 'Pédiatrie', 'Orthopédie', 'Radiologie', 'Urgences'];
  final List<String> _doctors = ['all', 'Dr. Martin', 'Dr. Bernard', 'Dr. Petit', 'Dr. Dubois'];
  final List<String> _departments = ['all', 'Consultations', 'Hospitalisation', 'Urgences', 'Bloc opératoire'];

  @override
  void initState() {
    super.initState();
    if (widget.initialFilters != null) {
      _period = widget.initialFilters!['period'] ?? 'month';
      _startDate = widget.initialFilters!['startDate'];
      _endDate = widget.initialFilters!['endDate'];
      _service = widget.initialFilters!['service'] ?? 'all';
      _doctor = widget.initialFilters!['doctor'] ?? 'all';
      _department = widget.initialFilters!['department'] ?? 'all';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_alt, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              const Text(
                'Filtres',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton(
                onPressed: _resetFilters,
                child: const Text('Réinitialiser', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Période
          AdminDropdown<String>(
            label: 'Période',
            value: _period,
            items: _periods.map((p) {
              return DropdownMenuItem(
                value: p,
                child: Text(_getPeriodLabel(p), style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (v) => setState(() {
              _period = v ?? _period;
              if (_period == 'custom') {
                _startDate = DateTime.now().subtract(const Duration(days: 30));
                _endDate = DateTime.now();
              } else {
                _startDate = null;
                _endDate = null;
              }
            }),
          ),
          const SizedBox(height: 12),
          // Dates personnalisées
          if (_period == 'custom')
            Row(
              children: [
                Expanded(
                  child: AdminDatePicker(
                    label: 'Date de début',
                    selectedDate: _startDate,
                    onDateSelected: (date) => setState(() => _startDate = date),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminDatePicker(
                    label: 'Date de fin',
                    selectedDate: _endDate,
                    onDateSelected: (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          // Filtres
          Row(
            children: [
              Expanded(
                child: AdminDropdown<String>(
                  label: 'Service',
                  value: _service,
                  items: _services.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(s == 'all' ? 'Tous les services' : s, style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _service = v ?? _service),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AdminDropdown<String>(
                  label: 'Médecin',
                  value: _doctor,
                  items: _doctors.map((d) {
                    return DropdownMenuItem(
                      value: d,
                      child: Text(d == 'all' ? 'Tous les médecins' : d, style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _doctor = v ?? _doctor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AdminDropdown<String>(
            label: 'Département',
            value: _department,
            items: _departments.map((d) {
              return DropdownMenuItem(
                value: d,
                child: Text(d == 'all' ? 'Tous les départements' : d, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (v) => setState(() => _department = v ?? _department),
          ),
          const SizedBox(height: 16),
          AdminGradientButton(
            text: 'Appliquer les filtres',
            onPressed: _applyFilters,
            icon: Icons.search,
          ),
        ],
      ),
    );
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'day':
        return 'Aujourd\'hui';
      case 'week':
        return 'Cette semaine';
      case 'month':
        return 'Ce mois';
      case 'quarter':
        return 'Ce trimestre';
      case 'year':
        return 'Cette année';
      case 'custom':
        return 'Personnalisé';
      default:
        return period;
    }
  }

  void _resetFilters() {
    setState(() {
      _period = 'month';
      _startDate = null;
      _endDate = null;
      _service = 'all';
      _doctor = 'all';
      _department = 'all';
    });
    _applyFilters();
  }

  void _applyFilters() {
    final filters = {
      'period': _period,
      'startDate': _startDate,
      'endDate': _endDate,
      'service': _service,
      'doctor': _doctor,
      'department': _department,
    };
    widget.onApply(filters);
  }
}
