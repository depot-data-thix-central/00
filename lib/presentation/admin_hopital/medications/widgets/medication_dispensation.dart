// 📁 lib/presentation/admin_hopital/medications/widgets/medication_dispensation.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_form_field.dart';
import '../../../common/widgets/admin_dropdown.dart';
import '../../../common/widgets/admin_gradient_button.dart';
import '../../../common/widgets/admin_search_bar.dart';
import '../../common/providers/admin_medication_provider.dart';
import '../../common/providers/admin_patient_provider.dart';
import '../../../../data/models/hospital/medication_model.dart';
import '../../../../data/models/hospital/patient_model.dart';

class MedicationDispensation extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onDispense;
  final String? patientId;

  const MedicationDispensation({
    Key? key,
    required this.onDispense,
    this.patientId,
  }) : super(key: key);

  @override
  ConsumerState<MedicationDispensation> createState() => _MedicationDispensationState();
}

class _MedicationDispensationState extends ConsumerState<MedicationDispensation> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _searchCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();

  // Valeurs
  String? _selectedMedicationId;
  String? _selectedPatientId;
  int _dispensedQuantity = 1;
  String _unit = 'Boîte';
  List<MedicationModel> _availableMedications = [];
  List<PatientModel> _patients = [];
  bool _isLoading = true;

  final List<String> _units = ['Boîte', 'Comprimé', 'Gélule', 'Sachet', 'Ampoule', 'Flacon', 'Tube', 'Inhalateur'];

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.patientId;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Charger les médicaments disponibles
      await ref.read(adminMedicationProvider.notifier).loadMedications();
      final medState = ref.read(adminMedicationProvider);
      _availableMedications = medState.medications.where((m) => m.quantity > 0).toList();

      // Charger les patients
      await ref.read(adminPatientProvider.notifier).loadPatients();
      final patientState = ref.read(adminPatientProvider);
      _patients = patientState.patients;

      // Si un patient est pré-sélectionné, le définir
      if (_selectedPatientId != null) {
        final exists = _patients.any((p) => p.id == _selectedPatientId);
        if (!exists) _selectedPatientId = null;
      }
    } catch (e) {
      // Gérer l'erreur
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<MedicationModel> get _filteredMedications {
    final query = _searchCtrl.text.toLowerCase();
    if (query.isEmpty) return _availableMedications;
    return _availableMedications.where((m) =>
      m.name.toLowerCase().contains(query) ||
      m.dosage.toLowerCase().contains(query)
    ).toList();
  }

  MedicationModel? get _selectedMedication {
    if (_selectedMedicationId == null) return null;
    return _availableMedications.firstWhere(
      (m) => m.id == _selectedMedicationId,
      orElse: () => null,
    );
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
                const Icon(Icons.assignment_turned_in, size: 20, color: Colors.teal),
                const SizedBox(width: 8),
                const Text(
                  'Dispensation de médicament',
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

            // Médicament
            AdminSearchBar(
              controller: _searchCtrl,
              onSearch: (_) => setState(() {}),
              hintText: 'Rechercher un médicament...',
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _filteredMedications.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Aucun médicament disponible',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filteredMedications.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final med = _filteredMedications[index];
                        final isSelected = _selectedMedicationId == med.id;
                        return InkWell(
                          onTap: () => setState(() => _selectedMedicationId = med.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            color: isSelected ? Colors.teal.shade50 : Colors.transparent,
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: med.id,
                                  groupValue: _selectedMedicationId,
                                  onChanged: (_) => setState(() => _selectedMedicationId = med.id),
                                  activeColor: Colors.teal,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        med.name,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        '${med.dosage} • Stock: ${med.quantity} unités',
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                                if (med.quantity <= (med.threshold ?? 30))
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Stock bas',
                                      style: TextStyle(fontSize: 9, color: Colors.orange.shade700),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),

            // Quantité et unité
            Row(
              children: [
                Expanded(
                  child: AdminFormField(
                    label: 'Quantité *',
                    controller: _quantityCtrl,
                    keyboardType: TextInputType.number,
                    hint: '1',
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Quantité requise';
                      if (int.tryParse(v) == null) return 'Nombre invalide';
                      final qty = int.parse(v);
                      if (qty <= 0) return 'Quantité > 0';
                      final med = _selectedMedication;
                      if (med != null && qty > med.quantity) {
                        return 'Stock insuffisant (${med.quantity} disponibles)';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminDropdown<String>(
                    label: 'Unité',
                    value: _unit,
                    items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (v) => setState(() => _unit = v ?? _unit),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Instructions
            AdminFormField(
              label: 'Instructions (optionnel)',
              controller: _instructionsCtrl,
              hint: 'Prendre avec de la nourriture, etc.',
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Résumé
            if (_selectedMedication != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.teal),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dispensation: ${_selectedMedication!.name} (${_selectedMedication!.dosage}) - ${_quantityCtrl.text.isNotEmpty ? _quantityCtrl.text : '0'} ${_unit}',
                        style: TextStyle(fontSize: 13, color: Colors.teal.shade800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            AdminGradientButton(
              text: 'Dispenser le médicament',
              onPressed: _dispense,
              icon: Icons.check_circle,
              gradient: const LinearGradient(colors: [Colors.teal, Colors.tealAccent]),
            ),
          ],
        ),
      ),
    );
  }

  void _dispense() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un patient'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_selectedMedicationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un médicament'), backgroundColor: Colors.orange),
      );
      return;
    }

    final quantity = int.parse(_quantityCtrl.text);
    final med = _selectedMedication!;

    final data = {
      'medicationId': med.id,
      'medicationName': med.name,
      'dosage': med.dosage,
      'patientId': _selectedPatientId!,
      'quantity': quantity,
      'unit': _unit,
      'instructions': _instructionsCtrl.text,
      'date': DateTime.now(),
    };

    // Mettre à jour le stock
    final newStock = med.quantity - quantity;
    ref.read(adminMedicationProvider.notifier).updateStock(med.id, newStock);

    widget.onDispense(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Médicament dispensé avec succès'), backgroundColor: Colors.green),
    );

    // Réinitialiser
    setState(() {
      _selectedMedicationId = null;
      _quantityCtrl.clear();
      _instructionsCtrl.clear();
      _searchCtrl.clear();
    });
  }
}
