// 📁 lib/presentation/admin_hopital/analytics/widgets/bi_dashboard_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_stats_card.dart';

class BIDashboardWidget extends ConsumerWidget {
  final Map<String, dynamic> data;

  const BIDashboardWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              const Icon(Icons.dashboard, size: 20, color: Colors.teal),
              const SizedBox(width: 8),
              const Text(
                'Tableau de bord BI',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Mis à jour: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 10, color: Colors.teal.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // KPIs
          Row(
            children: [
              Expanded(
                child: AdminStatsCard(
                  label: 'Chiffre d\'affaires',
                  value: '${data['revenue'] ?? '0'} €',
                  icon: Icons.euro,
                  color: Colors.green,
                  trend: 12.5,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AdminStatsCard(
                  label: 'Patients uniques',
                  value: '${data['patients'] ?? '0'}',
                  icon: Icons.people,
                  color: Colors.blue,
                  trend: 8.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AdminStatsCard(
                  label: 'Taux d\'occupation',
                  value: '${data['occupancy'] ?? '0'}%',
                  icon: Icons.bed,
                  color: Colors.orange,
                  trend: -2.1,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AdminStatsCard(
                  label: 'Score de satisfaction',
                  value: '${data['satisfaction'] ?? '0'}/10',
                  icon: Icons.star,
                  color: Colors.purple,
                  trend: 4.7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tableau rapide des services
          const Text(
            'Performance des services',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (data['services'] as List? ?? []).length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final service = (data['services'] as List)[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          service['name'],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            widthFactor: service['performance'] / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: service['performance'] >= 70
                                    ? Colors.green
                                    : (service['performance'] >= 50 ? Colors.orange : Colors.red),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${service['performance']}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: service['performance'] >= 70
                              ? Colors.green
                              : (service['performance'] >= 50 ? Colors.orange : Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
