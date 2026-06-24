// 📁 lib/presentation/admin_hopital/patients/widgets/patient_document_upload.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../common/widgets/admin_gradient_button.dart';
import '../../../common/providers/admin_patient_provider.dart';

class PatientDocumentUpload extends ConsumerStatefulWidget {
  final String patientId;

  const PatientDocumentUpload({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  ConsumerState<PatientDocumentUpload> createState() => _PatientDocumentUploadState();
}

class _PatientDocumentUploadState extends ConsumerState<PatientDocumentUpload> {
  bool _isUploading = false;
  String? _uploadProgress;
  final List<DocumentItem> _documents = [];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  void _loadDocuments() {
    // Simuler le chargement des documents existants (à connecter au vrai repository)
    setState(() {
      _documents.addAll([
        DocumentItem(
          name: 'Ordonnance_2024_01_15.pdf',
          type: 'prescription',
          date: DateTime(2024, 1, 15),
          url: '',
        ),
        DocumentItem(
          name: 'Radio_thorax_2024_01_10.jpg',
          type: 'radio',
          date: DateTime(2024, 1, 10),
          url: '',
        ),
      ]);
    });
  }

  Future<void> _uploadDocument() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 'Upload en cours...';
    });

    try {
      // Simuler l'upload vers Supabase Storage
      // Dans la vraie vie, on utiliserait :
      // final supabase = Supabase.instance.client;
      // final path = 'patients/${widget.patientId}/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      // await supabase.storage.from('documents').upload(path, File(file.path!));

      await Future.delayed(const Duration(seconds: 2));

      final newDoc = DocumentItem(
        name: file.name,
        type: _getDocumentType(file.name),
        date: DateTime.now(),
        url: '',
      );

      if (mounted) {
        setState(() {
          _documents.add(newDoc);
          _isUploading = false;
          _uploadProgress = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document uploadé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'upload: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getDocumentType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    if (['pdf', 'doc', 'docx'].contains(ext)) return 'prescription';
    if (['jpg', 'jpeg', 'png'].contains(ext)) return 'radio';
    return 'other';
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'prescription':
        return Icons.receipt;
      case 'radio':
        return Icons.image;
      default:
        return Icons.description;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'prescription':
        return Colors.blue;
      case 'radio':
        return Colors.purple;
      default:
        return Colors.grey;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.upload_file, size: 20),
              SizedBox(width: 8),
              Text(
                'Documents médicaux',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AdminGradientButton(
            text: _isUploading ? 'Upload en cours...' : 'Ajouter un document',
            onPressed: _isUploading ? null : _uploadDocument,
            icon: Icons.cloud_upload,
            isFullWidth: true,
          ),
          if (_uploadProgress != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: null, // Indéterminé
              backgroundColor: Colors.grey.shade200,
              color: Colors.green,
            ),
            const SizedBox(height: 4),
            Text(
              _uploadProgress!,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 16),
          if (_documents.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aucun document',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            )
          else
            ..._documents.map((doc) => _DocumentItemWidget(doc: doc)),
        ],
      ),
    );
  }
}

class DocumentItem {
  final String name;
  final String type;
  final DateTime date;
  final String url;

  DocumentItem({
    required this.name,
    required this.type,
    required this.date,
    required this.url,
  });
}

class _DocumentItemWidget extends StatelessWidget {
  final DocumentItem doc;

  const _DocumentItemWidget({required this.doc});

  @override
  Widget build(BuildContext context) {
    final isImage = doc.type == 'radio';
    final icon = isImage ? Icons.image : Icons.description;
    final color = isImage ? Colors.purple : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${doc.date.day}/${doc.date.month}/${doc.date.year}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.visibility, size: 18),
            onPressed: () {
              // Ouvrir le document
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, size: 18),
            onPressed: () {
              // Télécharger le document
            },
          ),
        ],
      ),
    );
  }
}
