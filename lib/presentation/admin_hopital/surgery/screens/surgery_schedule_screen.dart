// 📁 lib/presentation/admin_hopital/surgery/screens/surgery_schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/surgery_schedule_calendar.dart';
import '../../common/providers/admin_operation_provider.dart';
import '../../common/providers/admin_staff_provider.dart';
import '../../common/providers/admin_patient_provider.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_status_badge.dart';
import '../../common/widgets/admin_confirm_dialog.dart';
import '../../../../data/models/hospital/operation_model.dart';

class SurgeryScheduleScreen extends ConsumerStatefulWidget {
  const SurgeryScheduleScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SurgeryScheduleScreen> createState() => _SurgeryScheduleScreenState();
}

class _SurgeryScheduleScreenState extends ConsumerState<SurgeryScheduleScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all';
  bool _showCalendar = true;
  DateTime _selectedDate = DateTime.now();

  final List<String> _statusFilters = [
    'all',
    'scheduled',
    'in_progress',
    'completed',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminOperationProvider.notifier).loadOperations();
    });
  }

  List<OperationModel> get _filteredOperations {
    final state = ref.watch(adminOperationProvider);
    var filtered = state.operations;

    // Recherche
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((o) =>
        o.patientName.toLowerCase().contains(query) ||
        o.type.toLowerCase().contains(query) ||
        o.surgeonName.toLowerCase().contains(query) ||
        o.room.toLowerCase().contains(query)
      ).toList();
    }

    // Filtre par statut
    if (_filterStatus != 'all') {
      filtered = filtered.where((o) => o.status == _filterStatus).toList();
    }

    // Filtre par date
    filtered = filtered.where((o) =>
      o.scheduledDate.year == _selectedDate.year &&
      o.scheduledDate.month == _selectedDate.month &&
      o.scheduledDate.day == _selectedDate.day
    ).toList();

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminOperationProvider);
    final notifier = ref.read(adminOperationProvider.notifier);
    final filtered = _filteredOperations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bloc opératoire'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Icon(_showCalendar ? Icons.list : Icons.calendar_month),
            onPressed: () => setState(() => _showCalendar = !_showCalendar),
            tooltip: _showCalendar ? 'Vue liste' : 'Vue calendrier',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSurgeryDialog(),
            tooltip: 'Programmer une intervention',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: state.isLoading && state.operations.isEmpty,
        message: 'Chargement des interventions...',
        child: Column(
          children: [
            // Barre de recherche et filtres
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AdminSearchBar(
                          onSearch: (query) => setState(() => _searchQuery = query),
                          hintText: 'Rechercher patient, médecin, type...',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DropdownButton<String>(
                          value: _filterStatus,
                          items: _statusFilters.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(
                                s == 'all' ? 'Tous statuts' : _getStatusLabel(s),
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _filterStatus = v ?? 'all'),
                          underline: const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${filtered.length} intervention${filtered.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Contenu
            Expanded(
              child: _showCalendar
                  ? SurgeryScheduleCalendar(
                      onDaySelected: (date) {
                        setState(() => _selectedDate = date);
                      },
                      onSurgeryTap: (patientName) {
                        final op = state.operations.firstWhere(
                          (o) => o.patientName == patientName,
                          orElse: () => null,
                        );
                        if (op != null) {
                          context.push('/admin/surgery/${op.id}');
                        }
                      },
                    )
                  : filtered.isEmpty && !state.isLoading
                      ? const AdminEmptyState(
                          title: 'Aucune intervention',
                          subtitle: 'Aucune intervention programmée pour cette journée',
                          icon: Icons.surgery_outlined,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final op = filtered[index];
                            return _SurgeryCard(
                              operation: op,
                              onTap: () {
                                context.push('/admin/surgery/${op.id}');
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

  String _getStatusLabel(String status) {
    switch (status) {
      case 'scheduled':
        return 'Programmé';
      case 'in_progress':
        return 'En cours';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }

  void _showAddSurgeryDialog() {
    final patientCtrl = TextEditingController();
    final typeCtrl = TextEditingController();
    final surgeonCtrl = TextEditingController();
    final roomCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Programmer une intervention'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: patientCtrl,
                decoration: const InputDecoration(
                  labelText: 'Patient *',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: typeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Type d\'intervention *',
                  hintText: 'Cardiaque, Orthopédique...',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: surgeonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Chirurgien *',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: roomCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Salle *',
                        hintText: 'Salle 1',
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: timeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Heure *',
                        hintText: '08:00',
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Date de l\'intervention'),
                subtitle: Text(
                  selectedDate != null
                      ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                      : 'Sélectionner une date',
                  style: TextStyle(fontSize: 13),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (patientCtrl.text.isEmpty ||
                  typeCtrl.text.isEmpty ||
                  surgeonCtrl.text.isEmpty ||
                  roomCtrl.text.isEmpty ||
                  timeCtrl.text.isEmpty ||
                  selectedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez remplir tous les champs'), backgroundColor: Colors.orange),
                );
                return;
              }
              Navigator.pop(context);
              // Ajouter l'opération via le provider
              // Simuler
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Intervention programmée'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Programmer'),
          ),
        ],
      ),
    );
  }
}

class _SurgeryCard extends StatelessWidget {
  final OperationModel operation;
  final VoidCallback onTap;

  const _SurgeryCard({
    required this.operation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(operation.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
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
                _getStatusIcon(operation.status),
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
                    operation.patientName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${operation.type} • Dr. ${operation.surgeonName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.room, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        operation.room,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '${operation.scheduledDate.hour.toString().padLeft(2, '0')}:${operation.scheduledDate.minute.toString().padLeft(2, '0')}',
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
            AdminStatusBadge(
              status: _getStatusType(operation.status),
              customLabel: _getStatusLabel(operation.status),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'scheduled':
        return Icons.schedule;
      case 'in_progress':
        return Icons.sync;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'scheduled':
        return 'Programmé';
      case 'in_progress':
        return 'En cours';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }

  StatusType _getStatusType(String status) {
    switch (status) {
      case 'scheduled':
        return StatusType.pending;
      case 'in_progress':
        return StatusType.warning;
      case 'completed':
        return StatusType.completed;
      case 'cancelled':
        return StatusType.cancelled;
      default:
        return StatusType.inactive;
    }
  }
}
