// 📁 lib/presentation/admin_hopital/staff/widgets/staff_absence_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_form_field.dart';
import '../../../common/widgets/admin_dropdown.dart';
import '../../../common/widgets/admin_date_picker.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class StaffAbsenceForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback? onCancel;
  final Map<String, dynamic>? initialData;

  const StaffAbsenceForm({
    Key? key,
    required this.onSave,
    this.onCancel,
    this.initialData,
  }) : super(key: key);

  @override
  State<StaffAbsenceForm> createState() => _StaffAbsenceFormState();
}

class _StaffAbsenceFormState extends State<StaffAbsenceForm> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _reasonCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  // Valeurs
  String _absenceType = 'Congés payés';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isFullDay = true;

  final List<String> _absenceTypes = [
    'Congés payés',
    'Congés maladie',
    'Congés maternité/paternité',
    'Congés sans solde',
    'Formation',
    'RTT',
    'Jours fériés',
    'Autre',
  ];

  final List<String> _durations = [
    'Journée complète',
    'Matin',
    'Après-midi',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _reasonCtrl.text = widget.initialData!['reason'] ?? '';
      _descriptionCtrl.text = widget.initialData!['description'] ?? '';
      _absenceType = widget.initialData!['type'] ?? 'Congés payés';
      _startDate = widget.initialData!['startDate'];
      _endDate = widget.initialData!['endDate'];
      _isFullDay = widget.initialData!['isFullDay'] ?? true;
    }
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                const Icon(Icons.beach_access, size: 20, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Déclarer une absence',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AdminDropdown<String>(
              label: 'Type d\'absence *',
              value: _absenceType,
              items: _absenceTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (v) => setState(() => _absenceType = v ?? _absenceType),
            ),
            const SizedBox(height: 12),
            AdminFormField(
              label: 'Motif (optionnel)',
              controller: _reasonCtrl,
              hint: 'Raison de l\'absence',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AdminDatePicker(
                    label: 'Date de début *',
                    selectedDate: _startDate,
                    onDateSelected: (date) => setState(() => _startDate = date),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminDatePicker(
                    label: 'Date de fin *',
                    selectedDate: _endDate,
                    onDateSelected: (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _isFullDay ? 'Journée complète' : 'Matin',
                    items: _durations.map((d) {
                      return DropdownMenuItem(
                        value: d,
                        child: Text(d, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        _isFullDay = v == 'Journée complète';
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Durée',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminFormField(
                    label: 'Description (optionnel)',
                    controller: _descriptionCtrl,
                    hint: 'Détails supplémentaires',
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AdminGradientButton(
                    text: 'Enregistrer',
                    onPressed: _submitForm,
                    icon: Icons.save,
                  ),
                ),
                if (widget.onCancel != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Annuler', style: TextStyle(fontSize: 13)),
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

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner les dates'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La date de fin doit être postérieure à la date de début'), backgroundColor: Colors.orange),
      );
      return;
    }

    final data = {
      'type': _absenceType,
      'reason': _reasonCtrl.text,
      'description': _descriptionCtrl.text,
      'startDate': _startDate!,
      'endDate': _endDate!,
      'isFullDay': _isFullDay,
    };
    widget.onSave(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Absence enregistrée'), backgroundColor: Colors.green),
    );
  }
}
