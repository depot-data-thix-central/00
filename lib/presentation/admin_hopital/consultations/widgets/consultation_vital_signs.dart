// 📁 lib/presentation/admin_hopital/consultations/widgets/consultation_vital_signs.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_form_field.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class VitalSignsData {
  final double? temperature;
  final int? systolic;
  final int? diastolic;
  final int? heartRate;
  final int? respiratoryRate;
  final double? weight;
  final double? height;
  final double? spo2;
  final String? painScore;

  VitalSignsData({
    this.temperature,
    this.systolic,
    this.diastolic,
    this.heartRate,
    this.respiratoryRate,
    this.weight,
    this.height,
    this.spo2,
    this.painScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'systolic': systolic,
      'diastolic': diastolic,
      'heartRate': heartRate,
      'respiratoryRate': respiratoryRate,
      'weight': weight,
      'height': height,
      'spo2': spo2,
      'painScore': painScore,
    };
  }
}

class ConsultationVitalSigns extends StatefulWidget {
  final Function(VitalSignsData) onSave;
  final VitalSignsData? initialData;

  const ConsultationVitalSigns({
    Key? key,
    required this.onSave,
    this.initialData,
  }) : super(key: key);

  @override
  State<ConsultationVitalSigns> createState() => _ConsultationVitalSignsState();
}

class _ConsultationVitalSignsState extends State<ConsultationVitalSigns> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _temperatureCtrl = TextEditingController();
  final _systolicCtrl = TextEditingController();
  final _diastolicCtrl = TextEditingController();
  final _heartRateCtrl = TextEditingController();
  final _respiratoryCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _spo2Ctrl = TextEditingController();
  String _painScore = '0';

  final List<String> _painScores = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _temperatureCtrl.text = widget.initialData!.temperature?.toString() ?? '';
      _systolicCtrl.text = widget.initialData!.systolic?.toString() ?? '';
      _diastolicCtrl.text = widget.initialData!.diastolic?.toString() ?? '';
      _heartRateCtrl.text = widget.initialData!.heartRate?.toString() ?? '';
      _respiratoryCtrl.text = widget.initialData!.respiratoryRate?.toString() ?? '';
      _weightCtrl.text = widget.initialData!.weight?.toString() ?? '';
      _heightCtrl.text = widget.initialData!.height?.toString() ?? '';
      _spo2Ctrl.text = widget.initialData!.spo2?.toString() ?? '';
      _painScore = widget.initialData!.painScore ?? '0';
    }
  }

  @override
  void dispose() {
    _temperatureCtrl.dispose();
    _systolicCtrl.dispose();
    _diastolicCtrl.dispose();
    _heartRateCtrl.dispose();
    _respiratoryCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _spo2Ctrl.dispose();
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
                const Icon(Icons.monitor_heart, size: 20, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Signes vitaux',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AdminFormField(
                    label: 'Température (°C)',
                    controller: _temperatureCtrl,
                    keyboardType: TextInputType.number,
                    hint: '37.0',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminFormField(
                    label: 'Pouls (bpm)',
                    controller: _heartRateCtrl,
                    keyboardType: TextInputType.number,
                    hint: '72',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AdminFormField(
                    label: 'Systolique (mmHg)',
                    controller: _systolicCtrl,
                    keyboardType: TextInputType.number,
                    hint: '120',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminFormField(
                    label: 'Diastolique (mmHg)',
                    controller: _diastolicCtrl,
                    keyboardType: TextInputType.number,
                    hint: '80',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AdminFormField(
                    label: 'Fréquence respiratoire',
                    controller: _respiratoryCtrl,
                    keyboardType: TextInputType.number,
                    hint: '16',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminFormField(
                    label: 'SpO2 (%)',
                    controller: _spo2Ctrl,
                    keyboardType: TextInputType.number,
                    hint: '98',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AdminFormField(
                    label: 'Poids (kg)',
                    controller: _weightCtrl,
                    keyboardType: TextInputType.number,
                    hint: '72.5',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminFormField(
                    label: 'Taille (cm)',
                    controller: _heightCtrl,
                    keyboardType: TextInputType.number,
                    hint: '175',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _painScore,
                    items: _painScores.map((score) {
                      return DropdownMenuItem(
                        value: score,
                        child: Text('$score/10', style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _painScore = v ?? '0'),
                    decoration: InputDecoration(
                      labelText: 'Score de douleur',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _getPainLabel(int.parse(_painScore)),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AdminGradientButton(
              text: 'Enregistrer les signes vitaux',
              onPressed: _saveVitalSigns,
              icon: Icons.save,
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  String _getPainLabel(int score) {
    if (score == 0) return 'Pas de douleur';
    if (score <= 3) return 'Douleur légère';
    if (score <= 6) return 'Douleur modérée';
    if (score <= 8) return 'Douleur sévère';
    return 'Douleur maximale';
  }

  void _saveVitalSigns() {
    if (!_formKey.currentState!.validate()) return;

    final data = VitalSignsData(
      temperature: double.tryParse(_temperatureCtrl.text),
      systolic: int.tryParse(_systolicCtrl.text),
      diastolic: int.tryParse(_diastolicCtrl.text),
      heartRate: int.tryParse(_heartRateCtrl.text),
      respiratoryRate: int.tryParse(_respiratoryCtrl.text),
      weight: double.tryParse(_weightCtrl.text),
      height: double.tryParse(_heightCtrl.text),
      spo2: double.tryParse(_spo2Ctrl.text),
      painScore: _painScore,
    );

    widget.onSave(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signes vitaux enregistrés'), backgroundColor: Colors.green),
    );
  }
}
