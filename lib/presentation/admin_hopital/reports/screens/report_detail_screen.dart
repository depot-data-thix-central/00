// 📁 lib/presentation/admin_hopital/reports/screens/report_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/report_chart.dart';
import '../widgets/report_export_button.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_data_table.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_status_badge.dart';

class ReportDetailScreen extends ConsumerStatefulWidget {
  final String reportType; // 'consultations', 'hospitalizations', 'patients', 'billing'

  const ReportDetailScreen({
    Key? key,
    required this.reportType,
  }) : super(key: key);

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  bool _isLoading = true;
  bool _showTable = false;

  // Données mockées (à remplacer par les vrais providers)
  final List<Map<String, dynamic>> _tableData = [
    {'Service': 'Cardiologie', 'Consultations': 45, 'Patients': 32, 'Taux': 89},
    {'Service': 'Pédiatrie', 'Consultations': 38, 'Patients': 28, 'Taux': 75},
    {'Service': 'Orthopédie', 'Consultations': 30, 'Patients': 22, 'Taux': 68},
    {'Service': 'Radiologie', 'Consultations': 25, 'Patients': 18, 'Taux': 60},
    {'Service': 'Urgences', 'Consultations': 52, 'Patients': 40, 'Taux': 92},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _isLoading = false);
  }

  String get _title {
    switch (widget.reportType) {
      case 'consultations':
        return 'Rapport des consultations';
      case 'hospitalizations':
        return 'Rapport des hospitalisations';
      case 'patients':
        return 'Rapport des patients';
      case 'billing':
        return 'Rapport de facturation';
      default:
        return 'Rapport détaillé';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_showTable ? Icons.bar_chart : Icons.table_chart),
            onPressed: () => setState(() => _showTable = !_showTable),
            tooltip: _showTable ? 'Vue graphique' : 'Vue tableau',
          ),
          if (_showTable)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export des données en cours...'), backgroundColor: Colors.blue),
                );
              },
              tooltip: 'Exporter les données',
            ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Chargement du rapport...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Résumé
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rapport généré le ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} à ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 13, color: Colors.blue.shade700),
                      ),
                    ),
                    ReportExportButton.simpleButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Export en cours...'), backgroundColor: Colors.blue),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Vue graphique ou tableau
              if (!_showTable)
                _buildChartView()
              else
                _buildTableView(),

              const SizedBox(height: 16),

              // Indicateurs de performance
              const Text(
                'Indicateurs clés',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildIndicatorItem(
                      'Total',
                      '${_tableData.fold(0, (sum, row) => sum + row['Consultations'])}',
                      Icons.people,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildIndicatorItem(
                      'Moyenne',
                      '${(_tableData.fold(0.0, (sum, row) => sum + (row['Taux'] ?? 0)) / _tableData.length).toStringAsFixed(0)}%',
                      Icons.percent,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartView() {
    // Données pour le graphique
    final services = _tableData.map((row) => row['Service'] as String).toList();
    final consultations = _tableData.map((row) => (row['Consultations'] as int).toDouble()).toList();
    final patients = _tableData.map((row) => (row['Patients'] as int).toDouble()).toList();

    return Column(
      children: [
        ReportChart(
          chartType: ChartType.bar,
          spots: List.generate(consultations.length, (i) =>
              FlSpot(i.toDouble(), consultations[i])),
          labels: services,
          title: 'Consultations par service',
          unit: 'Nb consultations',
          color: Colors.blue,
          minY: 0,
          maxY: 60,
        ),
        const SizedBox(height: 16),
        ReportChart(
          chartType: ChartType.bar,
          spots: List.generate(patients.length, (i) =>
              FlSpot(i.toDouble(), patients[i])),
          labels: services,
          title: 'Patients par service',
          unit: 'Nb patients',
          color: Colors.green,
          minY: 0,
          maxY: 50,
        ),
      ],
    );
  }

  Widget _buildTableView() {
    return AdminDataTable(
      columns: const [
        DataColumn(label: Text('Service')),
        DataColumn(label: Text('Consultations')),
        DataColumn(label: Text('Patients')),
        DataColumn(label: Text('Taux (%)')),
        DataColumn(label: Text('Tendance')),
      ],
      rows: _tableData.map((row) {
        final taux = row['Taux'] as int;
        return {
          'Service': row['Service'],
          'Consultations': row['Consultations'].toString(),
          'Patients': row['Patients'].toString(),
          'Taux (%)': '$taux%',
          'Tendance': taux > 70 ? '✅' : (taux > 50 ? '📈' : '⚠️'),
        };
      }).toList(),
      onRowTap: null,
      selectable: false,
      isLoading: _isLoading,
      rowsPerPage: 10,
    );
  }

  Widget _buildIndicatorItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
