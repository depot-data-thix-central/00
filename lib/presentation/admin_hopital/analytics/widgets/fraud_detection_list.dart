// 📁 lib/presentation/admin_hopital/analytics/widgets/fraud_detection_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_gradient_button.dart';
import '../../../common/widgets/admin_status_badge.dart';

class FraudDetectionList extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> fraudCases;
  final Function(String)? onCaseTap;

  const FraudDetectionList({
    Key? key,
    required this.fraudCases,
    this.onCaseTap,
  }) : super(key: key);

  @override
  ConsumerState<FraudDetectionList> createState() => _FraudDetectionListState();
}

class _FraudDetectionListState extends ConsumerState<FraudDetectionList> {
  String _filterStatus = 'all';
  bool _isExpanded = false;

  List<Map<String, dynamic>> get _filteredCases {
    if (_filterStatus == 'all') return widget.fraudCases;
    return widget.fraudCases.where((c) => c['status'] == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCases;

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
              const Icon(Icons.security, size: 20, color: Colors.red),
              const SizedBox(width: 8),
              const Text(
                'Détection de fraudes',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButton<String>(
                  value: _filterStatus,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tous', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'pending', child: Text('À vérifier', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'confirmed', child: Text('Confirmé', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'dismissed', child: Text('Rejeté', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (v) => setState(() => _filterStatus = v ?? 'all'),
                  underline: const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aucune fraude détectée',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final case_ = filtered[index];
                final riskColor = _getRiskColor(case_['risk']);
                final statusType = case_['status'] == 'confirmed'
                    ? StatusType.cancelled
                    : (case_['status'] == 'pending' ? StatusType.warning : StatusType.completed);
                return InkWell(
                  onTap: () {
                    if (widget.onCaseTap != null) {
                      widget.onCaseTap!(case_['id']);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: riskColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: riskColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.warning_amber,
                            size: 18,
                            color: riskColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                case_['description'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Patient: ${case_['patient']} • Score: ${case_['score']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AdminStatusBadge(
                          status: statusType,
                          customLabel: case_['status'] == 'confirmed'
                              ? 'Confirmé'
                              : (case_['status'] == 'pending' ? 'À vérifier' : 'Rejeté'),
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

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}
