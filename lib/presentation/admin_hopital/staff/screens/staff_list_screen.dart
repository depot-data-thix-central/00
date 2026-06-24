// 📁 lib/presentation/admin_hopital/staff/screens/staff_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common/providers/admin_staff_provider.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_data_table.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_status_badge.dart';
import '../../common/widgets/admin_confirm_dialog.dart';
import '../../../../data/models/hospital/staff_model.dart';

class StaffListScreen extends ConsumerStatefulWidget {
  const StaffListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends ConsumerState<StaffListScreen> {
  String _searchQuery = '';
  String _roleFilter = 'all';
  String _statusFilter = 'all';

  final List<String> _roleOptions = [
    'all',
    'Médecin',
    'Infirmier',
    'Chirurgien',
    'Anesthésiste',
    'Radiologue',
    'Biologiste',
    'Pharmacien',
    'Secrétaire',
    'Administrateur'
  ];

  final List<String> _statusOptions = ['all', 'active', 'inactive'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminStaffProvider.notifier).loadStaff();
    });
  }

  List<StaffModel> get _filteredStaff {
    final state = ref.watch(adminStaffProvider);
    var filtered = state.staff;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((s) =>
        s.fullName.toLowerCase().contains(query) ||
        s.email.toLowerCase().contains(query) ||
        s.specialty.toLowerCase().contains(query)
      ).toList();
    }

    if (_roleFilter != 'all') {
      filtered = filtered.where((s) => s.role == _roleFilter).toList();
    }

    if (_statusFilter != 'all') {
      filtered = filtered.where((s) => s.status == _statusFilter).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminStaffProvider);
    final notifier = ref.read(adminStaffProvider.notifier);
    final filtered = _filteredStaff;

    return AdminLoadingOverlay(
      isLoading: state.isLoading && state.staff.isEmpty,
      message: 'Chargement du personnel...',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre de recherche et filtres
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AdminSearchBar(
                  onSearch: (query) => setState(() => _searchQuery = query),
                  hintText: 'Rechercher un membre (nom, email, spécialité)',
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButton<String>(
                  value: _roleFilter,
                  items: _roleOptions.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(
                        role == 'all' ? 'Tous les rôles' : role,
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _roleFilter = v ?? 'all'),
                  underline: const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButton<String>(
                  value: _statusFilter,
                  items: _statusOptions.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        status == 'all' ? 'Tous statuts' : (status == 'active' ? 'Actifs' : 'Inactifs'),
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _statusFilter = v ?? 'all'),
                  underline: const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 8),
              AdminGradientButton(
                text: 'Ajouter',
                onPressed: () {
                  context.push('/admin/staff/create');
                },
                icon: Icons.person_add,
                height: 40,
                width: 120,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Compteur
          Row(
            children: [
              Text(
                '${filtered.length} membre${filtered.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              if (state.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Tableau
          Expanded(
            child: filtered.isEmpty && !state.isLoading
                ? const AdminEmptyState(
                    title: 'Aucun membre trouvé',
                    subtitle: 'Aucun membre du personnel ne correspond à vos critères',
                    icon: Icons.people_outline,
                  )
                : AdminDataTable(
                    columns: const [
                      DataColumn(label: Text('Nom')),
                      DataColumn(label: Text('Rôle')),
                      DataColumn(label: Text('Spécialité')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Statut')),
                      DataColumn(label: Text('')),
                    ],
                    rows: filtered.map((staff) {
                      return {
                        'Nom': staff.fullName,
                        'Rôle': staff.role,
                        'Spécialité': staff.specialty,
                        'Email': staff.email,
                        'Statut': staff.status,
                        'id': staff.id,
                      };
                    }).toList(),
                    onRowTap: (index) {
                      final id = filtered[index].id;
                      context.push('/admin/staff/$id');
                    },
                    selectable: false,
                    isLoading: state.isLoading,
                  ),
          ),
        ],
      ),
    );
  }
}
