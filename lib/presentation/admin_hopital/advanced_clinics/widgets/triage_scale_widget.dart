// 📁 lib/presentation/admin_hopital/advanced_clinics/widgets/triage_scale_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TriageLevel {
  immediate('Immédiat', Colors.red, 'Catégorie 1', 'Urgence vitale'),
  veryUrgent('Très urgent', Colors.orange, 'Catégorie 2', 'Urgence sévère'),
  urgent('Urgent', Colors.yellow, 'Catégorie 3', 'Urgence modérée'),
  lessUrgent('Peu urgent', Colors.green, 'Catégorie 4', 'Urgence mineure'),
  nonUrgent('Non urgent', Colors.blue, 'Catégorie 5', 'Soins différés');

  final String label;
  final Color color;
  final String category;
  final String description;

  const TriageLevel(this.label, this.color, this.category, this.description);
}

class TriageScaleWidget extends StatefulWidget {
  final Function(TriageLevel, Map<String, dynamic>) onTriageComplete;
  final String patientName;
  final String? patientId;

  const TriageScaleWidget({
    Key? key,
    required this.onTriageComplete,
    required this.patientName,
    this.patientId,
  }) : super(key: key);

  @override
  State<TriageScaleWidget> createState() => _TriageScaleWidgetState();
}

class _TriageScaleWidgetState extends State<TriageScaleWidget> {
  TriageLevel? _selectedLevel;
  int _glasgowScore = 15;
  double _temperature = 37.0;
  int _heartRate = 80;
  int _respiratoryRate = 16;
  int _systolicBP = 120;
  int _diastolicBP = 80;
  int _painScore = 0;
  String _chiefComplaint = '';
  String _additionalNotes = '';
  bool _isSubmitting = false;

