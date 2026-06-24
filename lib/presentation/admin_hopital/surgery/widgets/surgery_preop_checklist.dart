// 📁 lib/presentation/admin_hopital/surgery/widgets/surgery_preop_checklist.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class SurgeryPreopChecklist extends ConsumerStatefulWidget {
  final String patientName;
  final String surgeryType;
  final String surgeon;
  final DateTime surgeryDate;
  final Function(bool) onComplete;

  const SurgeryPreopChecklist({
    Key? key,
    required this.patientName,
    required this.surgeryType,
    required this.surgeon,
    required this.surgeryDate,
    required this.onComplete,
  }) : super(key: key);

  @override
  ConsumerState<SurgeryPreopChecklist> createState() => _SurgeryPreopChecklistState();
}

class _SurgeryPreopChecklistState extends ConsumerState<SurgeryPreopChecklist> {
  final Map<String, bool> _checklist = {
    'Consentement éclairé signé': false,
    'Examens pré-opératoires réalisés': false,
    'Bilan sanguin complet': false,
    'Électrocardiogramme': false,
    'Radio thorax': false,
    'Évaluation anesthésique': false,
    'Jeûne respecté (6h)': false,
    'Antécédents médicaux vérifiés': false,
    'Allergies documentées': false,
    'Traitements en cours listés': false,
    'Bracelet patient identifié': false,
    'Marquage du site opératoire': false,
  };

  final List<String> _criticalItems = [
    'Consentement éclairé signé',
    'Évaluation anesthésique',
    'Jeûne respecté (6h)',
    'Marquage du site opératoire',
  ];

  String? _notes;
  bool _isAllValidated = false;

  @override
  Widget build(BuildContext context) {
    final progress = _checklist.values.where((v) => v).length;
    final total = _checklist.length;
    final progressPercent = total > 0 ? (progress / total * 100) : 0;

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
          // En-tête
          Row(
            children: [
              const Icon(Icons.checklist, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Checklist pré-opératoire',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient: ${widget.patientName}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Intervention: ${widget.surgeryType} • Dr. ${widget.surgeon}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      Text(
                        'Date: ${widget.surgeryDate.day}/${widget.surgeryDate.month}/${widget.surgeryDate.year} à ${widget.surgeryDate.hour.toString().padLeft(2, '0')}:${widget.surgeryDate.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${progressPercent.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: progressPercent == 100 ? Colors.green : Colors.blue,
                      ),
                    ),
                    Text(
                      '$progress/$total',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Barre de progression
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: progressPercent / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      progressPercent < 50 ? Colors.orange : (progressPercent < 100 ? Colors.blue : Colors.green),
                      progressPercent < 50 ? Colors.orangeAccent : (progressPercent < 100 ? Colors.blueAccent : Colors.greenAccent),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Liste des items
          ..._checklist.keys.map((item) {
            final isChecked = _checklist[item] ?? false;
            final isCritical = _criticalItems.contains(item);
            return CheckboxListTile(
              value: isChecked,
              onChanged: (value) {
                setState(() {
                  _checklist[item] = value ?? false;
                });
              },
              title: Text(
                item,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isChecked ? FontWeight.w500 : FontWeight.w400,
                  color: isChecked ? Colors.green.shade800 : Colors.grey.shade700,
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: isCritical
                  ? Text(
                      '⚠️ Élément critique',
                      style: TextStyle(fontSize: 10, color: Colors.red.shade600),
                    )
                  : null,
              activeColor: Colors.blue,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
            );
          }),

          const SizedBox(height: 12),

          // Notes
          TextField(
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Notes (optionnel)',
              hintText: 'Observations supplémentaires...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: const TextStyle(fontSize: 13),
            onChanged: (v) => _notes = v,
          ),
          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: AdminGradientButton(
                  text: progressPercent == 100 ? 'Valider la checklist' : '${progressPercent.toStringAsFixed(0)}% complété',
                  onPressed: progressPercent == 100 ? () {
                    setState(() => _isAllValidated = true);
                    widget.onComplete(true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Checklist validée'), backgroundColor: Colors.green),
                    );
                  } : null,
                  icon: progressPercent == 100 ? Icons.check_circle : Icons.pending,
                  gradient: progressPercent == 100
                      ? const LinearGradient(colors: [Colors.green, Colors.greenAccent])
                      : const LinearGradient(colors: [Colors.grey, Colors.grey]),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _checklist.updateAll((key, value) => false);
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Réinitialiser', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          if (_isAllValidated) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Checklist validée pour ${widget.patientName}',
                      style: TextStyle(fontSize: 13, color: Colors.green.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
