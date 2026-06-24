// 📁 lib/presentation/admin_hopital/reports/screens/report_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/report_chart.dart';
import '../widgets/report_filter.dart';
import '../widgets/report_export_button.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_stats_card.dart';
import '../../common/widgets/admin_empty_state.dart';

class ReportDashboardScreen extends ConsumerStatefulWidget {
  const ReportDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportDashboardScreen> createState() => _ReportDashboardScreenState();
}

class _ReportDashboardScreenState extends ConsumerState<ReportDashboardScreen> {
  bool _isLoading = true;
  bool _showFilters = false;
  Map<String, dynamic> _filters = {};

  // Données mockées (à remplacer par les vrais providers)
  final List<double> _consultationData = [120, 145, 138, 162, 150, 175, 190];
  final List<double> _hospitalizationData = [45, 52, 48, 55, 60, 58, 62];
  final List<String> _months = ['Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
  final List<Map<String, dynamic>> _topServices = [
    {'label': 'Cardiologie', 'value': 30},
    {'label': 'Pédiatrie', 'value': 25},
    {'label': 'Orthopédie', 'value': 20},
    {'label': 'Radiologie', 'value': 15},
    {'label': 'Urgences', 'value': 10},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // Simuler le chargement
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _isLoading = false);
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _filters = filters;
      _showFilters = false;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord des rapports'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.close : Icons.filter_alt),
            onPressed: () => setState(() => _showFilters = !_showFilters),
            tooltip: 'Filtres',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Chargement des rapports...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtres
              if (_showFilters)
                ReportFilter(
                  initialFilters: _filters,
                  onApply: _applyFilters,
                ),
              if (_showFilters) const SizedBox(height: 16),

              // KPIs
              Row(
                children: [
                  Expanded(
                    child: AdminStatsCard(
                      label: 'Consultations totales',
                      value: '${_consultationData.reduce((a, b) => a + b)}',
                      icon: Icons.medical_services,
                      color: Colors.blue,
                      trend: 8.5,
                      trendLabel: 'vs mois dernier',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AdminStatsCard(
                      label: 'Hospitalisations',
                      value: '${_hospitalizationData.reduce((a, b) => a + b)}',
                      icon: Icons.bed,
                      color: Colors.green,
                      trend: 5.2,
                      trendLabel: 'vs mois dernier',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AdminStatsCard(
                      label: 'Taux d\'occupation',
                      value: '78%',
                      icon: Icons.percent,
                      color: Colors.orange,
                      trend: -2.1,
                      trendLabel: 'vs mois dernier',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AdminStatsCard(
                      label: 'Délai moyen (jours)',
                      value: '4.2',
                      icon: Icons.access_time,
                      color: Colors.purple,
                      trend: -0.5,
                      trendLabel: 'vs mois dernier',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Graphiques
              ReportChart(
                chartType: ChartType.line,
                spots: List.generate(_consultationData.length, (i) =>
                    FlSpot(i.toDouble(), _consultationData[i].toDouble())),
                labels: _months,
                title: 'Évolution des consultations',
                unit: 'Nb consultations',
                color: Colors.blue,
                minY: 0,
                maxY: 220,
              ),
              const SizedBox(height: 16),

              ReportChart(
                chartType: ChartType.bar,
                spots: List.generate(_hospitalizationData.length, (i) =>
                    FlSpot(i.toDouble(), _hospitalizationData[i].toDouble())),
                labels: _months,
                title: 'Hospitalisations par mois',
                unit: 'Nb hospitalisations',
                color: Colors.green,
                minY: 0,
                maxY: 80,
              ),
              const SizedBox(height: 16),

              // Camembert
              ReportChart(
                chartType: ChartType.pie,
                spots: const [],
                labels: const [],
                title: 'Répartition par service',
                pieSections: ReportChart.createPieSections(_topServices),
                color: Colors.blue,
              ),
              const SizedBox(height: 16),

              // Légende du camembert
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: _topServices.map((service) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getColorForIndex(_topServices.indexOf(service)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service['label']} (${service['value']}%)',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Bouton d'exportation
              Center(
                child: ReportExportButton(
                  onExport: (format) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Export en $format en cours...'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.cyan,
    ];
    return colors[index % colors.length];
  }
}
