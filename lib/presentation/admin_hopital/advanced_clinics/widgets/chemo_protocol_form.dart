// 📁 lib/presentation/admin_hopital/advanced_clinics/widgets/chemo_protocol_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChemoProtocolForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onProtocolCreated;
  final String patientId;
  final String patientName;

  const ChemoProtocolForm({
    Key? key,
    required this.onProtocolCreated,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  State<ChemoProtocolForm> createState() => _ChemoProtocolFormState();
}

class _ChemoProtocolFormState extends State<ChemoProtocolForm> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _cycleCtrl = TextEditingController(text: '1');
  final _doseCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Valeurs
  String _protocolName = 'CHOP';
  String _phase = 'Induction';
  String _status = 'planned';
  DateTime? _startDate;
  DateTime? _endDate;
  double _bsa = 0.0;
  List<String> _selectedDrugs = [];
  List<Map<String, dynamic>> _drugsList = [];

  final List<String> _protocols = ['CHOP', 'R-CHOP', 'FOLFOX', 'FOLFIRI', 'TCHP', 'ECF', 'EPI', 'Cisplatine'];
  final List<String> _phases = ['Induction', 'Consolidation', 'Maintenance', 'Palliative'];
  final List<String> _statuses = ['planned', 'active', 'completed', 'on_hold'];

  final List<Map<String, dynamic>> _availableDrugs = [
    {'name': 'Cyclophosphamide', 'dose': '750 mg/m²', 'route': 'IV'},
    {'name': 'Doxorubicine', 'dose': '50 mg/m²', 'route': 'IV'},
    {'name': 'Vincristine', 'dose': '1.4 mg/m²', 'route': 'IV'},
    {'name': 'Prednisone', 'dose': '100 mg/jour', 'route': 'PO'},
    {'name': 'Rituximab', 'dose': '375 mg/m²', 'route': 'IV'},
    {'name': 'Oxaliplatine', 'dose': '85 mg/m²', 'route': 'IV'},
    {'name': 'Leucovorine', 'dose': '400 mg/m²', 'route': 'IV'},
    {'name': '5-FU', 'dose': '400 mg/m²', 'route': 'IV'},
  ];

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
  }

  @override
  void dispose() {
    _cycleCtrl.dispose();
    _doseCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _calculateBSA() {
    final weight = double.tryParse(_weightCtrl.text);
    final height = double.tryParse(_heightCtrl.text);
    if (weight != null && height != null && weight > 0 && height > 0) {
      // Formule de Mosteller
      setState(() {
        _bsa = ((weight * height) / 3600).sqrt();
      });
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medical_services, size: 20, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Protocole de chimiothérapie',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Patient: ${widget.patientName}',
                    style: TextStyle(fontSize: 12, color: Colors.purple.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Protocole et cycle
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonFormField<String>(
                      value: _protocolName,
                      items: _protocols.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(p, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _protocolName = v ?? _protocolName),
                      decoration: InputDecoration(
                        labelText: 'Protocole *',
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
                      controller: _cycleCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Cycle n°',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Phase et statut
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonFormField<String>(
                      value: _phase,
                      items: _phases.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(p, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _phase = v ?? _phase),
                      decoration: InputDecoration(
                        labelText: 'Phase',
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
                      value: _status,
                      items: _statuses.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(_getStatusLabel(s), style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _status = v ?? _status),
                      decoration: InputDecoration(
                        labelText: 'Statut',
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
            // Dates
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: const Text(
                        'Début',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        _startDate != null
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                            : 'Sélectionner',
                        style: TextStyle(fontSize: 13),
                      ),
                      trailing: const Icon(Icons.calendar_today, size: 18),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setState(() => _startDate = picked);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: const Text(
                        'Fin',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        _endDate != null
                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'Non définie',
                        style: TextStyle(fontSize: 13),
                      ),
                      trailing: const Icon(Icons.calendar_today, size: 18),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setState(() => _endDate = picked);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Poids, taille, BSA
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: _weightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Poids (kg)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      style: const TextStyle(fontSize: 13),
                      onChanged: (_) => _calculateBSA(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: _heightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Taille (cm)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      style: const TextStyle(fontSize: 13),
                      onChanged: (_) => _calculateBSA(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SC',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        Text(
                          _bsa > 0 ? '${_bsa.toStringAsFixed(2)} m²' : '--',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Médicaments
            const Text(
              'Médicaments',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableDrugs.map((drug) {
                final isSelected = _selectedDrugs.contains(drug['name']);
                return FilterChip(
                  label: Text(
                    '${drug['name']} (${drug['dose']})',
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDrugs.add(drug['name']);
                        _drugsList.add(drug);
                      } else {
                        _selectedDrugs.remove(drug['name']);
                        _drugsList.removeWhere((d) => d['name'] == drug['name']);
                      }
                    });
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: Colors.purple,
                );
              }).toList(),
            ),
            if (_selectedDrugs.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Sélectionnez au moins un médicament',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 12),
            // Notes
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
                    onPressed: _selectedDrugs.isEmpty ? null : _createProtocol,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Créer le protocole',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'planned':
        return 'Planifié';
      case 'active':
        return 'Actif';
      case 'completed':
        return 'Terminé';
      case 'on_hold':
        return 'En pause';
      default:
        return status;
    }
  }

  void _createProtocol() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'protocolName': _protocolName,
        'cycle': int.tryParse(_cycleCtrl.text) ?? 1,
        'phase': _phase,
        'status': _status,
        'startDate': _startDate,
        'endDate': _endDate,
        'weight': double.tryParse(_weightCtrl.text),
        'height': double.tryParse(_heightCtrl.text),
        'bsa': _bsa,
        'drugs': _drugsList,
        'notes': _notesCtrl.text,
        'patientId': widget.patientId,
        'patientName': widget.patientName,
        'createdAt': DateTime.now(),
      };
      widget.onProtocolCreated(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Protocole créé'), backgroundColor: Colors.green),
      );
    }
  }
}
