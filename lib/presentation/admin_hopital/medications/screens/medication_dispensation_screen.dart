// 📁 lib/presentation/admin_hopital/medications/screens/medication_dispensation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/medication_dispensation.dart';
import '../../common/providers/admin_medication_provider.dart';
import '../../common/providers/admin_patient_provider.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';

class MedicationDispensationScreen extends ConsumerStatefulWidget {
  final String? patientId;
  final String? patientName;

  const MedicationDispensationScreen({
    Key? key,
    this.patientId,
    this.patientName,
  }) : super(key: key);

  @override
  ConsumerState<MedicationDispensationScreen> createState() => _MedicationDispensationScreenState();
}

class _MedicationDispensationScreenState extends ConsumerState<MedicationDispensationScreen> {
  final List<Map<String, dynamic>> _dispensedItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      ref.read(adminMedicationProvider.notifier).loadMedications(),
      ref.read(adminPatientProvider.notifier).loadPatients(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final patientName = widget.patientName ?? 'Patient sélectionné';

    return Scaffold(
      appBar: AppBar(
        title: Text('Dispensation - $patientName'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Naviguer vers l'historique des dispensation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Historique des dispensation'), backgroundColor: Colors.blue),
              );
            },
            tooltip: 'Historique',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Formulaire de dispensation
            MedicationDispensation(
              onDispense: (data) {
                setState(() {
                  _dispensedItems.add(data);
                });
                // Rafraîchir les stocks
                ref.read(adminMedicationProvider.notifier).loadMedications();
              },
              patientId: widget.patientId,
            ),
            const SizedBox(height: 20),

            // Liste des dispensations du jour
            if (_dispensedItems.isNotEmpty) ...[
              const Text(
                'Dispensations du jour',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ..._dispensedItems.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.02),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.check_circle, size: 18, color: Colors.teal),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['medicationName'] ?? '',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item['dosage']} • ${item['quantity']} ${item['unit']}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          if (item['instructions'] != null && item['instructions'].toString().isNotEmpty)
                            Text(
                              '📝 ${item['instructions']}',
                              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey.shade500),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '${(item['date'] as DateTime).hour}:${(item['date'] as DateTime).minute.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 12),
              AdminGradientButton(
                text: 'Voir le récapitulatif',
                onPressed: () {
                  _showSummaryDialog();
                },
                icon: Icons.summarize,
                gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSummaryDialog() {
    final totalItems = _dispensedItems.length;
    final totalQuantity = _dispensedItems.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Récapitulatif des dispensations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total: $totalItems médicament${totalItems > 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Quantité totale: $totalQuantity unités',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ..._dispensedItems.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${item['medicationName']}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    '${item['quantity']} ${item['unit']}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Imprimer le récapitulatif
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Impression du récapitulatif'), backgroundColor: Colors.blue),
              );
            },
            child: const Text('Imprimer'),
          ),
        ],
      ),
    );
  }
}
