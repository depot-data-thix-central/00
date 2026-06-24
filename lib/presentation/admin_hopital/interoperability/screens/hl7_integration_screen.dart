// 📁 lib/presentation/admin_hopital/interoperability/screens/hl7_integration_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/hl7_import_widget.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_data_table.dart';

class Hl7IntegrationScreen extends ConsumerStatefulWidget {
  const Hl7IntegrationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<Hl7IntegrationScreen> createState() => _Hl7IntegrationScreenState();
}

class _Hl7IntegrationScreenState extends ConsumerState<Hl7IntegrationScreen> {
  bool _isLoading = false;
  final List<Map<String, dynamic>> _importHistory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intégration HL7 / FHIR'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Rafraîchir',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paramètres HL7'), backgroundColor: Colors.blue),
              );
            },
            tooltip: 'Paramètres',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Chargement...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Widget d'import
              HL7ImportWidget(
                onImport: (data) {
                  setState(() {
                    _importHistory.add({
                      ...data,
                      'importDate': DateTime.now(),
                      'status': 'success',
                    });
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Donnée importée avec succès'), backgroundColor: Colors.green),
                  );
                },
                onBatchImport: (data) {
                  setState(() {
                    for (var item in data) {
                      _importHistory.add({
                        ...item,
                        'importDate': DateTime.now(),
                        'status': 'success',
                      });
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${data.length} éléments importés'), backgroundColor: Colors.green),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Historique des imports
              const Text(
                'Historique des imports',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              if (_importHistory.isEmpty)
                const AdminEmptyState(
                  title: 'Aucun historique',
                  subtitle: 'Les imports effectués apparaîtront ici',
                  icon: Icons.history_outlined,
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _importHistory.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = _importHistory[_importHistory.length - 1 - index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.check_circle, size: 18, color: Colors.green),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['patientName'] ?? 'Patient inconnu',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${item['examType'] ?? 'Examen'} • ${item['date'] ?? 'Date inconnue'}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            (item['importDate'] as DateTime)
                                .toIso8601String()
                                .replaceFirst('T', ' ')
                                .substring(0, 16),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
