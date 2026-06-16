// 📁 lib/presentation/admin_hopital/exams/widgets/exam_prescription_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_form_field.dart';
import '../../../common/widgets/admin_dropdown.dart';
import '../../../common/widgets/admin_gradient_button.dart';
import '../../../common/widgets/admin_search_bar.dart';
import '../../common/providers/admin_patient_provider.dart';
import '../../common/providers/admin_exam_provider.dart';
import '../../common/providers/admin_staff_provider.dart';
import '../../../../data/models/hospital/exam_model.dart';
import '../../../../data/models/hospital/patient_model.dart';
import '../../../../data/models/hospital/staff_model.dart';

class ExamPrescriptionForm extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onPrescribe;
  final String? patientId;

  const ExamPrescriptionForm({
    Key? key,
    required this.onPrescribe,
    this.patientId,
  }) : super(key: key);

  @override
  ConsumerState<ExamPrescriptionForm> createState() => _ExamPrescriptionFormState();
}

class _ExamPrescriptionFormState extends ConsumerState<ExamPrescriptionForm> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _notesCtrl = TextEditingController();

  // Valeurs
  String? _selectedPatientId;
  String? _selectedDoctorId;
  String _examType = 'Biologie';
  String _priority = 'normal';
  String _status = 'pending';
  DateTime? _examDate;
  List<String> _selectedExams = [];

  final List<String> _examTypes = [
    'Biologie', 'Hématologie', 'Biochimie', 'Microbiologie',
    'Radiologie', 'Échographie', 'Scanner', 'IRM',
    'Électrocardiogramme', 'Échocardiographie', 'Holter',
    'Endoscopie', 'Coloscopie',
    'Biopsie', 'Cytologie',
    'Autre'
  ];

  final List<String> _priorities = ['normal', 'urgent', 'très urgent'];
  final List<String> _examList = [
    'Bilan sanguin complet',
    'Bilan hépatique',
    'Bilan rénal',
    'Bilan lipidique',
    'Hémogramme',
    'CRP',
    'Radiographie thoracique',
    'Échographie abdominale',
    'Scanner cérébral',
    'IRM lombaire',
    'Électrocardiogramme',
    'Holter 24h',
    'Endoscopie digestive',
    'Coloscopie',
    'Biopsie hépatique',
    'Examen cytologique',
  ];

  List<PatientModel> _patients = [];
  List<StaffModel> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.patientId;
    _examDate = DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(adminPatientProvider.notifier).loadPatients();
      await ref.read(adminStaffProvider.notifier).loadStaff();
      final patientState = ref.read(adminPatientProvider);
      final staffState = ref.read(adminStaffProvider);
      setState(() {
        _patients = patientState.patients;
        _doctors = staffState.staff.where((s) => s.role == 'Médecin' || s.role == 'Chirurgien').toList();
        _isLoading = false;
      });
      // Si patientId est fourni, vérifier qu'il existe
      if (_selectedPatientId != null) {
        final exists = _patients.any((p) => p.id == _selectedPatientId);
        if (!exists) _selectedPatientId = null;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
                const Icon(Icons.assignment, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Prescription d\'examens',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Patient
            if (widget.patientId == null)
              AdminDropdown<String>(
                label: 'Patient *',
                value: _selectedPatientId,
                items: _patients.map((p) {
                  return DropdownMenuItem(
                    value: p.id,
                    child: Text(p.fullName, style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedPatientId = v),
                hint: 'Sélectionner un patient',
                isSearchable: true,
              )
            else
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
                      _patients.firstWhere((p) => p.id == _selectedPatientId).fullName,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),

            // Médecin prescripteur
            AdminDropdown<String>(
              label: 'Médecin prescripteur *',
              value: _selectedDoctorId,
              items: _doctors.map((d) {
                return DropdownMenuItem(
                  value: d.id,
                  child: Text('${d.fullName} (${d.specialty})', style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedDoctorId = v),
              hint: 'Sélectionner un médecin',
              isSearchable: true,
            ),
            const SizedBox(height: 12),

            // Type et priorité
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

            // Date
            AdminDatePicker(
              label: 'Date de prescription',
              selectedDate: _examDate,
              onDateSelected: (date) => setState(() => _examDate = date),
            ),
            const SizedBox(height: 12),

            // Sélection multiple d'examens
            const Text(
              'Examens à prescrire',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _examList.map((exam) {
                final isSelected = _selectedExams.contains(exam);
                return FilterChip(
                  label: Text(
                    exam,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedExams.add(exam);
                      } else {
                        _selectedExams.remove(exam);
                      }
                    });
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: Colors.blue,
                );
              }).toList(),
            ),
            if (_selectedExams.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Sélectionnez au moins un examen',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 12),

            // Notes
            AdminFormField(
              label: 'Notes (optionnel)',
              controller: _notesCtrl,
              hint: 'Instructions supplémentaires...',
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            AdminGradientButton(
              text: 'Prescrire les examens',
              onPressed: _prescribe,
              icon: Icons.send,
              gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
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

  void _prescribe() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un patient'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un médecin'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_selectedExams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner au moins un examen'), backgroundColor: Colors.orange),
      );
      return;
    }

    final patient = _patients.firstWhere((p) => p.id == _selectedPatientId);
    final doctor = _doctors.firstWhere((d) => d.id == _selectedDoctorId);

    final data = {
      'patientId': patient.id,
      'patientName': patient.fullName,
      'doctorId': doctor.id,
      'doctorName': doctor.fullName,
      'examType': _examType,
      'priority': _priority,
      'date': _examDate!,
      'exams': _selectedExams,
      'notes': _notesCtrl.text,
    };

    widget.onPrescribe(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Examens prescrits'), backgroundColor: Colors.green),
    );
  }
}
