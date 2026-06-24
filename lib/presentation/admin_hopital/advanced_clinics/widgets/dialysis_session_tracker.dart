// 📁 lib/presentation/admin_hopital/advanced_clinics/widgets/dialysis_session_tracker.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DialysisSessionTracker extends StatefulWidget {
  final String patientId;
  final String patientName;
  final Function(Map<String, dynamic>) onSessionSaved;

  const DialysisSessionTracker({
    Key? key,
    required this.patientId,
    required this.patientName,
    required this.onSessionSaved,
  }) : super(key: key);

  @override
  State<DialysisSessionTracker> createState() => _DialysisSessionTrackerState();
}

class _DialysisSessionTrackerState extends State<DialysisSessionTracker> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _preWeightCtrl = TextEditingController();
  final _postWeightCtrl = TextEditingController();
  final _preBPCtrl = TextEditingController();
  final _postBPCtrl = TextEditingController();
  final _preHrCtrl = TextEditingController();
  final _postHrCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _observationsCtrl = TextEditingController();

  // Valeurs
  String _sessionType = 'Hémodialyse';
  String _status = 'planned';
  String _accessType = 'Fistule';
  DateTime? _sessionDate;
  List<String> _medications = [];
  bool _isCompleted = false;

  final List<String> _sessionTypes = ['Hémodialyse', 'Hémodiafiltration', 'Dialyse péritonéale'];
  final List<String> _statuses = ['planned', 'active', 'completed', 'cancelled'];
  final List<String> _accessTypes = ['Fistule', 'Cathéter', 'Greffe', 'Péritonéale'];
  final List<String> _medicationOptions = ['Héparine', 'Erythropoïétine', 'Calcimimétique', 'Vitamine D', 'Fer'];

  @override
  void initState() {
    super.initState();
    _sessionDate = DateTime.now();
  }

  @override
  void dispose() {
    _preWeightCtrl.dispose();
    _postWeightCtrl.dispose();
    _preBPCtrl.dispose();
    _postBPCtrl.dispose();
    _preHrCtrl.dispose();
    _postHrCtrl.dispose();
    _durationCtrl.dispose();
    _observationsCtrl.dispose();
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
                const Icon(Icons.health_and_safety, size: 20, color: Colors.teal),
                const SizedBox(width: 8),
                const Text(
                  'Suivi de dialyse',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Patient: ${widget.patientName}',
                    style: TextStyle(fontSize: 12, color: Colors.teal.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Type et statut
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonFormField<String>(
                      value: _sessionType,
                      items: _sessionTypes.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(t, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _sessionType = v ?? _sessionType),
                      decoration: InputDecoration(
                        labelText: 'Type de dialyse',
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
            // Date et durée
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: const Text(
                        'Date',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        _sessionDate != null
                            ? '${_sessionDate!.day}/${_sessionDate!.month}/${_sessionDate!.year}'
                            : 'Sélectionner',
                        style: TextStyle(fontSize: 13),
                      ),
                      trailing: const Icon(Icons.calendar_today, size: 18),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _sessionDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => _sessionDate = picked);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: _durationCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Durée (min)',
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
            // Poids
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: _preWeightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Poids pré (kg)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: _postWeightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Poids post (kg)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Différence',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        Text(
                          _getWeightDiff(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // TA et pouls
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: _preBPCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'TA pré (mmHg)',
                        hintText: 'Systolique/Diastolique',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: _postBPCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'TA post (mmHg)',
                        hintText: 'Systolique/Diastolique',
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
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: _preHrCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Pouls pré (bpm)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: _postHrCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Pouls post (bpm)',
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
            // Accès et médicaments
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonFormField<String>(
                      value: _accessType,
                      items: _accessTypes.map((a) {
                        return DropdownMenuItem(
                          value: a,
                          child: Text(a, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _accessType = v ?? _accessType),
                      decoration: InputDecoration(
                        labelText: 'Type d\'accès',
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
                        labelText: 'Statut session',
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
            // Médicaments
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _medicationOptions.map((med) {
                final isSelected = _medications.contains(med);
                return FilterChip(
                  label: Text(
                    med,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _medications.add(med);
                      } else {
                        _medications.remove(med);
                      }
                    });
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: Colors.teal,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // Observations
            TextField(
              controller: _observationsCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Observations',
                hintText: 'Remarques sur la session...',
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
                    onPressed: _saveSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Enregistrer la session',
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
        return 'Planifiée';
      case 'active':
        return 'En cours';
      case 'completed':
        return 'Terminée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  String _getWeightDiff() {
    final pre = double.tryParse(_preWeightCtrl.text);
    final post = double.tryParse(_postWeightCtrl.text);
    if (pre != null && post != null) {
      final diff = pre - post;
      return '${diff.toStringAsFixed(1)} kg';
    }
    return '--';
  }

  void _saveSession() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'sessionType': _sessionType,
        'status': _status,
        'sessionDate': _sessionDate,
        'duration': int.tryParse(_durationCtrl.text),
        'preWeight': double.tryParse(_preWeightCtrl.text),
        'postWeight': double.tryParse(_postWeightCtrl.text),
        'preBP': _preBPCtrl.text,
        'postBP': _postBPCtrl.text,
        'preHR': int.tryParse(_preHrCtrl.text),
        'postHR': int.tryParse(_postHrCtrl.text),
        'accessType': _accessType,
        'medications': _medications,
        'observations': _observationsCtrl.text,
        'patientId': widget.patientId,
        'patientName': widget.patientName,
        'timestamp': DateTime.now(),
      };
      widget.onSessionSaved(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session enregistrée'), backgroundColor: Colors.green),
      );
    }
  }
}
