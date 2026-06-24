// 📁 lib/presentation/admin_hopital/consultations/widgets/consultation_note_editor.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_form_field.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class ConsultationNoteEditor extends StatefulWidget {
  final Function(String, String, String) onSave; // motif, diagnostic, traitement
  final String? initialMotif;
  final String? initialDiagnostic;
  final String? initialTreatment;
  final bool isEditable;

  const ConsultationNoteEditor({
    Key? key,
    required this.onSave,
    this.initialMotif,
    this.initialDiagnostic,
    this.initialTreatment,
    this.isEditable = true,
  }) : super(key: key);

  @override
  State<ConsultationNoteEditor> createState() => _ConsultationNoteEditorState();
}

class _ConsultationNoteEditorState extends State<ConsultationNoteEditor> {
  final _motifCtrl = TextEditingController();
  final _diagnosticCtrl = TextEditingController();
  final _treatmentCtrl = TextEditingController();
  final List<String> _diagnosticCodes = [];
  String _selectedDiagnosticCode = '';

  @override
  void initState() {
    super.initState();
    _motifCtrl.text = widget.initialMotif ?? '';
    _diagnosticCtrl.text = widget.initialDiagnostic ?? '';
    _treatmentCtrl.text = widget.initialTreatment ?? '';
    // Simuler des codes CIM-10
    _diagnosticCodes.addAll(['J06.9', 'I10', 'E11.9', 'N39.0', 'R51']);
  }

  @override
  void dispose() {
    _motifCtrl.dispose();
    _diagnosticCtrl.dispose();
    _treatmentCtrl.dispose();
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.note_add, size: 20, color: Colors.teal),
              const SizedBox(width: 8),
              const Text(
                'Compte rendu de consultation',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AdminFormField(
            label: 'Motif de la consultation *',
            controller: _motifCtrl,
            hint: 'Douleur thoracique, fièvre, etc.',
            maxLines: 2,
            enabled: widget.isEditable,
            validator: (v) => v?.isEmpty == true ? 'Motif requis' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: AdminFormField(
                  label: 'Diagnostic (CIM-10) *',
                  controller: _diagnosticCtrl,
                  hint: 'J06.9 - Infection respiratoire',
                  enabled: widget.isEditable,
                  validator: (v) => v?.isEmpty == true ? 'Diagnostic requis' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDiagnosticCode.isNotEmpty ? _selectedDiagnosticCode : null,
                  items: _diagnosticCodes.map((code) {
                    return DropdownMenuItem(
                      value: code,
                      child: Text(code, style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _selectedDiagnosticCode = v;
                        if (_diagnosticCtrl.text.isEmpty) {
                          _diagnosticCtrl.text = v;
                        }
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Code CIM-10',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AdminFormField(
            label: 'Traitement / Recommandations',
            controller: _treatmentCtrl,
            hint: 'Médicaments, repos, suivi...',
            maxLines: 3,
            enabled: widget.isEditable,
          ),
          const SizedBox(height: 16),
          if (widget.isEditable)
            AdminGradientButton(
              text: 'Enregistrer le compte rendu',
              onPressed: _saveNote,
              icon: Icons.save,
              height: 40,
            ),
        ],
      ),
    );
  }

  void _saveNote() {
    if (_motifCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir le motif'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_diagnosticCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir le diagnostic'), backgroundColor: Colors.orange),
      );
      return;
    }

    widget.onSave(
      _motifCtrl.text,
      _diagnosticCtrl.text,
      _treatmentCtrl.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compte rendu enregistré'), backgroundColor: Colors.green),
    );
  }
}
