// 📁 lib/presentation/admin_hopital/advanced_clinics/widgets/pregnancy_followup_chart.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PregnancyFollowupChart extends StatefulWidget {
  final String patientId;
  final String patientName;
  final Function(Map<String, dynamic>) onUpdate;

  const PregnancyFollowupChart({
    Key? key,
    required this.patientId,
    required this.patientName,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<PregnancyFollowupChart> createState() => _PregnancyFollowupChartState();
}

class _PregnancyFollowupChartState extends State<PregnancyFollowupChart> {
  int _currentWeek = 8;
  int _weight = 62;
  String _bloodType = 'A+';
  String _rhFactor = '+';
  bool _isDiabetic = false;
  bool _isHypertensive = false;
  bool _isMultiple = false;
  String _presentation = 'Céphalique';
  String _fetalHeartRate = '140';
  String _comments = '';

  final List<String> _bloodTypes = ['A', 'B', 'AB', 'O'];
  final List<String> _rhFactors = ['+', '-'];
  final List<String> _presentations = ['Céphalique', 'Siège', 'Transverse', 'Incertaine'];

  // Données de suivi par semaine
  final Map<int, Map<String, dynamic>> _weeklyData = {
    8: {'size': '1.6 cm', 'weight': '1 g', 'development': 'Embryon en développement'},
    12: {'size': '5.4 cm', 'weight': '14 g', 'development': 'Membres formés'},
    16: {'size': '11.6 cm', 'weight': '100 g', 'development': 'Mouvements perceptibles'},
    20: {'size': '16.5 cm', 'weight': '300 g', 'development': 'Battements cardiaques audibles'},
    24: {'size': '21.0 cm', 'weight': '600 g', 'development': 'Réaction aux sons'},
    28: {'size': '25.0 cm', 'weight': '1000 g', 'development': 'Ouvrent les yeux'},
    32: {'size': '29.0 cm', 'weight': '1700 g', 'development': 'Prise de poids rapide'},
    36: {'size': '33.0 cm', 'weight': '2600 g', 'development': 'Position finale'},
    40: {'size': '35.0 cm', 'weight': '3400 g', 'development': 'Prêt pour la naissance'},
  };

  @override
  Widget build(BuildContext context) {
    final weekData = _weeklyData[_currentWeek] ?? {};
    final String? fetalSize = weekData['size'];
    final String? fetalWeight = weekData['weight'];
    final String? development = weekData['development'];

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
              const Icon(Icons.pregnant_woman, size: 20, color: Colors.pink),
              const SizedBox(width: 8),
              const Text(
                'Suivi de grossesse',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.patientName,
                  style: TextStyle(fontSize: 12, color: Colors.pink.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Semaine courante
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Semaine actuelle',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 24),
                            onPressed: () => setState(() {
                              if (_currentWeek > 4) _currentWeek--;
                            }),
                            color: Colors.pink,
                          ),
                          Text(
                            'SA$_currentWeek',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, size: 24),
                            onPressed: () => setState(() {
                              if (_currentWeek < 42) _currentWeek++;
                            }),
                            color: Colors.pink,
                          ),
                        ],
                      ),
                      Text(
                        'Date estimée: ${_getEstimatedDueDate()}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Informations fœtales
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Taille',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        fetalSize ?? '--',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Poids',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        fetalWeight ?? '--',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'FC fœtale',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        '$_fetalHeartRate bpm',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Développement
          if (development != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.child_care, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Développement: $development',
                      style: TextStyle(fontSize: 13, color: Colors.blue.shade800),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          // Paramètres de la mère
          const Text(
            'Paramètres maternels',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Poids (kg)',
                      hintText: _weight.toString(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 13),
                    onChanged: (v) => setState(() => _weight = int.tryParse(v) ?? _weight),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _bloodType,
                          items: _bloodTypes.map((b) {
                            return DropdownMenuItem(
                              value: b,
                              child: Text(b, style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _bloodType = v ?? _bloodType),
                          decoration: InputDecoration(
                            labelText: 'Groupe',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _rhFactor,
                          items: _rhFactors.map((r) {
                            return DropdownMenuItem(
                              value: r,
                              child: Text(r, style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _rhFactor = v ?? _rhFactor),
                          decoration: InputDecoration(
                            labelText: 'Rh',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    ],
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
                  child: Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          value: _isDiabetic,
                          onChanged: (v) => setState(() => _isDiabetic = v ?? false),
                          title: const Text('Diabète', style: TextStyle(fontSize: 12)),
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          value: _isHypertensive,
                          onChanged: (v) => setState(() => _isHypertensive = v ?? false),
                          title: const Text('HTA', style: TextStyle(fontSize: 12)),
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
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
                  child: CheckboxListTile(
                    value: _isMultiple,
                    onChanged: (v) => setState(() => _isMultiple = v ?? false),
                    title: const Text('Grossesse multiple', style: TextStyle(fontSize: 12)),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButtonFormField<String>(
                    value: _presentation,
                    items: _presentations.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(p, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _presentation = v ?? _presentation),
                    decoration: InputDecoration(
                      labelText: 'Présentation',
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
          // Commentaires
          TextField(
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Commentaires / Observ
