// 📁 lib/presentation/admin_hopital/surgery/widgets/surgery_postop_report.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_form_field.dart';
import '../../../common/widgets/admin_dropdown.dart';
import '../../../common/widgets/admin_gradient_button.dart';
import '../../../common/widgets/admin_date_picker.dart';
import '../../../common/widgets/admin_status_badge.dart';

class SurgeryPostopReport extends StatefulWidget {
  final String patientName;
  final String surgeryType;
  final String surgeon;
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const SurgeryPostopReport({
    Key? key,
    required this.patientName,
    required this.surgeryType,
    required this.surgeon,
    required this.onSave,
    this.initialData,
  }) : super(key: key);

  @override
  State<SurgeryPostopReport> createState() => _SurgeryPostopReportState();
}

class _SurgeryPostopReportState extends State<SurgeryPostopReport> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _procedureCtrl = TextEditingController();
  final _findingsCtrl = TextEditingController();
  final _complicationsCtrl = TextEditingController();
  final _medicationsCtrl = TextEditingController();
  final _followUpCtrl = TextEditingController();

  // Valeurs
  String _outcome = 'success';
  DateTime? _surgeryDate;
  bool _hasComplications = false;
  String _recoveryStatus = 'stable';

  final List<String> _outcomes = ['success', 'partial', 'failure'];
  final List<String> _recoveryStatuses = ['stable', 'monitoring', 'critical', 'transferred'];

  @override
  void initState() {
    super.initState();
    _surgeryDate = DateTime.now();
    if (widget.initialData != null) {
      _procedureCtrl.text = widget.initialData!['procedure'] ?? '';
      _findingsCtrl.text = widget.initialData!['findings'] ?? '';
      _complicationsCtrl.text = widget.initialData!['complications'] ?? '';
      _medicationsCtrl.text = widget.initialData!['medications'] ?? '';
      _followUpCtrl.text = widget.initialData!['followUp'] ?? '';
      _outcome = widget.initialData!['outcome'] ?? 'success';
      _hasComplications = widget.initialData!['hasComplications'] ?? false;
      _recoveryStatus = widget.initialData!['recoveryStatus'] ?? 'stable';
      _surgeryDate = widget.initialData!['surgeryDate'];
    }
  }

  @override
  void dispose() {
    _procedureCtrl.dispose();
    _findingsCtrl.dispose();
    _complicationsCtrl.dispose();
    _medicationsCtrl.dispose();
    _followUpCtrl.dispose();
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
                const Icon(Icons.medical_information, size: 20, color: Colors.teal),
                const SizedBox(width: 8),
                const Text(
                  'Compte rendu post-opératoire',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                AdminStatusBadge(
                  status: _outcome == 'success' ? StatusType.completed : (_outcome == 'partial' ? StatusType.warning : StatusType.cancelled),
                  customLabel: _getOutcomeLabel(_outcome),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Procédure réalisée
            AdminFormField(
              label: 'Procédure réalisée *',
              controller: _procedureCtrl,
              hint: 'Décrire l\'intervention...',
              maxLines: 2,
              validator: (v) => v?.isEmpty == true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),

            // Date
            AdminDatePicker(
              label: 'Date de l\'intervention',
              selectedDate: _surgeryDate,
              onDateSelected: (date) => setState(() => _surgeryDate = date),
            ),
            const SizedBox(height: 12),

            // Résultat et statut
            Row(
              children: [
                Expanded(
                  child: AdminDropdown<String>(
                    label: 'Résultat *',
                    value: _outcome,
                    items: _outcomes.map((o) {
                      return DropdownMenuItem(
                        value: o,
                        child: Text(_getOutcomeLabel(o), style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _outcome = v ?? _outcome),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminDropdown<String>(
                    label: 'Statut post-op',
                    value: _recoveryStatus,
                    items: _recoveryStatuses.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(_getRecoveryLabel(s), style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _recoveryStatus = v ?? _recoveryStatus),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Constatations
            AdminFormField(
              label: 'Constatations per-opératoires',
              controller: _findingsCtrl,
              hint: 'Observations pendant l\'intervention...',
              maxLines: 3,
            ),
            const SizedBox(height: 12),

            // Complications
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _hasComplications,
                          onChanged: (v) => setState(() => _hasComplications = v ?? false),
                          activeColor: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Complications',
                          style: TextStyle(
                            fontSize: 13,
                            color: _hasComplications ? Colors.red : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AdminFormField(
                    label: 'Détails complications',
                    controller: _complicationsCtrl,
                    hint: _hasComplications ? 'Décrire les complications...' : 'Aucune complication',
                    enabled: _hasComplications,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Médicaments post-op
            AdminFormField(
              label: 'Médicaments post-opératoires',
              controller: _medicationsCtrl,
              hint: 'Liste des médicaments prescrits...',
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            // Suivi
            AdminFormField(
              label: 'Plan de suivi',
              controller: _followUpCtrl,
              hint: 'Recommandations pour le suivi...',
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            AdminGradientButton(
              text: 'Enregistrer le compte rendu',
              onPressed: _saveReport,
              icon: Icons.save,
              gradient: const LinearGradient(colors: [Colors.teal, Colors.tealAccent]),
            ),
          ],
        ),
      ),
    );
  }

  String _getOutcomeLabel(String outcome) {
    switch (outcome) {
      case 'success':
        return 'Succès';
      case 'partial':
        return 'Partiel';
      case 'failure':
        return 'Échec';
      default:
        return outcome;
    }
  }

  String _getRecoveryLabel(String status) {
    switch (status) {
      case 'stable':
        return 'Stable';
      case 'monitoring':
        return 'Surveillance';
      case 'critical':
        return 'Critique';
      case 'transferred':
        return 'Transféré';
      default:
        return status;
    }
  }

  void _saveReport() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'procedure': _procedureCtrl.text,
      'surgeryDate': _surgeryDate!,
      'outcome': _outcome,
      'recoveryStatus': _recoveryStatus,
      'findings': _findingsCtrl.text,
      'hasComplications': _hasComplications,
      'complications': _complicationsCtrl.text,
      'medications': _medicationsCtrl.text,
      'followUp': _followUpCtrl.text,
      'patientName': widget.patientName,
      'surgeryType': widget.surgeryType,
      'surgeon': widget.surgeon,
      'date': DateTime.now(),
    };

    widget.onSave(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compte rendu enregistré'), backgroundColor: Colors.green),
    );
  }
}
