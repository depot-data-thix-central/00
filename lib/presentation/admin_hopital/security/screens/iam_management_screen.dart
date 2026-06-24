// 📁 lib/presentation/admin_hopital/security/screens/iam_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_status_badge.dart';
import '../../common/widgets/admin_confirm_dialog.dart';

class IamManagementScreen extends ConsumerStatefulWidget {
  const IamManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<IamManagementScreen> createState() => _IamManagementScreenState();
}

class _IamManagementScreenState extends ConsumerState<IamManagementScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterRole = 'all';

  // Données mockées (à remplacer par le provider)
  final List<Map<String, dynamic>> _users = [
    {'id': '1', 'name': 'Dr. Martin', 'email': 'martin@hopital.fr', 'role': 'Médecin', 'status': 'active', 'lastLogin': DateTime.now().subtract(const Duration(hours: 2))},
    {'id': '2', 'name': 'Dr. Bernard', 'email': 'bernard@hopital.fr', 'role': 'Chirurgien', 'status': 'active', 'lastLogin': DateTime.now().subtract(const Duration(days: 1))},
    {'id': '3', 'name': 'Sophie Dupont', 'email': 'sophie.dupont@hopital.fr', 'role': 'Infirmier', 'status': 'active', 'lastLogin': DateTime.now().subtract(const Duration(hours: 5))},
    {'id': '4', 'name': 'Jean Petit', 'email': 'jean.petit@hopital.fr', 'role': 'Secrétaire', 'status': 'inactive', 'lastLogin': DateTime.now().subtract(const Duration(days: 30))},
    {'id': '5', 'name': 'Dr. Dubois', 'email': 'dubois@hopital.fr', 'role': 'Administrateur', 'status': 'active', 'lastLogin': DateTime.now().subtract(const Duration(minutes: 30))},
  ];

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

  List<Map<String, dynamic>> get _filteredUsers {
    var filtered = _users;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((u) =>
        u['name'].toLowerCase().contains(query) ||
        u['email'].toLowerCase().contains(query) ||
        u['role'].toLowerCase().contains(query)
      ).toList();
    }
    if (_filterRole != 'all') {
      filtered = filtered.where((u) => u['role'] == _filterRole).toList();
    }
    return filtered;
  }

  List<String> get _roles => ['all', ..._users.map((u) => u['role'] as String).toSet()];

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String selectedRole = 'Médecin';
    final roles = ['Médecin', 'Chirurgien', 'Infirmier', 'Secrétaire', 'Administrateur', 'Laborantin', 'Pharmacien'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ajouter un utilisateur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nom complet *'), style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email *'), style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedRole,
              items: roles.map((r) {
                return DropdownMenuItem(
                  value: r,
                  child: Text(r, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedRole = v ?? selectedRole),
              decoration: const InputDecoration(
                labelText: 'Rôle *',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _users.add({
                  'id': '${DateTime.now().millisecondsSinceEpoch}',
                  'name': nameCtrl.text,
                  'email': emailCtrl.text,
                  'role': selectedRole,
                  'status': 'active',
                  'lastLogin': DateTime.now(),
                });
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Utilisateur ajouté'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleUserStatus(Map<String, dynamic> user) async {
    final newStatus = user['status'] == 'active' ? 'inactive' : 'active';
    final action = user['status'] == 'active' ? 'désactiver' : 'activer';
    final confirm = await AdminConfirmDialog.show(
      context: context,
      title: '${user['status'] == 'active' ? 'Désactiver' : 'Activer'} l\'utilisateur',
      message: 'Êtes-vous sûr de vouloir ${action} le compte de ${user['name']} ?',
      confirmText: user['status'] == 'active' ? 'Désactiver' : 'Activer',
      confirmColor: user['status'] == 'active' ? Colors.red : Colors.green,
    );
    if (confirm == true) {
      setState(() {
        final index = _users.indexWhere((u) => u['id'] == user['id']);
        if (index != -1) {
          _users[index]['status'] = newStatus;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Compte ${action}é avec succès'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredUsers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des identités (IAM)'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddUserDialog,
            tooltip: 'Ajouter un utilisateur',
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
        message: 'Chargement des utilisateurs...',
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: AdminSearchBar(
                      onSearch: (query) => setState(() => _searchQuery = query),
                      hintText: 'Rechercher un utilisateur...',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButton<String>(
                      value: _filterRole,
                      items: _roles.map((r) {
                        return DropdownMenuItem(
                          value: r,
                          child: Text(r == 'all' ? 'Tous les rôles' : r, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _filterRole = v ?? 'all'),
                      underline: const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const AdminEmptyState(
                      title: 'Aucun utilisateur',
                      subtitle: 'Ajoutez des utilisateurs pour gérer les accès',
                      icon: Icons.people_outlined,
                      actionText: 'Ajouter un utilisateur',
                      onAction: null,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final u = filtered[index];
                        final isActive = u['status'] == 'active';
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
                                  Icons.person,
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
                                      u['name'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      u['email'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          'Rôle: ${u['role']}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Dernière connexion: ${u['lastLogin'].day}/${u['lastLogin'].month}/${u['lastLogin'].year} ${u['lastLogin'].hour}:${u['lastLogin'].minute.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
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
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Édition de l\'utilisateur'), backgroundColor: Colors.blue),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          isActive ? Icons.block : Icons.check_circle,
                                          size: 18,
                                          color: isActive ? Colors.red : Colors.green,
                                        ),
                                        onPressed: () => _toggleUserStatus(u),
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
