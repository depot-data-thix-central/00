// 📁 lib/presentation/admin_hopital/analytics/screens/epidemic_risk_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/epidemic_risk_map.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';

class EpidemicRiskScreen extends ConsumerStatefulWidget {
  const EpidemicRiskScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EpidemicRiskScreen> createState() => _EpidemicRiskScreenState();
}

class _EpidemicRiskScreenState extends ConsumerState<EpidemicRiskScreen> {
  bool _isLoading = true;

  // Données mockées
  final List<Map<String, dynamic>> _regions = [
    {'name': 'Paris', 'x': 180, 'y': 70, 'risk': 'high', 'cases': 45},
    {'name': 'Marseille', 'x': 350, 'y': 120, 'risk': 'medium', 'cases': 28},
    {'name': 'Lyon', 'x': 280, 'y': 90, 'risk': 'high', 'cases': 52},
    {'name': 'Toulouse', 'x': 320, 'y': 160, 'risk': 'low', 'cases': 12},
    {'name': 'Nice', 'x': 400, 'y': 100, 'risk': 'low', 'cases': 8},
    {'name': 'Bordeaux', 'x': 240, 'y': 170, 'risk': 'medium', 'cases': 34},
    {'name': 'Nantes', 'x': 200, 'y': 140, 'risk': 'low', 'cases': 15},
    {'name': 'Lille', 'x': 140, 'y': 50, 'risk': 'high', 'cases': 63},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final totalCases = _regions.fold(0, (sum, r) => sum + (r['cases'] as int));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Risques épidémiques'),
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
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alertes épidémiques'), backgroundColor: Colors.orange),
              );
            },
            tooltip: 'Alertes',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Chargement des risques épidémiques...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Résumé
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$totalCases cas signalés',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          Text(
                            'Dernière mise à jour: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AdminGradientButton(
                      text: 'Activer alertes',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Alertes activées'), backgroundColor: Colors.green),
                        );
                      },
                      height: 34,
                      width: 120,
                      gradient: const LinearGradient(colors: [Colors.orange, Colors.orangeAccent]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Carte des risques
              EpidemicRiskMap(
                regions: _regions,
                lastUpdated: DateTime.now(),
              ),
              const SizedBox(height: 16),
              // Recommandations
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
                      'Recommandations',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    _buildRecommendation(
                      '🟢 Port du masque recommandé pour les zones à risque élevé',
                      Colors.red.shade100,
                    ),
                    const SizedBox(height: 6),
                    _buildRecommendation(
                      '🟡 Renforcer la surveillance des cas contacts',
                      Colors.orange.shade100,
                    ),
                    const SizedBox(height: 6),
                    _buildRecommendation(
                      '🔵 Augmenter les capacités de dépistage dans les zones rouges',
                      Colors.blue.shade100,
                    ),
                    const SizedBox(height: 6),
                    _buildRecommendation(
                      '🔴 Préparer les services d\'urgence à un afflux de patients',
                      Colors.red.shade100,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AdminGradientButton(
                text: 'Voir le rapport épidémiologique',
                onPressed: () {
                  context.push('/admin/analytics/epidemic/report');
                },
                icon: Icons.analytics,
                gradient: const LinearGradient(colors: [Colors.deepOrange, Colors.deepOrangeAccent]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendation(String text, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
