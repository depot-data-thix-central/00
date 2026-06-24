// 📁 lib/presentation/admin_hopital/advanced_finance/widgets/budget_tracker.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BudgetTracker extends ConsumerStatefulWidget {
  final Map<String, dynamic> budgetData;
  final Function(String) onDepartmentTap;

  const BudgetTracker({
    Key? key,
    required this.budgetData,
    required this.onDepartmentTap,
  }) : super(key: key);

  @override
  ConsumerState<BudgetTracker> createState() => _BudgetTrackerState();
}

class _BudgetTrackerState extends ConsumerState<BudgetTracker> {
  String _period = 'month';
  bool _showDetails = false;

  final List<String> _periods = ['month', 'quarter', 'year'];

  @override
  Widget build(BuildContext context) {
    final totalBudget = widget.budgetData['totalBudget'] ?? 0.0;
    final totalSpent = widget.budgetData['totalSpent'] ?? 0.0;
    final remaining = totalBudget - totalSpent;
    final departments = widget.budgetData['departments'] ?? [];

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
              const Icon(Icons.pie_chart, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Suivi budgétaire',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButton<String>(
                  value: _period,
                  items: _periods.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text(p == 'month' ? 'Mois' : (p == 'quarter' ? 'Trimestre' : 'Année'), style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _period = v ?? _period),
                  underline: const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Résumé
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildSummaryItem('Budget total', NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(totalBudget), Colors.blue),
                const VerticalDivider(),
                _buildSummaryItem('Dépensé', NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(totalSpent), Colors.red),
                const VerticalDivider(),
                _buildSummaryItem('Restant', NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(remaining), remaining >= 0 ? Colors.green : Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Barre de progression globale
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: totalBudget > 0 ? (totalSpent / totalBudget) : 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (totalSpent / totalBudget) > 0.9 ? Colors.red : Colors.blue,
                      (totalSpent / totalBudget) > 0.9 ? Colors.redAccent : Colors.blueAccent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${totalBudget > 0 ? ((totalSpent / totalBudget) * 100).toStringAsFixed(1) : 0}% utilisé',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          // Détails par service
          Row(
            children: [
              const Text(
                'Détail par service',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _showDetails = !_showDetails),
                child: Text(
                  _showDetails ? 'Masquer' : 'Voir tout',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (departments.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Aucun service enregistré',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _showDetails ? departments.length : departments.length.clamp(0, 3),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final dept = departments[index];
                final budget = dept['budget'] ?? 0.0;
                final spent = dept['spent'] ?? 0.0;
                final percentage = budget > 0 ? (spent / budget) : 0;
                final color = percentage > 0.9 ? Colors.red : (percentage > 0.7 ? Colors.orange : Colors.blue);

                return InkWell(
                  onTap: () => widget.onDepartmentTap(dept['name']),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                dept['name'],
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              '${(percentage * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: FractionallySizedBox(
                                  widthFactor: percentage.clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(spent)} / ${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(budget)}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
