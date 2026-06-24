// 📁 lib/presentation/admin_hopital/patients/screens/patient_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common/providers/admin_patient_provider.dart';
import '../../common/widgets/admin_form_field.dart';
import '../../common/widgets/admin_dropdown.dart';
import '../../common/widgets/admin_date_picker.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../../common/widgets/error_widget.dart';
import '../../../../data/models/hospital/patient_model.dart';

class PatientEditScreen extends ConsumerStatefulWidget {
  final String patientId;

  const PatientEditScreen({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  ConsumerState<PatientEditScreen> createState() => _PatientEditScreenState();
}

class _PatientEditScreenState extends ConsumerState<PatientEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Contrôleurs
  late TextEditingController _fullNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _emergencyContactCtrl;
  late TextEditingController _hospitalIdCtrl;
  late TextEditingController _thixIdCtrl;

  // Valeurs
  String _gender = '';
  String _bloodType = '';
  String _status = 'active';
  DateTime? _birthDate;
  List<String> _allergies = [];

  final List<String> _genders = ['Masculin', 'Féminin', 'Autre'];
  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _statuses = ['active', 'inactive', 'admitted'];
  final List<String> _allergyOptions = ['Pénicilline', 'Acariens', 'Pollens', 'Latex', 'Œufs', 'Arachides', 'Autre'];

  PatientModel? _patient;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fullNameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _emergencyContactCtrl = TextEditingController();
    _hospitalIdCtrl = TextEditingController();
    _thixIdCtrl = TextEditingController();
    _loadPatient();
  }

  Future<void> _loadPatient() async {
    final patient = await ref.read(adminPatientProvider.notifier).getPatientById(widget.patientId);
    if (mounted) {
      if (patient != null) {
        setState(() {
          _patient = patient;
          _fullNameCtrl.text = patient.fullName;
          _emailCtrl.text = patient.email;
          _phoneCtrl.text = patient.phoneNumber;
          _addressCtrl.text = patient.address;
          _emergencyContactCtrl.text = patient.emergencyContact ?? '';
          _hospitalIdCtrl.text = patient.hospitalId;
          _thixIdCtrl.text = patient.thixId ?? '';
          _gender = patient.gender;
          _bloodType = patient.bloodType ?? '';
          _status = patient.status;
          _birthDate = patient.birthDate;
          _allergies = patient.allergies ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Patient non trouvé';
          _isLoading = false;
        });
      }
    }
  }

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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(_error!, style: const TextStyle(fontSize: 14)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le patient'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Modification du dossier patient',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Identité
              const Text('Identité', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AdminDropdown<String>(
                      label: 'Groupe sanguin',
                      value: _bloodType.isNotEmpty ? _bloodType : null,
                      items: _bloodTypes.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                      onChanged: (v) => setState(() => _bloodType = v ?? ''),
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

              // Coordonnées
              const Text('Coordonnées', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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

              // Identifiants
              const Text('Identifiants', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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

              // Allergies
              const Text('Allergies', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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

              // Statut
              AdminDropdown<String>(
                label: 'Statut',
                value: _status,
                items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _status = v ?? 'active'),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: AdminGradientButton(
                      text: _isSubmitting ? 'Mise à jour...' : 'Enregistrer les modifications',
                      onPressed: _isSubmitting ? null : _submitForm,
                      icon: _isSubmitting ? null : Icons.save,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
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
              ),
            ],
          ),
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
      final updatedPatient = _patient!.copyWith(
        fullName: _fullNameCtrl.text,
        email: _emailCtrl.text,
        phoneNumber: _phoneCtrl.text,
        address: _addressCtrl.text,
        emergencyContact: _emergencyContactCtrl.text.isNotEmpty ? _emergencyContactCtrl.text : null,
        hospitalId: _hospitalIdCtrl.text,
        thixId: _thixIdCtrl.text.isNotEmpty ? _thixIdCtrl.text : null,
        gender: _gender,
        bloodType: _bloodType.isNotEmpty ? _bloodType : null,
        birthDate: _birthDate!,
        allergies: _allergies,
        status: _status,
        updatedAt: DateTime.now(),
      );

      final success = await ref.read(adminPatientProvider.notifier).updatePatient(updatedPatient);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient modifié avec succès'), backgroundColor: Colors.green),
        );
        context.pop();
        // Rafraîchir la liste
        ref.read(adminPatientProvider.notifier).loadPatients();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la mise à jour'), backgroundColor: Colors.red),
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
