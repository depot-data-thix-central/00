// 📁 lib/presentation/admin_hopital/operations/screens/transport_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/patient_transport_scheduler.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_status_badge.dart';

class TransportScreen extends ConsumerStatefulWidget {
  const TransportScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends ConsumerState<TransportScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all';
  bool _isLoading = false;

  // Données mockées
  final List<Map<String, dynamic>> _transports = [
    {'id': '1', 'patient': 'Michel Dupont', 'from': 'Cardiologie', 'to': 'Radiologie', 'transportType': 'Brancard', 'priority': 'normal', 'scheduleDate': DateTime.now(), 'scheduleTime': DateTime.now().add(const Duration(hours: 1)), 'status': 'planned'},
    {'id': '2', 'patient': 'Sophie Martin', 'from': 'Orthopédie', 'to': 'Bloc opératoire', 'transportType': 'Brancard', 'priority': 'urgent', 'scheduleDate': DateTime.now().add(const Duration(days: 1)), 'scheduleTime': DateTime.now().add(const Duration(hours: 3)), 'status': 'planned'},
    {'id': '3', 'patient': 'Lucas Bernard', 'from': 'Urgences', 'to': 'Réanimation', 'transportType': 'Ambulance', 'priority': 'critical', 'scheduleDate': DateTime.now().add(const Duration(days: -1)), 'scheduleTime': DateTime.now().add(const Duration(hours: -2)), 'status': 'completed'},
  ];

  List<Map<String, dynamic>> get _filteredTransports {
    var filtered = _transports;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((t) =>
        t['patient'].toLowerCase().contains(query) ||
        t['from'].toLowerCase().contains(query) ||
        t['to'].toLowerCase().contains(query)
      ).toList();
    }
    if (_filterStatus != 'all') {
      filtered = filtered.where((t) => t['status'] == _filterStatus).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTransports;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport des patients'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTransportDialog(),
            tooltip: 'Planifier un transport',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Chargement...',
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: AdminSearchBar(
                      onSearch: (query) => setState(() => _searchQuery = query),
                      hintText: 'Rechercher un transport (patient, départ, arrivée)...',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButton<String>(
                      value: _filterStatus,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Tous', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'planned', child: Text('Planifiés', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'in_progress', child: Text('En cours', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'completed', child: Text('Terminés', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'cancelled', child: Text('Annulés', style: TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) => setState(() => _filterStatus = v ?? 'all'),
                      underline: const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const AdminEmptyState(
                      title: 'Aucun transport planifié',
                      subtitle: 'Planifiez les transports des patients',
                      icon: Icons.directions_car_outlined,
                      actionText: 'Planifier un transport',
                      onAction: null,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final t = filtered[index];
                        final priorityColor = t['priority'] == 'critical' ? Colors.red : (t['priority'] == 'urgent' ? Colors.orange : Colors.blue);
                        final statusType = t['status'] == 'completed' ? StatusType.completed : (t['status'] == 'planned' ? StatusType.pending : StatusType.warning);
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: priorityColor.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: priorityColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.directions_car, size: 22, color: priorityColor),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t['patient'],
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${t['from']} → ${t['to']} • ${t['transportType']}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${t['scheduleDate'] != null ? '${(t['scheduleDate'] as DateTime).day}/${(t['scheduleDate'] as DateTime).month}/${(t['scheduleDate'] as DateTime).year}' : ''} ${t['scheduleTime'] != null ? '${(t['scheduleTime'] as DateTime).hour}h${(t['scheduleTime'] as DateTime).minute.toString().padLeft(2, '0')}' : ''}',
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                              AdminStatusBadge(
                                status: statusType,
                                customLabel: t['status'] == 'completed' ? 'Terminé' : (t['status'] == 'planned' ? 'Planifié' : 'En cours'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: 500,
          child: PatientTransportScheduler(
            onSchedule: (data) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transport planifié'), backgroundColor: Colors.green),
              );
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
