// 📁 lib/presentation/admin_hopital/settings/widgets/settings_general_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_form_field.dart';
import '../../../common/widgets/admin_dropdown.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class SettingsGeneralForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback? onCancel;
  final Map<String, dynamic>? initialData;

  const SettingsGeneralForm({
    Key? key,
    required this.onSave,
    this.onCancel,
    this.initialData,
  }) : super(key: key);

  @override
  State<SettingsGeneralForm> createState() => _SettingsGeneralFormState();
}

class _SettingsGeneralFormState extends State<SettingsGeneralForm> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCodeCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _openingHoursCtrl = TextEditingController();

  // Valeurs
  String _country = 'France';
  String _language = 'fr';
  String _timezone = 'Europe/Paris';
  bool _sendNotifications = true;
  bool _allowSms = false;
  bool _allowEmail = true;

  final List<String> _countries = ['France', 'Belgique', 'Suisse', 'Luxembourg', 'Canada'];
  final List<String> _languages = ['fr', 'en', 'ar', 'es', 'de'];
  final List<String> _timezones = ['Europe/Paris', 'Europe/London', 'America/New_York', 'Africa/Dakar'];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _nameCtrl.text = widget.initialData!['name'] ?? '';
      _addressCtrl.text = widget.initialData!['address'] ?? '';
      _cityCtrl.text = widget.initialData!['city'] ?? '';
      _zipCodeCtrl.text = widget.initialData!['zipCode'] ?? '';
      _phoneCtrl.text = widget.initialData!['phone'] ?? '';
      _emailCtrl.text = widget.initialData!['email'] ?? '';
      _websiteCtrl.text = widget.initialData!['website'] ?? '';
      _openingHoursCtrl.text = widget.initialData!['openingHours'] ?? '';
      _country = widget.initialData!['country'] ?? 'France';
      _language = widget.initialData!['language'] ?? 'fr';
      _timezone = widget.initialData!['timezone'] ?? 'Europe/Paris';
      _sendNotifications = widget.initialData!['sendNotifications'] ?? true;
      _allowSms = widget.initialData!['allowSms'] ?? false;
      _allowEmail = widget.initialData!['allowEmail'] ?? true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _zipCodeCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _openingHoursCtrl.dispose();
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.settings, size: 20, color: Colors.teal),
                  const SizedBox(width: 8),
                  const Text(
                    'Paramètres généraux',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              AdminFormField(
                label: 'Nom de l\'établissement *',
                controller: _nameCtrl,
                hint: 'Hôpital Central',
                validator: (v) => v?.isEmpty == true ? 'Nom requis' : null,
              ),
              const SizedBox(height: 12),

              AdminFormField(
                label: 'Adresse *',
                controller: _addressCtrl,
                hint: '12 rue de la République',
                maxLines: 2,
                validator: (v) => v?.isEmpty == true ? 'Adresse requise' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: AdminFormField(
                      label: 'Ville *',
                      controller: _cityCtrl,
                      hint: 'Paris',
                      validator: (v) => v?.isEmpty == true ? 'Ville requise' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AdminFormField(
                      label: 'Code postal *',
                      controller: _zipCodeCtrl,
                      hint: '75000',
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty == true ? 'Code postal requis' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              AdminDropdown<String>(
                label: 'Pays',
                value: _country,
                items: _countries.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c, style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _country = v ?? _country),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: AdminFormField(
                      label: 'Téléphone',
                      controller: _phoneCtrl,
                      hint: '01 23 45 67 89',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AdminFormField(
                      label: 'Email',
                      controller: _emailCtrl,
                      hint: 'contact@hopital.fr',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v != null && v.isNotEmpty && !v.contains('@')) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              AdminFormField(
                label: 'Site web',
                controller: _websiteCtrl,
                hint: 'www.hopital.fr',
              ),
              const SizedBox(height: 12),

              AdminFormField(
                label: 'Horaires d\'ouverture',
                controller: _openingHoursCtrl,
                hint: 'Lun-Ven: 08h-18h, Sam: 09h-12h',
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: AdminDropdown<String>(
                      label: 'Langue par défaut',
                      value: _language,
                      items: _languages.map((l) {
                        return DropdownMenuItem(
                          value: l,
                          child: Text(_getLanguageLabel(l), style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _language = v ?? _language),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AdminDropdown<String>(
                      label: 'Fuseau horaire',
                      value: _timezone,
                      items: _timezones.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(t, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _timezone = v ?? _timezone),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                'Notifications',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Switch(
                          value: _sendNotifications,
                          onChanged: (v) => setState(() => _sendNotifications = v),
                          activeColor: Colors.teal,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Activer les notifications',
                            style: TextStyle(fontSize: 13, color: _sendNotifications ? Colors.teal : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Switch(
                          value: _allowSms,
                          onChanged: (v) => setState(() => _allowSms = v),
                          activeColor: Colors.teal,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Autoriser les SMS',
                            style: TextStyle(fontSize: 13, color: _allowSms ? Colors.teal : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Switch(
                          value: _allowEmail,
                          onChanged: (v) => setState(() => _allowEmail = v),
                          activeColor: Colors.teal,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Autoriser les emails',
                            style: TextStyle(fontSize: 13, color: _allowEmail ? Colors.teal : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AdminGradientButton(
                      text: 'Enregistrer les paramètres',
                      onPressed: _save,
                      icon: Icons.save,
                      gradient: const LinearGradient(colors: [Colors.teal, Colors.tealAccent]),
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
      ),
    );
  }

  String _getLanguageLabel(String code) {
    switch (code) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'Anglais';
      case 'ar':
        return 'Arabe';
      case 'es':
        return 'Espagnol';
      case 'de':
        return 'Allemand';
      default:
        return code;
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameCtrl.text,
      'address': _addressCtrl.text,
      'city': _cityCtrl.text,
      'zipCode': _zipCodeCtrl.text,
      'country': _country,
      'phone': _phoneCtrl.text,
      'email': _emailCtrl.text,
      'website': _websiteCtrl.text,
      'openingHours': _openingHoursCtrl.text,
      'language': _language,
      'timezone': _timezone,
      'sendNotifications': _sendNotifications,
      'allowSms': _allowSms,
      'allowEmail': _allowEmail,
    };
    widget.onSave(data);
  }
}
