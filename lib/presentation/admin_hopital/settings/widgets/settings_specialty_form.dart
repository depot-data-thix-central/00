// 📁 lib/presentation/admin_hopital/settings/widgets/settings_specialty_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_form_field.dart';
import '../../../common/widgets/admin_dropdown.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class SettingsSpecialtyForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback? onCancel;
  final Map<String, dynamic>? initialData;

  const SettingsSpecialtyForm({
    Key? key,
    required this.onSave,
    this.onCancel,
    this.initialData,
  }) : super(key: key);

  @override
  State<SettingsSpecialtyForm> createState() => _SettingsSpecialtyFormState();
}

class _SettingsSpecialtyFormState extends State<SettingsSpecialtyForm> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _iconCtrl = TextEditingController();

  // Valeurs
  String _category = 'Médicale';
  String _status = 'active';

  final List<String> _categories = ['Médicale', 'Chirurgicale', 'Biologique', 'Radiologique', 'Autre'];
  final List<String> _statuses = ['active', 'inactive'];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _nameCtrl.text = widget.initialData!['name'] ?? '';
      _codeCtrl.text = widget.initialData!['code'] ?? '';
      _descriptionCtrl.text = widget.initialData!['description'] ?? '';
      _colorCtrl.text = widget.initialData!['color'] ?? '#3F51B5';
      _iconCtrl.text = widget.initialData!['icon'] ?? '';
      _category = widget.initialData!['category'] ?? 'Médicale';
      _status = widget.initialData!['status'] ?? 'active';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _descriptionCtrl.dispose();
    _colorCtrl.dispose();
    _iconCtrl.dispose();
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
                const Icon(Icons.medical_services, size: 20, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  widget.initialData == null ? 'Nouvelle spécialité' : 'Modifier la spécialité',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),

            AdminFormField(
              label: 'Nom de la spécialité *',
              controller: _nameCtrl,
              hint: 'Cardiologie, Chirurgie...',
              validator: (v) => v?.isEmpty == true ? 'Nom requis' : null,
            ),
            const SizedBox(height: 12),

            AdminFormField(
              label: 'Code CIM-10 (optionnel)',
              controller: _codeCtrl,
              hint: 'I10, J06.9...',
            ),
            const SizedBox(height: 12),

            AdminFormField(
              label: 'Description',
              controller: _descriptionCtrl,
              hint: 'Description de la spécialité...',
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: AdminFormField(
                    label: 'Couleur (hexadécimal)',
                    controller: _colorCtrl,
                    hint: '#3F51B5',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminFormField(
                    label: 'Icône (nom MaterialIcons)',
                    controller: _iconCtrl,
                    hint: 'favorite, person...',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: AdminDropdown<String>(
                    label: 'Catégorie',
                    value: _category,
                    items: _categories.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _category = v ?? _category),
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
                        child: Text(s == 'active' ? 'Actif' : 'Inactif', style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _status = v ?? _status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: AdminGradientButton(
                    text: widget.initialData == null ? 'Créer la spécialité' : 'Enregistrer les modifications',
                    onPressed: _save,
                    icon: Icons.save,
                    gradient: const LinearGradient(colors: [Colors.purple, Colors.purpleAccent]),
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
      'code': _codeCtrl.text,
      'description': _descriptionCtrl.text,
      'color': _colorCtrl.text,
      'icon': _iconCtrl.text,
      'category': _category,
      'status': _status,
    };
    widget.onSave(data);
  }
}
