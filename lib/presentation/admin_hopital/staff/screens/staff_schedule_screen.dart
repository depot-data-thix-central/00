// 📁 lib/presentation/admin_hopital/staff/screens/staff_schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../widgets/staff_schedule_calendar.dart';
import '../widgets/staff_absence_form.dart';
import '../widgets/staff_role_selector.dart';
import '../../common/providers/admin_staff_provider.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_status_badge.dart';
import '../../../../data/models/hospital/staff_model.dart';

class StaffScheduleScreen extends ConsumerStatefulWidget {
  const StaffScheduleScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StaffScheduleScreen> createState() => _StaffScheduleScreenState();
}

class _StaffScheduleScreenState extends ConsumerState<StaffScheduleScreen> {
  String _searchQuery = '';
  String? _selectedStaffId;
  DateTime _selectedDay = DateTime.now();
  List<StaffModel> _staffList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminStaffProvider.notifier).loadStaff();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminStaffProvider);

    if (state.isLoading && state.staff.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    _staffList = state.staff;

    final filteredStaff = _searchQuery.isEmpty
        ? _staffList
        : _staffList.where((s) =>
            s.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.role.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.specialty.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();

    final selectedStaff = _selectedStaffId != null
        ? _staffList.firstWhereOrNull((s) => s.id == _selectedStaffId)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning du personnel'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAbsenceDialog(),
          ),
        ],
      ),
      body: Row(
        children: [
          // Liste des membres (gauche)
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              children: [
                AdminSearchBar(
                  onSearch: (query) => setState(() => _searchQuery = query),
                  hintText: 'Rechercher...',
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filteredStaff.isEmpty
                      ? const AdminEmptyState(
                          title: 'Aucun membre',
                          subtitle: 'Aucun membre ne correspond',
                          icon: Icons.people_outline,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          itemCount: filteredStaff.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final staff = filteredStaff[index];
                            final isSelected = _selectedStaffId == staff.id;
                            return InkWell(
                              onTap: () => setState(() => _selectedStaffId = staff.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue.shade50 : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          staff.fullName.isNotEmpty ? staff.fullName[0].toUpperCase() : 'P',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            staff.fullName,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '${staff.role} • ${staff.specialty}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AdminStatusBadge(
                                      status: staff.status == 'active'
                                          ? StatusType.active
                                          : StatusType.inactive,
                                      fontSize: 9,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          // Calendrier (droite)
          Expanded(
            child: selectedStaff != null
                ? StaffScheduleCalendar(
                    staffId: selectedStaff.id,
                    onDaySelected: (day) {
                      setState(() => _selectedDay = day);
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sélectionnez un membre du personnel',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'pour voir son planning',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddAbsenceDialog() {
    if (_selectedStaffId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez d\'abord sélectionner un membre'), backgroundColor: Colors.orange),
      );
      return;
    }

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
}
