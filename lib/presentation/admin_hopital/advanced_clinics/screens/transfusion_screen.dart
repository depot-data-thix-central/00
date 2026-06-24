// 📁 lib/presentation/admin_hopital/advanced_clinics/screens/transfusion_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/transfusion_compatibility.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';

class TransfusionScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;
  final String? patientBloodType;

  const TransfusionScreen({
    Key? key,
    required this.patientId,
    required this.patientName,
    this.patientBloodType,
  }) : super(key: key);

  @override
  ConsumerState<TransfusionScreen> createState() => _TransfusionScreenState();
}

class _TransfusionScreenState extends ConsumerState<TransfusionScreen> {
  bool _isLoading = false;
  final List<Map<String, dynamic>> _orders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transfusion - ${widget.patientName}'),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Historique des transfusions'), backgroundColor: Colors.blue),
              );
            },
            tooltip: 'Historique',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Enregistrement de la demande...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TransfusionCompatibility(
                patientBloodType: widget.patientBloodType,
                onTransfusionOrdered: (data) {
                  setState(() {
                    _orders.add(data);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demande de transfusion enregistrée'), backgroundColor: Colors.green),
                  );
                },
              ),
              if (_orders.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Demandes récentes',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ..._orders.take(3).map((o) => Container(
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
                          color: o['isCompatible'] ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          o['isCompatible'] ? Icons.check_circle : Icons.warning,
                          size: 18,
                          color: o['isCompatible'] ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${o['selectedType']} - ${o['quantity']} poches',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Indication: ${o['indication']} • Priorité: ${o['priority']}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: o['isCompatible'] ? Colors.green.shade100 : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          o['isCompatible'] ? 'Compatible' : 'Incompatible',
                          style: TextStyle(
                            fontSize: 10,
                            color: o['isCompatible'] ? Colors.green.shade700 : Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
