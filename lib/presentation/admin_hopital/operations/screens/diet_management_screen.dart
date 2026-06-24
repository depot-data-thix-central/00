// 📁 lib/presentation/admin_hopital/operations/screens/diet_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/meal_planning_form.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_status_badge.dart';

class DietManagementScreen extends ConsumerStatefulWidget {
  const DietManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DietManagementScreen> createState() => _DietManagementScreenState();
}

class _DietManagementScreenState extends ConsumerState<DietManagementScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all';
  bool _isLoading = false;

  // Données mockées
  final List<Map<String, dynamic>> _meals = [
    {'id': '1', 'patient': 'Michel Dupont', 'meal': 'Poulet grillé, riz, légumes', 'mealType': 'Déjeuner', 'dietType': 'Sans sel', 'mealDate': DateTime.now(), 'serveTime': DateTime.now().add(const Duration(hours: 2)), 'status': 'planned', 'ingredients': 'Poulet, riz, légumes verts'},
    {'id': '2', 'patient': 'Sophie Martin', 'meal': 'Purée de légumes, poisson', 'mealType': 'Dîner', 'dietType': 'Mixé', 'mealDate': DateTime.now().add(const Duration(days: 1)), 'serveTime': DateTime.now().add(const Duration(hours: 6)), 'status': 'planned', 'ingredients': 'Légumes, poisson, pommes de terre'},
    {'id': '3', 'patient': 'Lucas Bernard', 'meal': 'Pain, beurre, confiture', 'mealType': 'Petit-déjeuner', 'dietType': 'Standard', 'mealDate': DateTime.now().add(const Duration(days: -1)), 'serveTime': DateTime.now().add(const Duration(hours: -2)), 'status': 'served', 'ingredients': 'Pain, beurre, confiture'},
  ];

  List<Map<String, dynamic>> get _filteredMeals {
    var filtered = _meals;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((m) =>
        m['patient'].toLowerCase().contains(query) ||
        m['meal'].toLowerCase().contains(query) ||
        m['mealType'].toLowerCase().contains(query)
      ).toList();
    }
    if (_filterStatus != 'all') {
      filtered = filtered.where((m) => m['status'] == _filterStatus).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredMeals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des repas'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMealDialog(),
            tooltip: 'Planifier un repas',
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
                      hintText: 'Rechercher un repas (patient, type)...',
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
                        DropdownMenuItem(value: 'preparing', child: Text('En préparation', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'served', child: Text('Servis', style: TextStyle(fontSize: 13))),
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
                      title: 'Aucun repas planifié',
                      subtitle: 'Planifiez les repas des patients',
                      icon: Icons.restaurant_outlined,
                      actionText: 'Planifier un repas',
                      onAction: null,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final m = filtered[index];
                        final statusColor = m['status'] == 'served' ? Colors.green : (m['status'] == 'planned' ? Colors.blue : Colors.orange);
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.restaurant, size: 22, color: Colors.orange),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m['patient'],
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${m['mealType']} • ${m['meal']}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Régime: ${m['dietType']} • ${m['serveTime'] != null ? '${(m['serveTime'] as DateTime).hour}h${(m['serveTime'] as DateTime).minute.toString().padLeft(2, '0')}' : ''}',
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                              AdminStatusBadge(
                                status: m['status'] == 'served' ? StatusType.completed : (m['status'] == 'planned' ? StatusType.pending : StatusType.warning),
                                customLabel: m['status'] == 'served' ? 'Servi' : (m['status'] == 'planned' ? 'Planifié' : 'En préparation'),
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

  void _showAddMealDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: 500,
          child: MealPlanningForm(
            onSave: (data) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Repas planifié'), backgroundColor: Colors.green),
              );
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
