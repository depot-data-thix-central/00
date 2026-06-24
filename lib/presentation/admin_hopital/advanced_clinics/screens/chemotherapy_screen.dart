// 📁 lib/presentation/admin_hopital/advanced_clinics/screens/chemotherapy_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/chemo_protocol_form.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';

class ChemotherapyScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;

  const ChemotherapyScreen({
    Key? key,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  ConsumerState<ChemotherapyScreen> createState() => _ChemotherapyScreenState();
}

class _ChemotherapyScreenState extends ConsumerState<ChemotherapyScreen> {
  bool _isLoading = false;
  final List<Map<String, dynamic>> _protocols = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chimiothérapie - ${widget.patientName}'),
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
                const SnackBar(content: Text('Historique des protocoles'), backgroundColor: Colors.blue),
              );
            },
            tooltip: 'Historique',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Enregistrement du protocole...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ChemoProtocolForm(
                patientId: widget.patientId,
                patientName: widget.patientName,
                onProtocolCreated: (data) {
                  setState(() {
                    _protocols.add(data);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Protocole créé avec succès'), backgroundColor: Colors.green),
                  );
                },
              ),
              if (_protocols.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Protocoles en cours',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ..._protocols.map((p) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${p['protocolName']} - Cycle ${p['cycle']}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Phase: ${p['phase']} • Statut: ${p['status']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: (p['drugs'] as List).map((drug) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              drug['name'],
                              style: TextStyle(fontSize: 11, color: Colors.purple.shade700),
                            ),
                          );
                        }).toList(),
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
