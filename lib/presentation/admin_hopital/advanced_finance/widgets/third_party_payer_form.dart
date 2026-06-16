// 📁 lib/presentation/admin_hopital/advanced_finance/widgets/third_party_payer_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_form_field.dart';
import '../../../common/widgets/admin_dropdown.dart';
import '../../../common/widgets/admin_gradient_button.dart';
import '../../../common/widgets/admin_date_picker.dart';

class ThirdPartyPayerForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback? onCancel;
  final Map<String, dynamic>? initialData;

  const ThirdPartyPayerForm({
    Key? key,
    required this.onSave,
    this.onCancel,
    this.initialData,
  }) : super(key: key);

  @override
  State<ThirdPartyPayerForm> createState() => _ThirdPartyPayerFormState();
}

class _ThirdPartyPayerFormState extends State<ThirdPartyPayerForm> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _nameCtrl = TextEditingController();
  final _contractIdCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Valeurs
  String _type = 'Mutuelle';
  double _coverageRate = 70.0;
  String _status = 'active';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _autoApply = true;

  final List<String> _types = ['Mutuelle', 'Sécurité Sociale', 'Mécénat', 'Assurance privée', 'État'];
  final List<String> _statuses = ['active', 'inactive', 'pending'];

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    if (widget.initialData != null) {
      _nameCtrl.text = widget.initialData!['name'] ?? '';
      _type = widget.initialData!['type'] ?? 'Mutuelle';
      _coverageRate = widget.initialData!['coverageRate'] ?? 70.0;
      _contractIdCtrl.text = widget.initialData!['contractId'] ?? '';
      _contactCtrl.text = widget.initialData!['contact'] ?? '';
      _phoneCtrl.text = widget.initialData!['phone'] ?? '';
      _emailCtrl.text = widget.initialData!['email'] ?? '';
      _status = widget.initialData!['status'] ?? 'active';
      _startDate = widget.initialData!['startDate'];
      _endDate = widget.initialData!['endDate'];
      _autoApply = widget.initialData!['autoApply'] ?? true;
      _notesCtrl.text = widget.initialData!['notes'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contractIdCtrl.dispose();
    _contactCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
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
                const Icon(Icons.people, size: 20, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Tiers payant',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AdminFormField(
              label: 'Nom du tiers *',
              controller: _nameCtrl,
              hint: 'Mutuelle, Assurance...',
              validator: (v) => v?.isEmpty == true ? 'Nom requis' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AdminDropdown<String>(
                    label: 'Type',
                    value: _type,
                    items: _types.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(t, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _type = v ?? _type),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminFormField(
                    label: 'ID Contrat',
                    controller: _contractIdCtrl,
                    hint: 'Référence du contrat',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AdminFormField(
                    label: 'Contact',
                    controller: _contactCtrl,
                    hint: 'Nom du contact',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminFormField(
                    label: 'Téléphone',
                    controller: _phoneCtrl,
                    hint: '01 23 45 67 89',
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AdminFormField(
              label: 'Email',
              controller: _emailCtrl,
              hint: 'contact@mutuelle.fr',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v != null && v.isNotEmpty && !v.contains('@')) {
                  return 'Email invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Taux de couverture
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Taux de couverture',
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Slider(
                        value: _coverageRate,
                        min: 0,
                        max: 100,
                        divisions: 20,
                        activeColor: Colors.orange,
                        label: '${_coverageRate.toInt()}%',
                        onChanged: (v) => setState(() => _coverageRate = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    '${_coverageRate.toInt()}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AdminDatePicker(
                    label: 'Date de début',
                    selectedDate: _startDate,
                    onDateSelected: (date) => setState(() => _startDate = date),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminDatePicker(
                    label: 'Date de fin',
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
                  child: AdminDropdown<String>(
                    label: 'Statut',
                    value: _status,
                    items: _statuses.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s == 'active' ? 'Actif' : (s == 'inactive' ? 'Inactif' : 'En attente'), style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _status = v ?? _status),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: _autoApply,
                        onChanged: (v) => setState(() => _autoApply = v ?? true),
                        activeColor: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Application auto',
                        style: TextStyle(
                          fontSize: 12,
                          color: _autoApply ? Colors.orange : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AdminFormField(
              label: 'Notes',
              controller: _notesCtrl,
              hint: 'Observations sur le tiers payant...',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AdminGradientButton(
                    text: 'Enregistrer le tiers',
                    onPressed: _savePayer,
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

  void _savePayer() {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'name': _nameCtrl.text,
      'type': _type,
      'coverageRate': _coverageRate,
      'contractId': _contractIdCtrl.text,
      'contact': _contactCtrl.text,
      'phone': _phoneCtrl.text,
      'email': _emailCtrl.text,
      'status': _status,
      'startDate': _startDate,
      'endDate': _endDate,
      'autoApply': _autoApply,
      'notes': _notesCtrl.text,
    };
    widget.onSave(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tiers payant enregistré'), backgroundColor: Colors.green),
    );
  }
}
