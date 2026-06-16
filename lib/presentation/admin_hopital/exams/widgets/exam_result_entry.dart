// 📁 lib/presentation/admin_hopital/exams/widgets/exam_result_entry.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_form_field.dart';
import '../../../common/widgets/admin_dropdown.dart';
import '../../../common/widgets/admin_gradient_button.dart';
import '../../../common/widgets/admin_date_picker.dart';
import '../../common/providers/admin_exam_provider.dart';
import '../../../../data/models/hospital/exam_model.dart';

class ExamResultEntry extends ConsumerStatefulWidget {
  final String? examId;
  final String? patientId;
  final String? patientName;
  final Function(Map<String, dynamic>)? onSave;

  const ExamResultEntry({
    Key? key,
    this.examId,
    this.patientId,
    this.patientName,
    this.onSave,
  }) : super(key: key);

  @override
  ConsumerState<ExamResultEntry> createState() => _ExamResultEntryState();
}

class _ExamResultEntryState extends ConsumerState<ExamResultEntry> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _resultCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _rangeCtrl = TextEditingController();

  // Valeurs
  String _examType = 'Biologie';
  String _priority = 'normal';
  String _status = 'pending';
  DateTime? _examDate;
  bool _isAbnormal = false;
  bool _isLoading = false;
  ExamModel? _exam;

  final List<String> _examTypes = [
    'Biologie', 'Hématologie', 'Biochimie', 'Microbiologie',
    'Radiologie', 'Échographie', 'Scanner', 'IRM',
    'Électrocardiogramme', 'Échocardiographie', 'Holter',
    'Endoscopie', 'Coloscopie',
    'Biopsie', 'Cytologie',
    'Autre'
  ];

  final List<String> _priorities = ['normal', 'urgent', 'très urgent'];
  final List<String> _statuses = ['pending', 'in_progress', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _examDate = DateTime.now();
    if (widget.examId != null) {
      _loadExam();
    }
  }

  Future<void> _loadExam() async {
    setState(() => _isLoading = true);
    final exams = ref.read(adminExamProvider).exams;
    final exam = exams.firstWhere(
      (e) => e.id == widget.examId,
      orElse: () => null,
    );
    if (exam != null) {
      setState(() {
        _exam = exam;
        _examType = exam.type;
        _priority = exam.priority;
        _status = exam.status;
        _examDate = exam.date;
        _resultCtrl.text = exam.result ?? '';
        _notesCtrl.text = exam.notes ?? '';
        _rangeCtrl.text = exam.referenceRange ?? '';
        _isAbnormal = exam.isAbnormal ?? false;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _resultCtrl.dispose();
    _notesCtrl.dispose();
    _rangeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final patientName = widget.patientName ?? _exam?.patientName ?? 'Patient inconnu';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science, size: 20, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Saisie des résultats d\'examen',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Informations patient
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Patient: $patientName',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  if (_exam != null)
                    Text(
                      'Examen #${_exam!.id.substring(0, 6)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AdminDropdown<String>(
                    label: 'Type d\'examen',
                    value: _examType,
                    items: _examTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _examType = v ?? _examType),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminDropdown<String>(
                    label: 'Priorité',
                    value: _priority,
                    items: _priorities.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getPriorityColor(p),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(_getPriorityLabel(p), style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _priority = v ?? _priority),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AdminDatePicker(
                    label: 'Date de l\'examen',
                    selectedDate: _examDate,
                    onDateSelected: (date) => setState(() => _examDate = date),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminDropdown<String>(
                    label: 'Statut',
                    value: _status,
                    items: _statuses.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(_getStatusLabel(s), style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _status = v ?? _status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AdminFormField(
              label: 'Résultat',
              controller: _resultCtrl,
              hint: 'Saisir le résultat de l\'examen...',
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AdminFormField(
                    label: 'Valeurs de référence',
                    controller: _rangeCtrl,
                    hint: 'Ex: 3.5-5.5 g/L',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _isAbnormal,
                          onChanged: (v) => setState(() => _isAbnormal = v ?? false),
                          activeColor: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Anormal',
                          style: TextStyle(
                            fontSize: 13,
                            color: _isAbnormal ? Colors.red : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AdminFormField(
              label: 'Notes (optionnel)',
              controller: _notesCtrl,
              hint: 'Observations supplémentaires...',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AdminGradientButton(
                    text: _exam != null ? 'Mettre à jour' : 'Enregistrer le résultat',
                    onPressed: _saveResult,
                    icon: Icons.save,
                    gradient: const LinearGradient(colors: [Colors.purple, Colors.purpleAccent]),
                  ),
                ),
                if (widget.examId != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _resultCtrl.clear();
                          _notesCtrl.clear();
                          _rangeCtrl.clear();
                          _isAbnormal = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Réinitialiser', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.orange;
      case 'très urgent':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'urgent':
        return 'Urgent';
      case 'très urgent':
        return 'Très urgent';
      default:
        return 'Normal';
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

  void _saveResult() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'examId': widget.examId,
      'examType': _examType,
      'priority': _priority,
      'date': _examDate!,
      'status': _status,
      'result': _resultCtrl.text,
      'referenceRange': _rangeCtrl.text,
      'isAbnormal': _isAbnormal,
      'notes': _notesCtrl.text,
    };

    if (widget.onSave != null) {
      widget.onSave!(data);
    } else {
      // Sauvegarder directement via le provider
      // À implémenter selon votre logique
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Résultat enregistré'), backgroundColor: Colors.green),
      );
    }
  }
}
