// 📁 lib/presentation/admin_hopital/advanced_clinics/widgets/rehabilitation_session_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RehabilitationSessionCard extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String therapistName;
  final Function(Map<String, dynamic>) onSessionSaved;

  const RehabilitationSessionCard({
    Key? key,
    required this.patientId,
    required this.patientName,
    required this.therapistName,
    required this.onSessionSaved,
  }) : super(key: key);

  @override
  State<RehabilitationSessionCard> createState() => _RehabilitationSessionCardState();
}

class _RehabilitationSessionCardState extends State<RehabilitationSessionCard> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _durationCtrl = TextEditingController();
  final _observationsCtrl = TextEditingController();

  // Valeurs
  String _sessionType = 'Kinésithérapie';
  String _intensity = 'Modérée';
  String _status = 'planned';
  DateTime? _sessionDate;
  List<String> _exercises = [];
  List<String> _goalsAchieved = [];

  final List<String> _sessionTypes = ['Kinésithérapie', 'Ergothérapie', 'Orthophonie', 'Psychomotricité'];
  final List<String> _intensities = ['Légère', 'Modérée', 'Intense', 'Maximale'];
  final List<String> _statuses = ['planned', 'active', 'completed', 'cancelled'];
  final List<String> _exerciseOptions = [
    'Mobilisation passive',
    'Mobilisation active',
    'Renforcement musculaire',
    'Stretching',
    'Exercices proprioceptifs',
    'Coordination',
    'Équilibre',
    'Marche',
    'Escalier',
    'Transferts'
  ];
  final List<String> _goalOptions = [
    'Amélioration mobilité',
    'Augmentation force',
    'Réduction douleur',
    'Amélioration équilibre',
    'Indépendance fonctionnelle',
    'Correction posture'
  ];

  @override
  void initState() {
    super.initState();
    _sessionDate = DateTime.now();
  }

  @override
  void dispose() {
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
                const Icon(Icons.fitness_center, size: 20, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Session de rééducation',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Kiné: ${widget.therapistName}',
                    style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Type et intensité
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
                        labelText: 'Type de session',
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
                      value: _intensity,
                      items: _intensities.map((i) {
                        return DropdownMenuItem(
                          value: i,
                          child: Text(i, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _intensity = v ?? _intensity),
                      decoration: InputDecoration(
                        labelText: 'Intensité',
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
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
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
            // Exercices
            const Text(
              'Exercices réalisés',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _exerciseOptions.map((ex) {
                final isSelected = _exercises.contains(ex);
                return FilterChip(
                  label: Text(
                    ex,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _exercises.add(ex);
                      } else {
                        _exercises.remove(ex);
                      }
                    });
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: Colors.orange,
                );
              }).toList(),
            ),
            if (_exercises.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Sélectionnez au moins un exercice',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 12),
            // Objectifs atteints
            const Text(
              'Objectifs atteints',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _goalOptions.map((goal) {
                final isSelected = _goalsAchieved.contains(goal);
                return FilterChip(
                  label: Text(
                    goal,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _goalsAchieved.add(goal);
                      } else {
                        _goalsAchieved.remove(goal);
                      }
                    });
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: Colors.green,
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
                hintText: 'Progression, difficultés...',
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
                    onPressed: _exercises.isEmpty ? null : _saveSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
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

  void _saveSession() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'sessionType': _sessionType,
        'intensity': _intensity,
        'sessionDate': _sessionDate,
        'duration': int.tryParse(_durationCtrl.text),
        'exercises': _exercises,
        'goalsAchieved': _goalsAchieved,
        'observations': _observationsCtrl.text,
        'therapistName': widget.therapistName,
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
