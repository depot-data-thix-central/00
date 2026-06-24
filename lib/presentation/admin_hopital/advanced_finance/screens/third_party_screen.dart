// 📁 lib/presentation/admin_hopital/advanced_finance/screens/third_party_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/third_party_payer_form.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_status_badge.dart';
import '../../common/widgets/admin_confirm_dialog.dart';

class ThirdPartyScreen extends ConsumerStatefulWidget {
  const ThirdPartyScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ThirdPartyScreen> createState() => _ThirdPartyScreenState();
}

class _ThirdPartyScreenState extends ConsumerState<ThirdPartyScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterType = 'all';

  // Données mockées
  final List<Map<String, dynamic>> _payers = [
    {'id': '1', 'name': 'Mutuelle Générale', 'type': 'Mutuelle', 'coverageRate': 70.0, 'contact': 'Jean Dupont', 'phone': '01 23 45 67 89', 'email': 'contact@mutuelleg.fr', 'status': 'active', 'startDate': DateTime(2023, 1, 1), 'endDate': DateTime(2025, 12, 31), 'autoApply': true},
    {'id': '2', 'name': 'Sécurité Sociale', 'type': 'Sécurité Sociale', 'coverageRate': 80.0, 'contact': 'Service Gestion', 'phone': '01 23 45 67 90', 'email': 'gestion@secu.fr', 'status': 'active', 'startDate': DateTime(2020, 1, 1), 'endDate': null, 'autoApply': true},
    {'id': '3', 'name': 'Assurance Santé Plus', 'type': 'Assurance privée', 'coverageRate': 60.0, 'contact': 'Marie Bernard', 'phone': '01 23 45 67 91', 'email': 'contact@assurance-plus.fr', 'status': 'inactive', 'startDate': DateTime(2022, 6, 1), 'endDate': DateTime(2024, 5, 31), 'autoApply': false},
  ];

  List<Map<String, dynamic>> get _filteredPayers {
    var filtered = _payers;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((p) =>
        p['name'].toLowerCase().contains(query) ||
        p['contact'].toLowerCase().contains(query) ||
        p['email'].toLowerCase().contains(query)
      ).toList();
    }
    if (_filterType != 'all') {
      filtered = filtered.where((p) => p['type'] == _filterType).toList();
    }
    return filtered;
  }

  List<String> get _types => ['all', ..._payers.map((p) => p['type'] as String).toSet()];

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

  void _showAddPayerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: 500,
          child: ThirdPartyPayerForm(
            onSave: (data) {
              Navigator.pop(context);
              setState(() {
                _payers.add({
                  'id': '${DateTime.now().millisecondsSinceEpoch}',
                  ...data,
                });
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tiers payant ajouté'), backgroundColor: Colors.green),
              );
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  void _showEditPayerDialog(Map<String, dynamic> payer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: 500,
          child: ThirdPartyPayerForm(
            initialData: payer,
            onSave: (data) {
              Navigator.pop(context);
              final index = _payers.indexWhere((p) => p['id'] == payer['id']);
              if (index != -1) {
                setState(() {
                  _payers[index] = {..._payers[index], ...data};
                });
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tiers payant modifié'), backgroundColor: Colors.green),
              );
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Future<void> _deletePayer(Map<String, dynamic> payer) async {
    final confirm = await AdminConfirmDialog.show(
      context: context,
      title: 'Supprimer le tiers payant',
      message: 'Êtes-vous sûr de vouloir supprimer "${payer['name']}" ?',
      confirmText: 'Supprimer',
      confirmColor: Colors.red,
    );
    if (confirm == true) {
      setState(() {
        _payers.removeWhere((p) => p['id'] == payer['id']);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tiers payant supprimé'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPayers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des tiers payants'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddPayerDialog,
            tooltip: 'Ajouter un tiers payant',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
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
                      hintText: 'Rechercher un tiers payant...',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButton<String>(
                      value: _filterType,
                      items: _types.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(t == 'all' ? 'Tous types' : t, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _filterType = v ?? 'all'),
                      underline: const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const AdminEmptyState(
                      title: 'Aucun tiers payant',
                      subtitle: 'Ajoutez un tiers payant',
                      icon: Icons.people_outlined,
                      actionText: 'Ajouter un tiers',
                      onAction: null,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final p = filtered[index];
                        final isActive = p['status'] == 'active';
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isActive ? Colors.green.shade200 : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.business,
                                  size: 22,
                                  color: isActive ? Colors.green : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p['name'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${p['type']} • ${p['coverageRate']}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Contact: ${p['contact']} • ${p['phone']}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  AdminStatusBadge(
                                    status: isActive ? StatusType.active : StatusType.inactive,
                                    customLabel: isActive ? 'Actif' : 'Inactif',
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 18),
                                        onPressed: () => _showEditPayerDialog(p),
                                        color: Colors.grey.shade600,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18),
                                        onPressed: () => _deletePayer(p),
                                        color: Colors.red.shade300,
                                      ),
                                    ],
                                  ),
                                ],
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
}
