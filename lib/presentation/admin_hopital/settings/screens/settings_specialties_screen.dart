// 📁 lib/presentation/admin_hopital/settings/screens/settings_specialties_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/settings_specialty_form.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_status_badge.dart';
import '../../common/widgets/admin_confirm_dialog.dart';

class SettingsSpecialtiesScreen extends ConsumerStatefulWidget {
  const SettingsSpecialtiesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsSpecialtiesScreen> createState() => _SettingsSpecialtiesScreenState();
}

class _SettingsSpecialtiesScreenState extends ConsumerState<SettingsSpecialtiesScreen> {
  String _searchQuery = '';
  bool _isLoading = true;

  // Données mockées (à remplacer par le provider)
  final List<Map<String, dynamic>> _specialties = [
    {'id': '1', 'name': 'Cardiologie', 'code': 'I10', 'description': 'Maladies cardiovasculaires', 'color': '#F44336', 'icon': 'favorite', 'category': 'Médicale', 'status': 'active'},
    {'id': '2', 'name': 'Pédiatrie', 'code': 'P00', 'description': 'Médecine infantile', 'color': '#4CAF50', 'icon': 'child_care', 'category': 'Médicale', 'status': 'active'},
    {'id': '3', 'name': 'Chirurgie générale', 'code': 'S00', 'description': 'Chirurgie viscérale', 'color': '#3F51B5', 'icon': 'surgery', 'category': 'Chirurgicale', 'status': 'active'},
    {'id': '4', 'name': 'Radiologie', 'code': 'R00', 'description': 'Imagerie médicale', 'color': '#FF9800', 'icon': 'image', 'category': 'Radiologique', 'status': 'inactive'},
  ];

  List<Map<String, dynamic>> get _filteredSpecialties {
    if (_searchQuery.isEmpty) return _specialties;
    final query = _searchQuery.toLowerCase();
    return _specialties.where((s) =>
      s['name'].toLowerCase().contains(query) ||
      s['code'].toLowerCase().contains(query) ||
      s['category'].toLowerCase().contains(query)
    ).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isLoading = false);
  }

  void _showAddSpecialtyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: 500,
          child: SettingsSpecialtyForm(
            onSave: (data) {
              Navigator.pop(context);
              setState(() {
                _specialties.add({
                  ...data,
                  'id': '${DateTime.now().millisecondsSinceEpoch}',
                });
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Spécialité créée'), backgroundColor: Colors.green),
              );
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  void _showEditSpecialtyDialog(Map<String, dynamic> specialty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: 500,
          child: SettingsSpecialtyForm(
            initialData: specialty,
            onSave: (data) {
              Navigator.pop(context);
              final index = _specialties.indexWhere((s) => s['id'] == specialty['id']);
              if (index != -1) {
                setState(() {
                  _specialties[index] = {..._specialties[index], ...data};
                });
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Spécialité modifiée'), backgroundColor: Colors.green),
              );
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteSpecialty(Map<String, dynamic> specialty) async {
    final confirm = await AdminConfirmDialog.show(
      context: context,
      title: 'Supprimer la spécialité',
      message: 'Êtes-vous sûr de vouloir supprimer la spécialité "${specialty['name']}" ?',
      confirmText: 'Supprimer',
      confirmColor: Colors.red,
    );
    if (confirm == true) {
      setState(() {
        _specialties.removeWhere((s) => s['id'] == specialty['id']);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Spécialité supprimée'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSpecialties;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des spécialités'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSpecialtyDialog,
            tooltip: 'Ajouter une spécialité',
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
        message: 'Chargement des spécialités...',
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: AdminSearchBar(
                      onSearch: (query) => setState(() => _searchQuery = query),
                      hintText: 'Rechercher une spécialité...',
                    ),
                  ),
                  const SizedBox(width: 12),
                  AdminGradientButton(
                    text: 'Ajouter',
                    onPressed: _showAddSpecialtyDialog,
                    icon: Icons.add,
                    height: 40,
                    width: 100,
                    gradient: const LinearGradient(colors: [Colors.purple, Colors.purpleAccent]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty && !_isLoading
                  ? const AdminEmptyState(
                      title: 'Aucune spécialité',
                      subtitle: 'Créez votre première spécialité',
                      icon: Icons.medical_services_outlined,
                      actionText: 'Ajouter une spécialité',
                      onAction: null,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final specialty = filtered[index];
                        return _SpecialtyCard(
                          specialty: specialty,
                          onEdit: () => _showEditSpecialtyDialog(specialty),
                          onDelete: () => _deleteSpecialty(specialty),
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

class _SpecialtyCard extends StatelessWidget {
  final Map<String, dynamic> specialty;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SpecialtyCard({
    required this.specialty,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = specialty['status'] == 'active';
    final color = specialty['color'] != null ? Color(int.parse(specialty['color'].replaceFirst('#', '0xFF'))) : Colors.purple;
    final iconName = specialty['icon']?.isNotEmpty == true ? specialty['icon'] : 'medical_services';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isActive ? color.withOpacity(0.3) : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIcon(iconName),
              size: 22,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  specialty['name'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Code: ${specialty['code'] ?? 'N/A'} • ${specialty['category']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  specialty['description'] ?? '',
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

  IconData _getIcon(String name) {
    // Mappage simple pour les icônes Material Icons
    const iconMap = {
      'favorite': Icons.favorite,
      'child_care': Icons.child_care,
      'surgery': Icons.surgery,
      'image': Icons.image,
      'medical_services': Icons.medical_services,
      'person': Icons.person,
      'science': Icons.science,
      'health_and_safety': Icons.health_and_safety,
    };
    return iconMap[name] ?? Icons.medical_services;
  }
}
