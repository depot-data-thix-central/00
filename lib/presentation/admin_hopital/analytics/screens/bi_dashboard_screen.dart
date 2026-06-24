// 📁 lib/presentation/admin_hopital/analytics/screens/bi_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bi_dashboard_widget.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';

class BIDashboardScreen extends ConsumerStatefulWidget {
  const BIDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BIDashboardScreen> createState() => _BIDashboardScreenState();
}

class _BIDashboardScreenState extends ConsumerState<BIDashboardScreen> {
  bool _isLoading = true;

  // Données mockées
  final Map<String, dynamic> _biData = {
    'revenue': 248500,
    'patients': 1247,
    'occupancy': 78,
    'satisfaction': 8.7,
    'services': [
      {'name': 'Cardiologie', 'performance': 92},
      {'name': 'Pédiatrie', 'performance': 85},
      {'name': 'Orthopédie', 'performance': 78},
      {'name': 'Radiologie', 'performance': 88},
      {'name': 'Urgences', 'performance': 70},
    ],
  };

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
        title: const Text('Tableau de bord BI'),
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
                const SnackBar(content: Text('Export du rapport'), backgroundColor: Colors.blue),
              );
            },
            tooltip: 'Exporter',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Chargement des données...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              BIDashboardWidget(data: _biData),
              const SizedBox(height: 16),
              // Widgets supplémentaires pour les détails
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
                      'Vue d\'ensemble',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildDetailCard('Consultations', '1 450', '+8%', Icons.medical_services, Colors.blue),
                        const SizedBox(width: 12),
                        _buildDetailCard('Hospitalisations', '380', '+3%', Icons.bed, Colors.green),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildDetailCard('Durée moyenne', '4.2 jours', '-0.5', Icons.access_time, Colors.orange),
                        const SizedBox(width: 12),
                        _buildDetailCard('Taux de réadmission', '6.8%', '-1.2%', Icons.rotate_left, Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AdminGradientButton(
                text: 'Voir le rapport complet',
                onPressed: () {
                  context.push('/admin/analytics/bi/report');
                },
                icon: Icons.assessment,
                gradient: const LinearGradient(colors: [Colors.teal, Colors.tealAccent]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, String trend, IconData icon, Color color) {
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
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const Spacer(),
                Text(
                  trend,
                  style: TextStyle(
                    fontSize: 11,
                    color: trend.startsWith('+') ? Colors.green : (trend.startsWith('-') ? Colors.red : Colors.grey),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
