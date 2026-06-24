// 📁 lib/presentation/admin_hopital/interoperability/widgets/hl7_import_widget.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class HL7ImportWidget extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onImport;
  final Function(List<Map<String, dynamic>>)? onBatchImport;

  const HL7ImportWidget({
    Key? key,
    required this.onImport,
    this.onBatchImport,
  }) : super(key: key);

  @override
  ConsumerState<HL7ImportWidget> createState() => _HL7ImportWidgetState();
}

class _HL7ImportWidgetState extends ConsumerState<HL7ImportWidget> {
  bool _isLoading = false;
  String _status = '';
  List<Map<String, dynamic>> _parsedMessages = [];
  String _selectedFormat = 'HL7 v2';
  String _selectedSource = 'Laboratoire';
  double _progress = 0.0;
  bool _autoMap = true;

  final List<String> _formats = ['HL7 v2', 'HL7 v3', 'FHIR R4', 'CSV', 'XML'];
  final List<String> _sources = ['Laboratoire', 'Radiologie', 'Cardiologie', 'Autre'];

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
              const Icon(Icons.medical_services, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Importation HL7 / FHIR',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _status.contains('Succès')
                      ? Colors.green.shade50
                      : (_status.isNotEmpty ? Colors.orange.shade50 : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _status.isNotEmpty ? _status : 'Prêt',
                  style: TextStyle(
                    fontSize: 11,
                    color: _status.contains('Succès')
                        ? Colors.green.shade700
                        : (_status.isNotEmpty ? Colors.orange.shade700 : Colors.grey.shade600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Configuration
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButtonFormField<String>(
                    value: _selectedFormat,
                    items: _formats.map((f) {
                      return DropdownMenuItem(
                        value: f,
                        child: Text(f, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedFormat = v ?? _selectedFormat),
                    decoration: InputDecoration(
                      labelText: 'Format',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButtonFormField<String>(
                    value: _selectedSource,
                    items: _sources.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedSource = v ?? _selectedSource),
                    decoration: InputDecoration(
                      labelText: 'Source',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Checkbox(
                      value: _autoMap,
                      onChanged: (v) => setState(() => _autoMap = v ?? true),
                      activeColor: Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Mappage automatique',
                      style: TextStyle(
                        fontSize: 12,
                        color: _autoMap ? Colors.blue : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Boutons d'import
          Row(
            children: [
              Expanded(
                child: AdminGradientButton(
                  text: _isLoading ? 'Importation...' : 'Importer un fichier',
                  onPressed: _isLoading ? null : _importFile,
                  icon: Icons.upload_file,
                  gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AdminGradientButton(
                  text: 'Exemple HL7',
                  onPressed: _isLoading ? null : _loadExample,
                  icon: Icons.preview,
                  gradient: const LinearGradient(colors: [Colors.purple, Colors.purpleAccent]),
                ),
              ),
            ],
          ),

          if (_isLoading) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.shade200,
              color: Colors.blue,
            ),
            const SizedBox(height: 4),
            Text(
              '${(_progress * 100).toInt()}%',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],

          if (_parsedMessages.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Messages extraits',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_parsedMessages.length} éléments',
                    style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                  ),
                ),
                const SizedBox(width: 8),
                AdminGradientButton(
                  text: 'Importer tout',
                  onPressed: () {
                    if (widget.onBatchImport != null) {
                      widget.onBatchImport!(_parsedMessages);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Import terminé'), backgroundColor: Colors.green),
                    );
                    setState(() => _parsedMessages = []);
                  },
                  height: 34,
                  width: 120,
                  gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _parsedMessages.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final msg = _parsedMessages[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.message, size: 16, color: Colors.blue),
                    title: Text(
                      msg['patientName'] ?? 'Patient inconnu',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${msg['examType'] ?? 'Examen'} • ${msg['date'] ?? 'Date inconnue'}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.check_circle, size: 18, color: Colors.green),
                      onPressed: () {
                        widget.onImport(msg);
                        setState(() {
                          _parsedMessages.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Importé avec succès'), backgroundColor: Colors.green),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _importFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['hl7', 'fhir', 'xml', 'csv', 'json'],
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      _isLoading = true;
      _progress = 0.0;
      _status = 'Analyse du fichier...';
    });

    try {
      // Simuler le parsing
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _progress = 0.5);
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _progress = 1.0);

      final sampleMessages = [
        {
          'patientName': 'Michel Dupont',
          'patientId': 'P001',
          'examType': 'Bilan sanguin',
          'date': '18/12/2024',
          'results': {'Hemoglobine': '14.2 g/dL', 'GB': '7.5 K/µL'},
        },
        {
          'patientName': 'Sophie Martin',
          'patientId': 'P002',
          'examType': 'Radio thoracique',
          'date': '18/12/2024',
          'results': {'Aspect': 'Normal'},
        },
      ];

      setState(() {
        _parsedMessages = sampleMessages;
        _status = '✅ Import réussi (${sampleMessages.length} messages)';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Erreur: $e';
        _isLoading = false;
      });
    }
  }

  void _loadExample() {
    setState(() {
      _parsedMessages = [
        {
          'patientName': 'Lucas Bernard',
          'patientId': 'P003',
          'examType': 'IRM cérébrale',
          'date': '19/12/2024',
          'results': {'Conclusion': 'Lésion suspecte au niveau temporal'},
        },
        {
          'patientName': 'Julie Petit',
          'patientId': 'P004',
          'examType': 'Échocardiographie',
          'date': '19/12/2024',
          'results': {'FE': '65%', 'Aspect': 'Globalement normal'},
        },
      ];
      _status = '✅ Exemple chargé (2 messages)';
    });
  }
}
