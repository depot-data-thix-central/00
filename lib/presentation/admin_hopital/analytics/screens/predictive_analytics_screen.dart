// 📁 lib/presentation/admin_hopital/analytics/screens/predictive_analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/predictive_chart.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';

class PredictiveAnalyticsScreen extends ConsumerStatefulWidget {
  const PredictiveAnalyticsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PredictiveAnalyticsScreen> createState() => _PredictiveAnalyticsScreenState();
}

class _PredictiveAnalyticsScreenState extends ConsumerState<PredictiveAnalyticsScreen> {
  bool _isLoading = true;

  // Données mockées
  final List<double> _historicalAdmissions = [45, 52, 48, 60, 55, 62, 58, 70, 65, 72, 68, 75];
  final List<double> _predictedAdmissions = [80, 85, 82, 90, 88, 95];
  final List<String> _months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc', 'Jan25', 'Fév25', 'Mar25', 'Avr25', 'Mai25', 'Juin25'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse prédictive'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Rafraîchir',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export des données'), backgroundColor: Colors.blue),
              );
            },
            tooltip: 'Exporter',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Chargement des prédictions...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Graphique principal
              PredictiveChart(
                historicalData: _historicalAdmissions,
                predictedData: _predictedAdmissions,
                labels: _months,
                title: 'Prévision des admissions',
                unit: 'Nombre de patients',
                color: Colors.blue,
              ),
              const SizedBox(height: 16),

              // Indicateurs de prédiction
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Résumé des prédictions',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildPredictionItem(
                          label: 'Pic attendu',
                          value: '95 patients',
                          detail: 'Juin 2025',
                          color: Colors.red,
                        ),
                        const SizedBox(width: 12),
                        _buildPredictionItem(
                          label: 'Moyenne prévue',
                          value: '85 patients',
                          detail: '+12% vs année précédente',
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildPredictionItem(
                          label: 'Seuil d\'alerte',
                          value: '90 patients',
                          detail: 'Dépassé en Mai 2025',
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        _buildPredictionItem(
                          label: 'Confiance modèle',
                          value: '92%',
                          detail: 'R² = 0.87',
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Actions
              AdminGradientButton(
                text: 'Voir le rapport détaillé',
                onPressed: () {
                  context.push('/admin/analytics/predictive/report');
                },
                icon: Icons.description,
                gradient: const LinearGradient(colors: [Colors.purple, Colors.purpleAccent]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionItem({
    required String label,
    required String value,
    required String detail,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
