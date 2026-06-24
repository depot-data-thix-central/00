// 📁 lib/presentation/admin_hopital/advanced_clinics/widgets/transfusion_compatibility.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransfusionCompatibility extends StatefulWidget {
  final Function(Map<String, dynamic>) onTransfusionOrdered;
  final String? patientBloodType;

  const TransfusionCompatibility({
    Key? key,
    required this.onTransfusionOrdered,
    this.patientBloodType,
  }) : super(key: key);

  @override
  State<TransfusionCompatibility> createState() => _TransfusionCompatibilityState();
}

class _TransfusionCompatibilityState extends State<TransfusionCompatibility> {
  String _patientBloodType = 'A+';
  String _selectedBloodType = 'A+';
  int _quantity = 1;
  String _priority = 'normal';
  String _indication = 'Anémie sévère';
  final TextEditingController _notesCtrl = TextEditingController();

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _priorities = ['normal', 'urgent', 'critical'];
  final List<String> _indications = [
    'Anémie sévère',
    'Hémorragie aiguë',
    'Chirurgie programmée',
    'Pathologie hématologique',
    'Accident vasculaire',
    'Autre'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.patientBloodType != null) {
      _patientBloodType = widget.patientBloodType!;
      _selectedBloodType = widget.patientBloodType!;
    }
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
              const Icon(Icons.bloodtype, size: 20, color: Colors.red),
              const SizedBox(width: 8),
              const Text(
                'Transfusion sanguine',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (widget.patientBloodType != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    'Patient: ${widget.patientBloodType}',
                    style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Compatibilité
          const Text(
            'Compatibilité ABO/Rh',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
                      const Text(
                        'Patient',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _patientBloodType,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, size: 24, color: Colors.grey),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Compatibles',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: _getCompatibleTypes(_patientBloodType).map((type) {
                          final isSelected = type == _selectedBloodType;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.green : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Sélection du produit
          const Text(
            'Sélection du produit',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButtonFormField<String>(
                    value: _selectedBloodType,
                    items: _bloodTypes.map((type) {
                      final isCompatible = _getCompatibleTypes(_patientBloodType).contains(type);
                      return DropdownMenuItem(
                        value: type,
                        enabled: isCompatible,
                        child: Row(
                          children: [
                            Text(type, style: TextStyle(fontSize: 13)),
                            if (!isCompatible)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Icon(Icons.close, size: 14, color: Colors.red),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedBloodType = v ?? _selectedBloodType),
                    decoration: InputDecoration(
                      labelText: 'Groupe sanguin',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantité',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      suffixText: 'poches',
                    ),
                    style: const TextStyle(fontSize: 13),
                    onChanged: (v) => setState(() => _quantity = int.tryParse(v) ?? 1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButtonFormField<String>(
                    value: _indication,
                    items: _indications.map((i) {
                      return DropdownMenuItem(
                        value: i,
                        child: Text(i, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _indication = v ?? _indication),
                    decoration: InputDecoration(
                      labelText: 'Indication',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButtonFormField<String>(
                    value: _priority,
                    items: _priorities.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: p == 'critical' ? Colors.red : (p == 'urgent' ? Colors.orange : Colors.blue),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(_getPriorityLabel(p), style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _priority = v ?? _priority),
                    decoration: InputDecoration(
                      labelText: 'Priorité',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Observations supplémentaires...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(10),
            ),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _orderTransfusion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Commander la transfusion',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> _getCompatibleTypes(String patientType) {
    final map = {
      'A+': ['A+', 'A-', 'O+', 'O-'],
      'A-': ['A-', 'O-'],
      'B+': ['B+', 'B-', 'O+', 'O-'],
      'B-': ['B-', 'O-'],
      'AB+': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
      'AB-': ['A-', 'B-', 'AB-', 'O-'],
      'O+': ['O+', 'O-'],
      'O-': ['O-'],
    };
    return map[patientType] ?? [];
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'critical':
        return 'Critique';
      case 'urgent':
        return 'Urgent';
      default:
        return 'Normal';
    }
  }

  void _orderTransfusion() {
    final data = {
      'patientType': _patientBloodType,
      'selectedType': _selectedBloodType,
      'quantity': _quantity,
      'indication': _indication,
      'priority': _priority,
      'notes': _notesCtrl.text,
      'isCompatible': _getCompatibleTypes(_patientBloodType).contains(_selectedBloodType),
      'timestamp': DateTime.now(),
    };
    widget.onTransfusionOrdered(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Demande de transfusion enregistrée'), backgroundColor: Colors.green),
    );
  }
}
