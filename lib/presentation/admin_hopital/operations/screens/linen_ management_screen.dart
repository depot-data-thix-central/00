// 📁 lib/presentation/admin_hopital/operations/screens/linen_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/linen_inventory_item.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';

class LinenManagementScreen extends ConsumerStatefulWidget {
  const LinenManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LinenManagementScreen> createState() => _LinenManagementScreenState();
}

class _LinenManagementScreenState extends ConsumerState<LinenManagementScreen> {
  String _searchQuery = '';
  String _filterCategory = 'all';
  bool _isLoading = false;

  // Données mockées
  final List<Map<String, dynamic>> _linen = [
    {'name': 'Draps blancs', 'category': 'Draps', 'quantity': 150, 'threshold': 100, 'condition': 'good'},
    {'name': 'Taies d\'oreiller', 'category': 'Taies', 'quantity': 80, 'threshold': 60, 'condition': 'good'},
    {'name': 'Serviettes de bain', 'category': 'Serviettes', 'quantity': 45, 'threshold': 50, 'condition': 'fair'},
    {'name': 'Blouses patients', 'category': 'Vêtements', 'quantity': 20, 'threshold': 40, 'condition': 'poor'},
    {'name': 'Gigognes', 'category': 'Équipement', 'quantity': 35, 'threshold': 30, 'condition': 'fair'},
  ];

  List<Map<String, dynamic>> get _filteredLinen {
    var filtered = _linen;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((l) =>
        l['name'].toLowerCase().contains(query) ||
        l['category'].toLowerCase().contains(query)
      ).toList();
    }
    if (_filterCategory != 'all') {
      filtered = filtered.where((l) => l['category'] == _filterCategory).toList();
    }
    return filtered;
  }

  List<String> get _categories => ['all', ..._linen.map((l) => l['category'] as String).toSet()];

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredLinen;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion du linge'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddLinenDialog(),
            tooltip: 'Ajouter du linge',
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
                      hintText: 'Rechercher du linge...',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButton<String>(
                      value: _filterCategory,
                      items: _categories.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(c == 'all' ? 'Toutes catégories' : c, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _filterCategory = v ?? 'all'),
                      underline: const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const AdminEmptyState(
                      title: 'Aucun article',
                      subtitle: 'Ajoutez du linge à l\'inventaire',
                      icon: Icons.checkroom_outlined,
                      actionText: 'Ajouter du linge',
                      onAction: null,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final l = filtered[index];
                        return LinenInventoryItem(
                          name: l['name'],
                          category: l['category'],
                          quantity: l['quantity'],
                          threshold: l['threshold'],
                          condition: l['condition'],
                          onReorder: l['quantity'] <= l['threshold'] ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Commande de réapprovisionnement envoyée'), backgroundColor: Colors.orange),
                            );
                          } : null,
                          onInspect: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Inspection du linge'), backgroundColor: Colors.blue),
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

  void _showAddLinenDialog() {
    final nameCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    final quantityCtrl = TextEditingController();
    final thresholdCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ajouter du linge'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nom *'), style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Catégorie *'), style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            TextField(controller: quantityCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantité *'), style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            TextField(controller: thresholdCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Seuil *'), style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Article ajouté'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
