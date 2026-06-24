// 📁 lib/presentation/admin_hopital/security/screens/signature_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/signature_pad.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';

class SignatureScreen extends ConsumerStatefulWidget {
  final String? documentId;
  final String? documentTitle;

  const SignatureScreen({Key? key, this.documentId, this.documentTitle}) : super(key: key);

  @override
  ConsumerState<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends ConsumerState<SignatureScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _signedDocuments = [];
  Uint8List? _lastSignature;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  void _loadDocuments() {
    setState(() {
      _signedDocuments = [
        {'id': '1', 'title': 'Consentement - Michel Dupont', 'date': DateTime.now().subtract(const Duration(days: 1)), 'signer': 'Dr. Martin'},
        {'id': '2', 'title': 'Autorisation de soins - Sophie Martin', 'date': DateTime.now().subtract(const Duration(days: 3)), 'signer': 'Dr. Bernard'},
      ];
    });
  }

  void _showSignatureDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: 500,
          child: SignaturePad(
            documentTitle: widget.documentTitle ?? 'Document à signer',
            signerName: 'Dr. Martin',
            onSignatureSaved: (signature) {
              setState(() {
                _lastSignature = signature;
                _signedDocuments.add({
                  'id': '${DateTime.now().millisecondsSinceEpoch}',
                  'title': widget.documentTitle ?? 'Document signé',
                  'date': DateTime.now(),
                  'signer': 'Dr. Martin',
                });
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document signé avec succès'), backgroundColor: Colors.green),
              );
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature électronique'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showSignatureDialog,
            tooltip: 'Signer un document',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocuments,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Chargement...',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Dernière signature
              if (_lastSignature != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dernière signature enregistrée',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green),
                            ),
                            Text(
                              widget.documentTitle ?? 'Document signé',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                      AdminGradientButton(
                        text: 'Voir la signature',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Affichage de la signature'), backgroundColor: Colors.blue),
                          );
                        },
                        height: 34,
                        width: 100,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Documents signés
              const Text(
                'Documents signés',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              if (_signedDocuments.isEmpty)
                const AdminEmptyState(
                  title: 'Aucun document signé',
                  subtitle: 'Signez votre premier document',
                  icon: Icons.edit_document_outlined,
                  actionText: 'Signer un document',
                  onAction: null,
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: _signedDocuments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final doc = _signedDocuments[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.description, size: 22, color: Colors.indigo),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc['title'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Signé par: ${doc['signer']} • ${doc['date'].day}/${doc['date'].month}/${doc['date'].year}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.visibility, size: 18),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Affichage du document signé'), backgroundColor: Colors.blue),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.download, size: 18),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Téléchargement du document'), backgroundColor: Colors.blue),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSignatureDialog,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.edit_document, color: Colors.white),
        tooltip: 'Signer un document',
      ),
    );
  }
}
