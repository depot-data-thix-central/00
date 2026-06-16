// 📁 lib/presentation/admin_hopital/consultations/widgets/consultation_prescription.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_form_field.dart';
import '../../../common/widgets/admin_dropdown.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class PrescriptionItem {
  final String drugName;
  final String dosage;
  final String frequency;
  final String duration;
  final String? instructions;

  PrescriptionItem({
    required this.drugName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'drugName': drugName,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
    };
  }
}

class ConsultationPrescription extends StatefulWidget {
  final Function(List<PrescriptionItem>) onSave;
  final List<PrescriptionItem>? initialPrescriptions;

  const ConsultationPrescription({
    Key? key,
    required this.onSave,
    this.initialPrescriptions,
  }) : super(key: key);

  @override
  State<ConsultationPrescription> createState() => _ConsultationPrescriptionState();
}

class _ConsultationPrescriptionState extends State<ConsultationPrescription> {
  final List<PrescriptionItem> _prescriptions = [];
  final List<String> _frequencies = [
    '1x/jour', '2x/jour', '3x/jour', '4x/jour',
    '1x/semaine', '2x/semaine',
    'Si besoin', 'Au coucher',
    'À jeun', 'Pendant les repas'
  ];
  final List<String> _durations = [
    '3 jours', '5 jours', '7 jours', '10 jours',
    '14 jours', '21 jours', '30 jours',
    'Traitement long', 'Prolongé'
  ];

  final _drugCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  String _frequency = '2x/jour';
  String _duration = '7 jours';
  final _instructionsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialPrescriptions != null) {
      _prescriptions.addAll(widget.initialPrescriptions!);
    }
  }

  @override
  void dispose() {
    _drugCtrl.dispose();
    _dosageCtrl.dispose();
    _instructionsCtrl.dispose();
    super.dispose();
  }

  void _addPrescription() {
    if (_drugCtrl.text.isEmpty || _dosageCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir le médicament et le dosage'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _prescriptions.add(PrescriptionItem(
        drugName: _drugCtrl.text,
        dosage: _dosageCtrl.text,
        frequency: _frequency,
        duration: _duration,
        instructions: _instructionsCtrl.text.isNotEmpty ? _instructionsCtrl.text : null,
      ));
      _drugCtrl.clear();
      _dosageCtrl.clear();
      _instructionsCtrl.clear();
    });
  }

  void _removePrescription(int index) {
    setState(() {
      _prescriptions.removeAt(index);
    });
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Prescription médicamenteuse',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Formulaire d'ajout
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AdminFormField(
                        label: 'Médicament *',
                        controller: _drugCtrl,
                        hint: 'Amoxicilline',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AdminFormField(
                        label: 'Dosage *',
                        controller: _dosageCtrl,
                        hint: '500mg',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AdminDropdown<String>(
                        label: 'Fréquence',
                        value: _frequency,
                        items: _frequencies.map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (v) => setState(() => _frequency = v ?? _frequency),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AdminDropdown<String>(
                        label: 'Durée',
                        value: _duration,
                        items: _durations.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (v) => setState(() => _duration = v ?? _duration),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AdminFormField(
                        label: 'Instructions',
                        controller: _instructionsCtrl,
                        hint: 'Prendre avec de la nourriture',
                      ),
                    ),
                    const SizedBox(width: 12),
                    AdminGradientButton(
                      text: 'Ajouter',
                      onPressed: _addPrescription,
                      icon: Icons.add,
                      height: 40,
                      width: 100,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Liste des prescriptions
          if (_prescriptions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Aucun médicament prescrit',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            )
          else
            Column(
              children: _prescriptions.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.medication, size: 16, color: Colors.blue),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.drugName} (${item.dosage})',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.frequency} • ${item.duration}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                            if (item.instructions != null)
                              Text(
                                item.instructions!,
                                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18, color: Colors.red),
                        onPressed: () => _removePrescription(index),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          if (_prescriptions.isNotEmpty)
            AdminGradientButton(
              text: 'Enregistrer la prescription',
              onPressed: () => widget.onSave(_prescriptions),
              icon: Icons.save,
              height: 40,
            ),
        ],
      ),
    );
  }
}
