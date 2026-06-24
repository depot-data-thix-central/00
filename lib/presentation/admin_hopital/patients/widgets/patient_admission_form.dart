// 📁 lib/presentation/admin_hopital/patients/widgets/patient_admission_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/providers/admin_patient_provider.dart';
import '../../../common/providers/admin_bed_provider.dart';
import '../../../common/widgets/admin_form_field.dart';
import '../../../common/widgets/admin_dropdown.dart';
import '../../../common/widgets/admin_date_picker.dart';
import '../../../common/widgets/admin_gradient_button.dart';
import '../../../../data/models/hospital/patient_model.dart';

class PatientAdmissionForm extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback? onCancel;

  const PatientAdmissionForm({
    Key? key,
    required this.onSuccess,
    this.onCancel,
  }) : super(key: key);

  @override
  ConsumerState<PatientAdmissionForm> createState() => _PatientAdmissionFormState();
}

class _PatientAdmissionFormState extends ConsumerState<PatientAdmissionForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Contrôleurs
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _emergencyContactCtrl = TextEditingController();
  final _hospitalIdCtrl = TextEditingController();
  final _thixIdCtrl = TextEditingController();

  // Valeurs sélectionnées
  String _gender = '';
  String _bloodType = '';
  String _status = 'active';
  DateTime? _birthDate;
  List<String> _allergies = [];

  // Options
  final List<String> _genders = ['Masculin', 'Féminin', 'Autre'];
  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _statuses = ['active', 'inactive', 'admitted'];
  final List<String> _allergyOptions = ['Pénicilline', 'Acariens', 'Pollens', 'Latex', 'Œufs', 'Arachides', 'Autre'];

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _emergencyContactCtrl.dispose();
    _hospitalIdCtrl.dispose();
    _thixIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admission d\'un nouveau patient',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Remplissez tous les champs pour créer le dossier patient',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // Section : Identité
            const Text(
              'Identité',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            AdminFormField(
              label: 'Nom complet *',
              controller: _fullNameCtrl,
              validator: (v) => v?.isEmpty == true ? 'Nom complet requis' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AdminFormField(
                    label: 'Email',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v != null && v.isNotEmpty && !v.contains('@')) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminFormField(
                    label: 'Téléphone *',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v?.isEmpty == true ? 'Téléphone requis' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AdminDropdown<String>(
                    label: 'Genre',
                    value: _gender.isNotEmpty ? _gender : null,
                    items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (v) => setState(() => _gender = v ?? ''),
                    hint: 'Sélectionner',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminDropdown<String>(
                    label: 'Groupe sanguin',
                    value: _bloodType.isNotEmpty ? _bloodType : null,
                    items: _bloodTypes.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                    onChanged: (v) => setState(() => _bloodType = v ?? ''),
                    hint: 'Sélectionner',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminDatePicker(
                    label: 'Date de naissance *',
                    selectedDate: _birthDate,
                    onDateSelected: (date) => setState(() => _birthDate = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section : Coordonnées
            const Text(
              'Coordonnées',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            AdminFormField(
              label: 'Adresse',
              controller: _addressCtrl,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            AdminFormField(
              label: 'Contact d\'urgence',
              controller: _emergencyContactCtrl,
            ),
            const SizedBox(height: 16),

            // Section : Identifiants
            const Text(
              'Identifiants',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AdminFormField(
                    label: 'N° d\'hospitalisation *',
                    controller: _hospitalIdCtrl,
                    validator: (v) => v?.isEmpty == true ? 'Numéro requis' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminFormField(
                    label: 'THIX ID',
                    controller: _thixIdCtrl,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section : Allergies
            const Text(
              'Allergies',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allergyOptions.map((allergy) {
                final isSelected = _allergies.contains(allergy);
                return FilterChip(
                  label: Text(
                    allergy,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _allergies.add(allergy);
                      } else {
                        _allergies.remove(allergy);
                      }
                    });
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: Colors.red,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Section : Statut
            AdminDropdown<String>(
              label: 'Statut',
              value: _status,
              items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _status = v ?? 'active'),
            ),
            const SizedBox(height: 24),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: AdminGradientButton(
                    text: _isSubmitting ? 'Création en cours...' : 'Admettre le patient',
                    onPressed: _isSubmitting ? null : _submitForm,
                    icon: _isSubmitting ? null : Icons.person_add,
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

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une date de naissance'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final patient = PatientModel(
        id: '',
        fullName: _fullNameCtrl.text,
        email: _emailCtrl.text,
        phoneNumber: _phoneCtrl.text,
        address: _addressCtrl.text,
        emergencyContact: _emergencyContactCtrl.text,
        hospitalId: _hospitalIdCtrl.text,
        thixId: _thixIdCtrl.text.isNotEmpty ? _thixIdCtrl.text : null,
        gender: _gender,
        bloodType: _bloodType.isNotEmpty ? _bloodType : null,
        birthDate: _birthDate!,
        allergies: _allergies,
        status: _status,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await ref.read(adminPatientProvider.notifier).addPatient(patient);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient admis avec succès'), backgroundColor: Colors.green),
        );
        widget.onSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'admission'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
