// 📁 lib/presentation/admin_hopital/settings/screens/settings_services_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/settings_service_form.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_data_table.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_status_badge.dart';
import '../../common/widgets/admin_confirm_dialog.dart';

// Provider à créer pour les services
// import '../../common/providers/admin_service_provider.dart';

class SettingsServicesScreen extends ConsumerStatefulWidget {
  const SettingsServicesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsServicesScreen> createState() => _SettingsServicesScreenState();
}

class _SettingsServicesScreenState extends ConsumerState<SettingsServicesScreen> {
  String _searchQuery = '';
  bool _isLoading = true;

  // Données mockées (à remplacer par le provider)
  final List<Map<String, dynamic>> _services = [
    {'id': '1', 'name': 'Cardiologie', 'description': 'Soins cardiaques', 'head': 'Dr. Martin', 'beds': 25, 'phone': '01 23 45 67 89', 'email': 'cardiologie@hopital.fr', 'status': 'active', 'isEmergency': true},
    {'id': '2', 'name': 'Pédiatrie', 'description': 'Soins enfants', 'head': 'Dr. Bernard', 'beds': 18, 'phone': '01 23 45 67 90', 'email': 'pediatrie@hopital.fr', 'status': 'active', 'isEmergency': false},
    {'id': '3', 'name': 'Orthopédie', 'description': 'Traumatologie', 'head': 'Dr. Petit', 'beds': 20, 'phone': '01 23 45 67 91', 'email': 'orthopedie@hopital.fr', 'status': 'active', 'isEmergency': false},
    {'id': '4', 'name': 'Radiologie', 'description': 'Imagerie médicale', 'head': 'Dr. Dubois', 'beds': 0, 'phone': '01 23 45 67 92', 'email': 'radiologie@hopital.fr', 'status': 'inactive', 'isEmergency': false},
  ];

  List<Map<String, dynamic>> get _filteredServices {
    if (_searchQuery.isEmpty) return _services;
    final query = _searchQuery.toLowerCase();
    return _services.where((s) =>
      s['name'].toLowerCase().contains(query) ||
      s['description'].toLowerCase().contains(query) ||
      s['head'].toLowerCase().contains(query)
    ).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // Simuler le chargement
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isLoading = false);
  }

  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: 500,
          child: SettingsServiceForm(
            onSave: (data) {
              Navigator.pop(context);
              setState(() {
                _services.add({
                  ...data,
                  'id': '${DateTime.now().millisecondsSinceEpoch}',
                });
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Service créé avec succès'), backgroundColor: Colors.green),
              );
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  void _showEditServiceDialog(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: 500,
          child: SettingsServiceForm(
            initialData: service,
            onSave: (data) {
              Navigator.pop(context);
              final index = _services.indexWhere((s) => s['id'] == service['id']);
              if (index != -1) {
                setState(() {
                  _services[index] = {..._services[index], ...data};
                });
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Service modifié'), backgroundColor: Colors.green),
              );
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteService(Map<String, dynamic> service) async {
    final confirm = await AdminConfirmDialog.show(
      context: context,
      title: 'Supprimer le service',
      message: 'Êtes-vous sûr de vouloir supprimer le service "${service['name']}" ?',
      confirmText: 'Supprimer',
      confirmColor: Colors.red,
    );
    if (confirm == true) {
      setState(() {
        _services.removeWhere((s) => s['id'] == service['id']);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service supprimé'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredServices;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des services'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddServiceDialog,
            tooltip: 'Ajouter un service',
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
        message: 'Chargement des services...',
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: AdminSearchBar(
                      onSearch: (query) => setState(() => _searchQuery = query),
                      hintText: 'Rechercher un service...',
                    ),
                  ),
                  const SizedBox(width: 12),
                  AdminGradientButton(
                    text: 'Ajouter',
                    onPressed: _showAddServiceDialog,
                    icon: Icons.add,
                    height: 40,
                    width: 100,
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty && !_isLoading
                  ? const AdminEmptyState(
                      title: 'Aucun service',
                      subtitle: 'Créez votre premier service',
                      icon: Icons.business_outlined,
                      actionText: 'Ajouter un service',
                      onAction: null,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final service = filtered[index];
                        return _ServiceCard(
                          service: service,
                          onEdit: () => _showEditServiceDialog(service),
                          onDelete: () => _deleteService(service),
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

class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = service['status'] == 'active';
    final isEmergency = service['isEmergency'] ?? false;

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
              isEmergency ? Icons.local_hospital : Icons.medical_services,
              size: 22,
              color: isActive ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      service['name'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isEmergency)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Urgences',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  service['description'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Chef: ${service['head']} • Lits: ${service['beds']}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
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
                    onPressed: onEdit,
                    color: Colors.grey.shade600,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: onDelete,
                    color: Colors.red.shade300,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
