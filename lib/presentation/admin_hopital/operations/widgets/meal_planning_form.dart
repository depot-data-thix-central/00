// 📁 lib/presentation/admin_hopital/operations/widgets/meal_planning_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_form_field.dart';
import '../../../common/widgets/admin_dropdown.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class MealPlanningForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback? onCancel;
  final Map<String, dynamic>? initialData;

  const MealPlanningForm({
    Key? key,
    required this.onSave,
    this.onCancel,
    this.initialData,
  }) : super(key: key);

  @override
  State<MealPlanningForm> createState() => _MealPlanningFormState();
}

class _MealPlanningFormState extends State<MealPlanningForm> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _patientCtrl = TextEditingController();
  final _mealCtrl = TextEditingController();
  final _ingredientsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Valeurs
  String _mealType = 'Petit-déjeuner';
  String _dietType = 'Standard';
  String _status = 'planned';
  DateTime? _mealDate;
  DateTime? _serveTime;

  final List<String> _mealTypes = ['Petit-déjeuner', 'Déjeuner', 'Dîner', 'Collation'];
  final List<String> _dietTypes = [
    'Standard',
    'Sans sel',
    'Sans sucre',
    'Diabétique',
    'Hypocalorique',
    'Hyperprotéiné',
    'Végétarien',
    'Sans gluten',
    'Liquide',
    'Mixé'
  ];
  final List<String> _statuses = ['planned', 'preparing', 'served', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _mealDate = DateTime.now();
    _serveTime = DateTime.now().add(const Duration(hours: 2));
    if (widget.initialData != null) {
      _patientCtrl.text = widget.initialData!['patient'] ?? '';
      _mealCtrl.text = widget.initialData!['meal'] ?? '';
      _ingredientsCtrl.text = widget.initialData!['ingredients'] ?? '';
      _notesCtrl.text = widget.initialData!['notes'] ?? '';
      _mealType = widget.initialData!['mealType'] ?? 'Petit-déjeuner';
      _dietType = widget.initialData!['dietType'] ?? 'Standard';
      _status = widget.initialData!['status'] ?? 'planned';
      _mealDate = widget.initialData!['mealDate'];
      _serveTime = widget.initialData!['serveTime'];
    }
  }

  @override
  void dispose() {
    _patientCtrl.dispose();
    _mealCtrl.dispose();
    _ingredientsCtrl.dispose();
    _notesCtrl.dispose();
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
                const Icon(Icons.restaurant, size: 20, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Planification des repas',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AdminFormField(
              label: 'Patient *',
              controller: _patientCtrl,
              hint: 'Nom du patient',
              validator: (v) => v?.isEmpty == true ? 'Patient requis' : null,
            ),
            const SizedBox(height: 12),
            AdminFormField(
              label: 'Repas *',
              controller: _mealCtrl,
              hint: 'Description du repas',
              validator: (v) => v?.isEmpty == true ? 'Repas requis' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AdminDropdown<String>(
                    label: 'Type de repas',
                    value: _mealType,
                    items: _mealTypes.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(t, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _mealType = v ?? _mealType),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminDropdown<String>(
                    label: 'Régime',
                    value: _dietType,
                    items: _dietTypes.map((d) {
                      return DropdownMenuItem(
                        value: d,
                        child: Text(d, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _dietType = v ?? _dietType),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AdminFormField(
              label: 'Ingrédients',
              controller: _ingredientsCtrl,
              hint: 'Liste des ingrédients',
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: const Text(
                        'Date',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        _mealDate != null
                            ? '${_mealDate!.day}/${_mealDate!.month}/${_mealDate!.year}'
                            : 'Sélectionner',
                        style: TextStyle(fontSize: 13),
                      ),
                      trailing: const Icon(Icons.calendar_today, size: 18),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _mealDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) setState(() => _mealDate = picked);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: const Text(
                        'Heure de service',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        _serveTime != null
                            ? '${_serveTime!.hour.toString().padLeft(2, '0')}:${_serveTime!.minute.toString().padLeft(2, '0')}'
                            : 'Sélectionner',
                        style: TextStyle(fontSize: 13),
                      ),
                      trailing: const Icon(Icons.access_time, size: 18),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_serveTime ?? DateTime.now()),
                        );
                        if (picked != null) {
                          final now = DateTime.now();
                          setState(() {
                            _serveTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AdminDropdown<String>(
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
            const SizedBox(height: 12),
            AdminFormField(
              label: 'Notes',
              controller: _notesCtrl,
              hint: 'Observations, allergies...',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AdminGradientButton(
                    text: 'Enregistrer le repas',
                    onPressed: _saveMeal,
                    icon: Icons.save,
                    gradient: const LinearGradient(colors: [Colors.orange, Colors.orangeAccent]),
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

  String _getStatusLabel(String status) {
    switch (status) {
      case 'planned':
        return 'Planifié';
      case 'preparing':
        return 'En préparation';
      case 'served':
        return 'Servi';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }

  void _saveMeal() {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'patient': _patientCtrl.text,
      'meal': _mealCtrl.text,
      'mealType': _mealType,
      'dietType': _dietType,
      'ingredients': _ingredientsCtrl.text,
      'mealDate': _mealDate,
      'serveTime': _serveTime,
      'status': _status,
      'notes': _notesCtrl.text,
    };
    widget.onSave(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Repas enregistré'), backgroundColor: Colors.green),
    );
  }
}
