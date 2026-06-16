// 📁 lib/presentation/admin_hopital/staff/screens/staff_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/staff_role_selector.dart';
import '../widgets/staff_absence_form.dart';
import '../widgets/staff_schedule_calendar.dart';
import '../../common/providers/admin_staff_provider.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_status_badge.dart';
import '../../common/widgets/admin_confirm_dialog.dart';
import '../../../../data/models/hospital/staff_model.dart';

class StaffDetailScreen extends ConsumerStatefulWidget {
  final String staffId;

  const StaffDetailScreen({
    Key? key,
    required this.staffId,
  }) : super(key: key);

  @override
  ConsumerState<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends ConsumerState<StaffDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StaffModel? _staff;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    final state = ref.watch(adminStaffProvider);
    final staff = state.staff.firstWhere(
      (s) => s.id == widget.staffId,
      orElse: () => null,
    );
    if (staff != null) {
      setState(() {
        _staff = staff;
        _isLoading = false;
      });
    } else {
      await ref.read(adminStaffProvider.notifier).loadStaff();
      final newState = ref.read(adminStaffProvider);
      final found = newState.staff.firstWhere(
        (s) => s.id == widget.staffId,
        orElse: () => null,
      );
      if (found != null) {
        setState(() {
          _staff = found;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Membre non trouvé';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(_error!, style: const TextStyle(fontSize: 14)),
          ),
        ),
      );
    }

    final staff = _staff!;

    return Scaffold(
      appBar: AppBar(
        title: Text(staff.fullName),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // Naviguer vers l'édition (à implémenter)
            },
          ),
          IconButton(
            icon: Icon(
              staff.status == 'active' ? Icons.block : Icons.check_circle,
              color: staff.status == 'active' ? Colors.red : Colors.green,
            ),
            onPressed: () => _toggleStatus(staff),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Profil'),
            Tab(text: 'Absences'),
            Tab(text: 'Planning'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Profil
          _buildProfileTab(staff),
          // Absences
          _buildAbsencesTab(staff),
          // Planning
          StaffScheduleCalendar(staffId: staff.id),
        ],
      ),
    );
  }

  Widget _buildProfileTab(StaffModel staff) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // En-tête avec avatar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      staff.fullName.isNotEmpty ? staff.fullName[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        staff.role,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        staff.specialty,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AdminStatusBadge(
                        status: staff.status == 'active'
                            ? StatusType.active
                            : StatusType.inactive,
                        customLabel: staff.status == 'active' ? 'Actif' : 'Inactif',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Informations détaillées
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informations',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Email', staff.email),
                _buildInfoRow('Téléphone', staff.phoneNumber),
                _buildInfoRow('Spécialité', staff.specialty),
                _buildInfoRow('Service', staff.service ?? 'Non défini'),
                if (staff.registrationNumber != null)
                  _buildInfoRow('N° d\'inscription', staff.registrationNumber!),
                _buildInfoRow('Statut', staff.status == 'active' ? 'Actif' : 'Inactif'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Rôles et permissions
          StaffRoleSelector(
            initialRoles: _getStaffRoles(staff),
            onRolesChanged: (roles) {
              // Sauvegarder les rôles
            },
            isMultiSelect: true,
          ),
          const SizedBox(height: 16),

          AdminGradientButton(
            text: 'Ajouter une absence',
            onPressed: () => _showAddAbsenceDialog(staff),
            icon: Icons.beach_access,
            gradient: const LinearGradient(colors: [Colors.orange, Colors.orangeAccent]),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsencesTab(StaffModel staff) {
    // Données mockées
    final absences = [
      {'type': 'Congés payés', 'start': '2024-12-20', 'end': '2024-12-27', 'status': 'approuvé'},
      {'type': 'Congés maladie', 'start': '2024-11-05', 'end': '2024-11-07', 'status': 'terminé'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Historique des absences de ${staff.fullName}',
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade700),
                  ),
                ),
                AdminGradientButton(
                  text: '+ Ajouter',
                  onPressed: () => _showAddAbsenceDialog(staff),
                  height: 32,
                  width: 100,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (absences.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Aucune absence enregistrée',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            )
          else
            ...absences.map((a) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.beach_access, size: 18, color: Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a['type'] as String,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Du ${a['start']} au ${a['end']}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  AdminStatusBadge(
                    status: a['status'] == 'approuvé' ? StatusType.active : StatusType.pending,
                    customLabel: a['status'] as String,
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  List<StaffRole> _getStaffRoles(StaffModel staff) {
    // Simuler des rôles basés sur le rôle du staff
    final allRoles = StaffRoleSelector.getAllRoles(); // Méthode statique à ajouter
    final roleMap = {
      'Médecin': ['Médecin'],
      'Infirmier': ['Infirmier'],
      'Chirurgien': ['Chirurgien'],
      'Administrateur': ['Administrateur'],
    };
    final roleNames = roleMap[staff.role] ?? [staff.role];
    return allRoles.where((r) => roleNames.contains(r.name)).toList();
  }

  void _showAddAbsenceDialog(StaffModel staff) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: StaffAbsenceForm(
            onSave: (data) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Absence enregistrée'), backgroundColor: Colors.green),
              );
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  void _toggleStatus(StaffModel staff) async {
    final newStatus = staff.status == 'active' ? 'inactive' : 'active';
    final action = staff.status == 'active' ? 'désactiver' : 'activer';
    final confirm = await AdminConfirmDialog.show(
      context: context,
      title: '${staff.status == 'active' ? 'Désactiver' : 'Activer'} le compte',
      message: 'Êtes-vous sûr de vouloir ${action} le compte de ${staff.fullName} ?',
      confirmText: staff.status == 'active' ? 'Désactiver' : 'Activer',
      confirmColor: staff.status == 'active' ? Colors.red : Colors.green,
    );

    if (confirm != true || !mounted) return;

    try {
      // Mettre à jour le statut
      await ref.read(adminStaffProvider.notifier).updateStaff(
        staff.copyWith(status: newStatus),
      );
      await _loadStaff();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compte ${action} avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