  final List<String> _painScores = List.generate(11, (i) => i.toString());

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
              const Icon(Icons.emergency, size: 20, color: Colors.red),
              const SizedBox(width: 8),
              const Text(
                'Tri des urgences',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Patient: ${widget.patientName}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Échelle de tri CIMU
          const Text(
            'Niveau de tri',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: TriageLevel.values.map((level) {
              final isSelected = _selectedLevel == level;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedLevel = level),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? level.color : level.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? level.color : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: level.color,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (TriageLevel.values.indexOf(level) + 1).toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          level.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : level.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          if (_selectedLevel != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _selectedLevel!.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _selectedLevel!.color.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: _selectedLevel!.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_selectedLevel!.category} - ${_selectedLevel!.description}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _selectedLevel!.color,
                          ),
                        ),
                        Text(
                          'Temps d\'attente maximal: ${_getMaxWaitTime(_selectedLevel!)}',
                          style: TextStyle(fontSize: 11, color: _selectedLevel!.color),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Signes vitaux
          const Text(
            'Signes vitaux',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildVitalInput(
                label: 'Température',
                value: _temperature.toStringAsFixed(1),
                unit: '°C',
                onChanged: (v) => setState(() => _temperature = double.tryParse(v) ?? 37.0),
                min: 34,
                max: 42,
              ),
              const SizedBox(width: 8),
              _buildVitalInput(
                label: 'Pouls',
                value: _heartRate.toString(),
                unit: 'bpm',
                onChanged: (v) => setState(() => _heartRate = int.tryParse(v) ?? 80),
                min: 30,
                max: 220,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildVitalInput(
                label: 'FR',
                value: _respiratoryRate.toString(),
                unit: '/min',
                onChanged: (v) => setState(() => _respiratoryRate = int.tryParse(v) ?? 16),
                min: 4,
                max: 60,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TA',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Sys',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              ),
                              style: const TextStyle(fontSize: 12),
                              onChanged: (v) => setState(() => _systolicBP = int.tryParse(v) ?? 120),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('/', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Dia',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              ),
                              style: const TextStyle(fontSize: 12),
                              onChanged: (v) => setState(() => _diastolicBP = int.tryParse(v) ?? 80),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('mmHg', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Score de Glasgow
          const Text(
            'Score de Glasgow',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildGlasgowItem('Yeux', 4, _glasgowScore >= 10),
              _buildGlasgowItem('Verbal', 5, _glasgowScore >= 10),
              _buildGlasgowItem('Moteur', 6, _glasgowScore >= 10),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _getGlasgowColor(_glasgowScore),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '$_glasgowScore / 15',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getGlasgowTextColor(_glasgowScore),
                      ),
                    ),
                    Text(
                      _getGlasgowLabel(_glasgowScore),
                      style: TextStyle(
                        fontSize: 10,
                        color: _getGlasgowTextColor(_glasgowScore),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Douleur
          Row(
            children: [
              const Text(
                'Douleur:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              ..._painScores.map((score) {
                final isSelected = _painScore == int.parse(score);
                return GestureDetector(
                  onTap: () => setState(() => _painScore = int.parse(score)),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      score,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white : Colors.grey,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(width: 8),
              Text(
                _getPainLabel(_painScore),
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Motif
          TextField(
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Motif principal',
              hintText: 'Douleur thoracique, traumatisme...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(10),
            ),
            style: const TextStyle(fontSize: 13),
            onChanged: (v) => _chiefComplaint = v,
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Notes supplémentaires',
              hintText: 'Observations...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(10),
            ),
            style: const TextStyle(fontSize: 13),
            onChanged: (v) => _additionalNotes = v,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting || _selectedLevel == null ? null : _submitTriage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedLevel?.color ?? Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Valider le tri',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalInput({
    required String label,
    required String value,
    required String unit,
    required Function(String) onChanged,
    required double min,
    required double max,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 2),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: value,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              suffixText: unit,
            ),
            style: const TextStyle(fontSize: 12),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildGlasgowItem(String label, int max, bool selected) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: selected ? Colors.black : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            decoration: BoxDecoration(
              color: selected ? Colors.green.shade100 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$max',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.green : Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGlasgowColor(int score) {
    if (score >= 13) return Colors.green.shade100;
    if (score >= 9) return Colors.orange.shade100;
    return Colors.red.shade100;
  }

  Color _getGlasgowTextColor(int score) {
    if (score >= 13) return Colors.green;
    if (score >= 9) return Colors.orange;
    return Colors.red;
  }

  String _getGlasgowLabel(int score) {
    if (score >= 13) return 'Léger';
    if (score >= 9) return 'Modéré';
    return 'Sévère';
  }

  String _getPainLabel(int score) {
    if (score == 0) return 'Pas de douleur';
    if (score <= 3) return 'Légère';
    if (score <= 6) return 'Modérée';
    if (score <= 8) return 'Sévère';
    return 'Maximale';
  }

  String _getMaxWaitTime(TriageLevel level) {
    switch (level) {
      case TriageLevel.immediate:
        return '0-5 min';
      case TriageLevel.veryUrgent:
        return '5-15 min';
      case TriageLevel.urgent:
        return '15-30 min';
      case TriageLevel.lessUrgent:
        return '30-60 min';
      case TriageLevel.nonUrgent:
        return '60+ min';
    }
  }

  void _submitTriage() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    final data = {
      'triageLevel': _selectedLevel!.label,
      'category': _selectedLevel!.category,
      'glasgowScore': _glasgowScore,
      'temperature': _temperature,
      'heartRate': _heartRate,
      'respiratoryRate': _respiratoryRate,
      'systolicBP': _systolicBP,
      'diastolicBP': _diastolicBP,
      'painScore': _painScore,
      'chiefComplaint': _chiefComplaint,
      'additionalNotes': _additionalNotes,
      'timestamp': DateTime.now(),
    };
    widget.onTriageComplete(_selectedLevel!, data);
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tri effectué: ${_selectedLevel!.label}'),
        backgroundColor: _selectedLevel!.color,
      ),
    );
  }
}
