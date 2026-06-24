// 📁 lib/presentation/admin_hopital/security/widgets/consent_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_form_field.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class ConsentForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback? onCancel;
  final String patientName;
  final String consentType;

  const ConsentForm({
    Key? key,
    required this.onSave,
    required this.patientName,
    required this.consentType,
    this.onCancel,
  }) : super(key: key);

  @override
  State<ConsentForm> createState() => _ConsentFormState();
}

class _ConsentFormState extends State<ConsentForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isAgreed = false;
  bool _isDataProcessingAccepted = false;
  bool _isDataSharingAccepted = false;
  bool _isThirdPartyAccepted = false;
  String _consentDuration = '1 an';
  final TextEditingController _notesCtrl = TextEditingController();

  final List<String> _durations = ['1 an', '2 ans', '5 ans', 'Indéterminé'];

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
                const Icon(Icons.assignment, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Formulaire de consentement',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.consentType,
                    style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Patient: ${widget.patientName}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Veuillez lire et accepter les conditions suivantes :',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            _buildCheckboxTile(
              title: 'J\'accepte le traitement de mes données médicales',
              subtitle: 'Les données seront utilisées pour le suivi médical et la recherche.',
              value: _isDataProcessingAccepted,
              onChanged: (v) => setState(() => _isDataProcessingAccepted = v),
            ),
            _buildCheckboxTile(
              title: 'J\'accepte le partage de mes données avec mon médecin traitant',
              subtitle: 'Seuls les professionnels habilités auront accès à votre dossier.',
              value: _isDataSharingAccepted,
              onChanged: (v) => setState(() => _isDataSharingAccepted = v),
            ),
            _buildCheckboxTile(
              title: 'J\'accepte le transfert à des tiers (laboratoires, imagerie)',
              subtitle: 'Uniquement pour la réalisation des examens prescrits.',
              value: _isThirdPartyAccepted,
              onChanged: (v) => setState(() => _isThirdPartyAccepted = v),
            ),
            const SizedBox(height: 12),
            AdminDropdown<String>(
              label: 'Durée du consentement',
              value: _consentDuration,
              items: _durations.map((d) {
                return DropdownMenuItem(
                  value: d,
                  child: Text(d, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (v) => setState(() => _consentDuration = v ?? _consentDuration),
            ),
            const SizedBox(height: 12),
            AdminFormField(
              label: 'Notes (optionnel)',
              controller: _notesCtrl,
              hint: 'Observations supplémentaires...',
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _isAgreed,
                    onChanged: (v) => setState(() => _isAgreed = v ?? false),
                    activeColor: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Je confirme avoir lu et accepté l\'ensemble des conditions ci-dessus.',
                      style: TextStyle(
                        fontSize: 13,
                        color: _isAgreed ? Colors.green : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AdminGradientButton(
                    text: 'Enregistrer le consentement',
                    onPressed: _isAgreed ? _saveConsent : null,
                    icon: Icons.save,
                    gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
                  ),
                ),
                if (widget.onCancel != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Annuler', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: value ? Colors.green.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value ? Colors.green.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: Colors.green,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                    color: value ? Colors.green.shade700 : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveConsent() {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'patientName': widget.patientName,
      'consentType': widget.consentType,
      'isDataProcessingAccepted': _isDataProcessingAccepted,
      'isDataSharingAccepted': _isDataSharingAccepted,
      'isThirdPartyAccepted': _isThirdPartyAccepted,
      'duration': _consentDuration,
      'notes': _notesCtrl.text,
      'timestamp': DateTime.now(),
      'status': 'active',
    };
    widget.onSave(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Consentement enregistré'), backgroundColor: Colors.green),
    );
  }
}
