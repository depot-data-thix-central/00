// 📁 lib/presentation/admin_hopital/settings/widgets/settings_service_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_form_field.dart';
import '../../../common/widgets/admin_dropdown.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class SettingsServiceForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback? onCancel;
  final Map<String, dynamic>? initialData;

  const SettingsServiceForm({
    Key? key,
    required this.onSave,
    this.onCancel,
    this.initialData,
  }) : super(key: key);

  @override
  State<SettingsServiceForm> createState() => _SettingsServiceFormState();
}

class _SettingsServiceFormState extends State<SettingsServiceForm> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _headCtrl = TextEditingController();
  final _bedsCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // Valeurs
  String _status = 'active';
  bool _isEmergency = false;
  bool _has24hService = false;

  final List<String> _statuses = ['active', 'inactive'];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _nameCtrl.text = widget.initialData!['name'] ?? '';
      _descriptionCtrl.text = widget.initialData!['description'] ?? '';
      _headCtrl.text = widget.initialData!['head'] ?? '';
      _bedsCtrl.text = widget.initialData!['beds']?.toString() ?? '';
      _phoneCtrl.text = widget.initialData!['phone'] ?? '';
      _emailCtrl.text = widget.initialData!['email'] ?? '';
      _status = widget.initialData!['status'] ?? 'active';
      _isEmergency = widget.initialData!['isEmergency'] ?? false;
      _has24hService = widget.initialData!['has24hService'] ?? false;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _headCtrl.dispose();
    _bedsCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
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
                const Icon(Icons.business, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  widget.initialData == null ? 'Nouveau service' : 'Modifier le service',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),

            AdminFormField(
              label: 'Nom du service *',
              controller: _nameCtrl,
              hint: 'Cardiologie, Pédiatrie...',
              validator: (v) => v?.isEmpty == true ? 'Nom requis' : null,
            ),
            const SizedBox(height: 12),

            AdminFormField(
              label: 'Description',
              controller: _descriptionCtrl,
              hint: 'Description du service...',
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            AdminFormField(
              label: 'Chef de service',
              controller: _headCtrl,
              hint: 'Dr. Martin',
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: AdminFormField(
                    label: 'Nombre de lits',
                    controller: _bedsCtrl,
                    keyboardType: TextInputType.number,
                    hint: '0',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminFormField(
                    label: 'Téléphone',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    hint: '01 23 45 67 89',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            AdminFormField(
              label: 'Email',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              hint: 'service@hopital.fr',
              validator: (v) {
                if (v != null && v.isNotEmpty && !v.contains('@')) {
                  return 'Email invalide';
                }
                return null;
              },
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
                        child: Text(s == 'active' ? 'Actif' : 'Inactif', style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _status = v ?? _status),
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
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _isEmergency,
                              onChanged: (v) => setState(() => _isEmergency = v ?? false),
                              activeColor: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Urgences',
                              style: TextStyle(
                                fontSize: 12,
                                color: _isEmergency ? Colors.red : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: _has24hService,
                              onChanged: (v) => setState(() => _has24hService = v ?? false),
                              activeColor: Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '24h/24',
                              style: TextStyle(
                                fontSize: 12,
                                color: _has24hService ? Colors.blue : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: AdminGradientButton(
                    text: widget.initialData == null ? 'Créer le service' : 'Enregistrer les modifications',
                    onPressed: _save,
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

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameCtrl.text,
      'description': _descriptionCtrl.text,
      'head': _headCtrl.text,
      'beds': int.tryParse(_bedsCtrl.text) ?? 0,
      'phone': _phoneCtrl.text,
      'email': _emailCtrl.text,
      'status': _status,
      'isEmergency': _isEmergency,
      'has24hService': _has24hService,
    };
    widget.onSave(data);
  }
}
