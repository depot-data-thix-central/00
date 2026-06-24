// 📁 lib/presentation/admin_hopital/analytics/screens/fraud_detection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/fraud_detection_list.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_stats_card.dart';

class FraudDetectionScreen extends ConsumerStatefulWidget {
  const FraudDetectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FraudDetectionScreen> createState() => _FraudDetectionScreenState();
}

class _FraudDetectionScreenState extends ConsumerState<FraudDetectionScreen> {
  bool _isLoading = true;

  // Données mockées
  final List<Map<String, dynamic>> _fraudCases = [
    {
      'id': '1',
      'description': 'Doublon de prescription pour le patient Michel Dupont',
      'patient': 'Michel Dupont',
      'score': 0.92,
      'risk': 'high',
      'status': 'pending',
      'date': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': '2',
      'description': 'Facturation excessive pour des examens non réalisés (Sophie Martin)',
      'patient': 'Sophie Martin',
      'score': 0.85,
      'risk': 'medium',
      'status': 'pending',
      'date': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': '3',
      'description': 'Anomalie de quantité : 5 boîtes prescrites pour 3 jours',
      'patient': 'Lucas Bernard',
      'score': 0.73,
      'risk': 'medium',
      'status': 'confirmed',
      'date': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'id': '4',
      'description': 'Prescription par un médecin non habilité (Julie Petit)',
      'patient': 'Julie Petit',
      'score': 0.45,
      'risk': 'low',
      'status': 'dismissed',
      'date': DateTime.now().subtract(const Duration(days: 5)),
    },
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

  @override
  Widget build(BuildContext context) {
    final pendingCount = _fraudCases.where((c) => c['status'] == 'pending').length;
    final confirmedCount = _fraudCases.where((c) => c['status'] == 'confirmed').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détection de fraudes'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Chargement des cas...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Statistiques
              Row(
                children: [
                  Expanded(
                    child: AdminStatsCard(
                      label: 'Cas en attente',
                      value: '$pendingCount',
                      icon: Icons.pending,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AdminStatsCard(
                      label: 'Cas confirmés',
                      value: '$confirmedCount',
                      icon: Icons.check_circle,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Liste des cas
              FraudDetectionList(
                fraudCases: _fraudCases,
                onCaseTap: (id) {
                  context.push('/admin/analytics/fraud/$id');
                },
              ),
              const SizedBox(height: 16),
              AdminGradientButton(
                text: 'Voir le rapport complet',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rapport de fraude'), backgroundColor: Colors.blue),
                  );
                },
                icon: Icons.assessment,
                gradient: const LinearGradient(colors: [Colors.red, Colors.redAccent]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
