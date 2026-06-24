// 📁 lib/presentation/admin_hopital/operations/screens/equipment_maintenance_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/equipment_maintenance_card.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_confirm_dialog.dart';

class EquipmentMaintenanceScreen extends ConsumerStatefulWidget {
  const EquipmentMaintenanceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EquipmentMaintenanceScreen> createState() => _EquipmentMaintenanceScreenState();
}

class _EquipmentMaintenanceScreenState extends ConsumerState<EquipmentMaintenanceScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all';
  bool _isLoading = false;

  // Données mockées (à remplacer par le provider)
  final List<Map<String, dynamic>> _equipment = [
    {'name': 'IRM 3T', 'serial': 'IRM-2024-001', 'location': 'Radiologie', 'lastMaintenance': DateTime(2024, 10, 15), 'nextMaintenance': DateTime(2024, 12, 15), 'status': 'operational'},
    {'name': 'Scanner CT', 'serial': 'CT-2024-002', 'location': 'Radiologie', 'lastMaintenance': DateTime(2024, 9, 20), 'nextMaintenance': DateTime(2024, 11, 20), 'status': 'scheduled'},
    {'name': 'Échographe', 'serial': 'ECHO-2024-003', 'location': 'Cardiologie', 'lastMaintenance': DateTime(2024, 8, 5), 'nextMaintenance': DateTime(2024, 11, 5), 'status': 'overdue'},
    {'name': 'Ventilateur', 'serial': 'VENT-2024-004', 'location': 'Réanimation', 'lastMaintenance': DateTime(2024, 11, 1), 'nextMaintenance': DateTime(2025, 2, 1), 'status': 'operational'},
  ];

  List<Map<String, dynamic>> get _filteredEquipment {
    var filtered = _equipment;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((e) =>
        e['name'].toLowerCase().contains(query) ||
        e['serial'].toLowerCase().contains(query) ||
        e['location'].toLowerCase().contains(query)
      ).toList();
    }
    if (_filterStatus != 'all') {
      filtered = filtered.where((e) => e['status'] == _filterStatus).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEquipment;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance des équipements'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEquipmentDialog(),
            tooltip: 'Ajouter un équipement',
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
                      hintText: 'Rechercher un équipement...',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButton<String>(
                      value: _filterStatus,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Tous', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'operational', child: Text('Opérationnel', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'scheduled', child: Text('Programmé', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'in_progress', child: Text('En cours', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'overdue', child: Text('En retard', style: TextStyle(fontSize: 13))),
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
                      title: 'Aucun équipement',
                      subtitle: 'Ajoutez un équipement à suivre',
                      icon: Icons.medical_services_outlined,
                      actionText: 'Ajouter un équipement',
                      onAction: null,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final e = filtered[index];
                        final statusMap = {
                          'operational': MaintenanceStatus.operational,
                          'scheduled': MaintenanceStatus.scheduled,
                          'in_progress': MaintenanceStatus.in_progress,
                          'overdue': MaintenanceStatus.overdue,
                        };
                        return EquipmentMaintenanceCard(
                          equipmentName: e['name'],
                          serialNumber: e['serial'],
                          location: e['location'],
                          lastMaintenance: e['lastMaintenance'],
                          nextMaintenance: e['nextMaintenance'],
                          status: statusMap[e['status']] ?? MaintenanceStatus.operational,
                          onSchedule: () => _showScheduleDialog(e),
                          onViewHistory: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Historique des maintenances'), backgroundColor: Colors.blue),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEquipmentDialog() {
    final nameCtrl = TextEditingController();
    final serialCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ajouter un équipement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nom *'), style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            TextField(controller: serialCtrl, decoration: const InputDecoration(labelText: 'N° série *'), style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Emplacement *'), style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Équipement ajouté'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog(Map<String, dynamic> equipment) {
    final dateCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Planifier maintenance - ${equipment['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Date de maintenance'),
              subtitle: Text('Sélectionner une date'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  dateCtrl.text = '${picked.day}/${picked.month}/${picked.year}';
                }
              },
            ),
            TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date'), readOnly: true, style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Maintenance planifiée'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Planifier'),
          ),
        ],
      ),
    );
  }
}
