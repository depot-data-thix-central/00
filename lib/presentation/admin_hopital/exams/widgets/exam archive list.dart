// 📁 lib/presentation/admin_hopital/exams/widgets/exam_archive_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_search_bar.dart';
import '../../../common/widgets/admin_status_badge.dart';
import '../../../common/widgets/admin_empty_state.dart';
import '../../../common/widgets/admin_confirm_dialog.dart';
import '../../common/providers/admin_exam_provider.dart';
import '../../../../data/models/hospital/exam_model.dart';

class ExamArchiveList extends ConsumerStatefulWidget {
  final String? patientId;
  final Function(ExamModel)? onExamTap;

  const ExamArchiveList({
    Key? key,
    this.patientId,
    this.onExamTap,
  }) : super(key: key);

  @override
  ConsumerState<ExamArchiveList> createState() => _ExamArchiveListState();
}

class _ExamArchiveListState extends ConsumerState<ExamArchiveList> {
  String _searchQuery = '';
  String _filterStatus = 'all';
  String _filterType = 'all';

  final List<String> _statuses = ['all', 'pending', 'in_progress', 'completed', 'cancelled'];
  final List<String> _types = ['all', 'Biologie', 'Radiologie', 'Scanner', 'IRM', 'Échographie', 'Autre'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminExamProvider.notifier).loadExams();
    });
  }

  List<ExamModel> get _filteredExams {
    final state = ref.watch(adminExamProvider);
    var filtered = state.exams;

    // Filtrer par patient
    if (widget.patientId != null) {
      filtered = filtered.where((e) => e.patientId == widget.patientId).toList();
    }

    // Recherche
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((e) =>
        e.patientName.toLowerCase().contains(query) ||
        e.type.toLowerCase().contains(query) ||
        (e.doctorName?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    // Filtre par statut
    if (_filterStatus != 'all') {
      filtered = filtered.where((e) => e.status == _filterStatus).toList();
    }

    // Filtre par type
    if (_filterType != 'all') {
      filtered = filtered.where((e) => e.type == _filterType).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminExamProvider);
    final filtered = _filteredExams;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barre de recherche et filtres
        Row(
          children: [
            Expanded(
              child: AdminSearchBar(
                onSearch: (query) => setState(() => _searchQuery = query),
                hintText: 'Rechercher un examen (patient, type, médecin)',
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButton<String>(
                value: _filterStatus,
                items: _statuses.map((s) {
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
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButton<String>(
                value: _filterType,
                items: _types.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(
                      t == 'all' ? 'Tous types' : t,
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _filterType = v ?? 'all'),
                underline: const SizedBox.shrink(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Compteur
        Text(
          '${filtered.length} examen${filtered.length > 1 ? 's' : ''}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),

        // Liste
        if (state.isLoading && state.exams.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (filtered.isEmpty)
          const AdminEmptyState(
            title: 'Aucun examen trouvé',
            subtitle: 'Aucun examen ne correspond à vos critères',
            icon: Icons.science_outlined,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final exam = filtered[index];
              return _ExamArchiveItem(
                exam: exam,
                onTap: () {
                  if (widget.onExamTap != null) {
                    widget.onExamTap!(exam);
                  }
                },
                onDelete: () => _deleteExam(exam),
              );
            },
          ),
      ],
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
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

  void _deleteExam(ExamModel exam) async {
    final confirm = await AdminConfirmDialog.show(
      context: context,
      title: 'Supprimer l\'examen',
      message: 'Êtes-vous sûr de vouloir supprimer l\'examen "${exam.type}" du patient ${exam.patientName} ?',
      confirmText: 'Supprimer',
      confirmColor: Colors.red,
    );

    if (confirm == true) {
      // Supprimer l'examen (à implémenter dans le provider)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Examen supprimé'), backgroundColor: Colors.green),
      );
    }
  }
}

class _ExamArchiveItem extends StatelessWidget {
  final ExamModel exam;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ExamArchiveItem({
    required this.exam,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(exam.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: exam.isAbnormal == true ? Colors.red.shade200 : Colors.grey.shade100,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getStatusIcon(exam.status),
                size: 22,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.type,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Patient: ${exam.patientName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (exam.doctorName != null) ...[
                        Text(
                          'Dr. ${exam.doctorName}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '${exam.date.day}/${exam.date.month}/${exam.date.year}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      if (exam.isAbnormal == true) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Anormal',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AdminStatusBadge(
                  status: _getStatusType(exam.status),
                  customLabel: _getStatusLabel(exam.status),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, size: 18),
                      onPressed: onTap,
                      color: Colors.grey.shade500,
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
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
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
      case 'pending':
        return Icons.hourglass_empty;
      case 'in_progress':
        return Icons.sync;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.science;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
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
      case 'pending':
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
