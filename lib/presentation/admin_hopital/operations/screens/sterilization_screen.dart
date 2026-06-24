// 📁 lib/presentation/admin_hopital/operations/screens/sterilization_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/sterilization_tracker.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';

class SterilizationScreen extends ConsumerStatefulWidget {
  const SterilizationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SterilizationScreen> createState() => _SterilizationScreenState();
}

class _SterilizationScreenState extends ConsumerState<SterilizationScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all';
  bool _isLoading = false;

  // Données mockées
  final List<Map<String, dynamic>> _batches = [
    {'id': 'ST-2024-001', 'date': DateTime(2024, 12, 10), 'expiry': DateTime(2025, 1, 10), 'technician': 'Dr. Martin', 'method': 'Autoclave', 'status': 'active', 'items': 24},
    {'id': 'ST-2024-002', 'date': DateTime(2024, 11, 20), 'expiry': DateTime(2024, 12, 20), 'technician': 'Dr. Bernard', 'method': 'Éthylène', 'status': 'active', 'items': 18},
    {'id': 'ST-2024-003', 'date': DateTime(2024, 10, 5), 'expiry': DateTime(2024, 11, 5), 'technician': 'Dr. Petit', 'method': 'Autoclave', 'status': 'expired', 'items': 30},
    {'id': 'ST-2024-004', 'date': DateTime(2024, 12, 1), 'expiry': DateTime(2025, 1, 1), 'technician': 'Dr. Dubois', 'method': 'UV', 'status': 'used', 'items': 12},
  ];

  List<Map<String, dynamic>> get _filteredBatches {
    var filtered = _batches;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((b) =>
        b['id'].toLowerCase().contains(query) ||
        b['technician'].toLowerCase().contains(query) ||
        b['method'].toLowerCase().contains(query)
      ).toList();
    }
    if (_filterStatus != 'all') {
      filtered = filtered.where((b) => b['status'] == _filterStatus).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredBatches;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stérilisation'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBatchDialog(),
            tooltip: 'Nouveau lot',
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
                      hintText: 'Rechercher un lot...',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButton<String>(
                      value: _filterStatus,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Tous', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'active', child: Text('Actifs', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'expired', child: Text('Expirés', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'used', child: Text('Utilisés', style: TextStyle(fontSize: 13))),
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
                      title: 'Aucun lot',
                      subtitle: 'Ajoutez un lot de stérilisation',
                      icon: Icons.cleaning_services_outlined,
                      actionText: 'Ajouter un lot',
                      onAction: null,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final b = filtered[index];
                        return SterilizationTracker(
                          batchId: b['id'],
                          sterilizationDate: b['date'],
                          expiryDate: b['expiry'],
                          technician: b['technician'],
                          method: b['method'],
                          status: b['status'],
                          itemCount: b['items'],
                          onDetails: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Détails du lot'), backgroundColor: Colors.blue),
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

  void _showAddBatchDialog() {
    final idCtrl = TextEditingController(text: 'ST-${DateTime.now().year}-${(DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}');
    final methodCtrl = TextEditingController();
    final itemsCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nouveau lot de stérilisation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'N° lot *'), style: const TextStyle(fontSize: 13), readOnly: true),
            const SizedBox(height: 8),
            TextField(controller: methodCtrl, decoration: const InputDecoration(labelText: 'Méthode *'), style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            TextField(controller: itemsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nombre d\'instruments *'), style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lot ajouté'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
