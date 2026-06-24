// 📁 lib/presentation/admin_hopital/interoperability/screens/external_pharmacy_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/pharmacy_external_api.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';

class ExternalPharmacyScreen extends ConsumerStatefulWidget {
  const ExternalPharmacyScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ExternalPharmacyScreen> createState() => _ExternalPharmacyScreenState();
}

class _ExternalPharmacyScreenState extends ConsumerState<ExternalPharmacyScreen> {
  bool _isLoading = false;
  bool _isEnabled = false;
  final List<Map<String, dynamic>> _orderHistory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacies externes'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Rafraîchir',
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
              PharmacyExternalApi(
                onUpdate: (data) {
                  if (data.containsKey('enabled')) {
                    setState(() => _isEnabled = data['enabled']);
                  }
                  if (data.containsKey('synced')) {
                    _addOrderHistory('Synchronisation effectuée');
                  }
                },
              ),
              const SizedBox(height: 16),

              // Ordres récents
              Container(
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
                        const Icon(Icons.receipt, size: 18, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text(
                          'Historique des commandes',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        if (_orderHistory.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_orderHistory.length} commandes',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_orderHistory.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Aucune commande synchronisée',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _orderHistory.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final order = _orderHistory[_orderHistory.length - 1 - index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: order['status'] == 'validated'
                                        ? Colors.green.shade50
                                        : (order['status'] == 'pending'
                                            ? Colors.orange.shade50
                                            : Colors.red.shade50),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    order['status'] == 'validated'
                                        ? Icons.check_circle
                                        : (order['status'] == 'pending'
                                            ? Icons.pending
                                            : Icons.warning_amber),
                                    size: 16,
                                    color: order['status'] == 'validated'
                                        ? Colors.green
                                        : (order['status'] == 'pending'
                                            ? Colors.orange
                                            : Colors.red),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order['patient'] ?? 'Patient inconnu',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        order['description'] ?? 'Commande',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  order['date'] ?? '',
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
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Actions
              AdminGradientButton(
                text: 'Voir toutes les pharmacies',
                onPressed: () {
                  context.push('/admin/interop/pharmacies/list');
                },
                icon: Icons.local_pharmacy,
                gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addOrderHistory(String description, {String status = 'pending', String patient = 'Système'}) {
    setState(() {
      _orderHistory.add({
        'patient': patient,
        'description': description,
        'status': status,
        'date': DateTime.now().toIso8601String().replaceFirst('T', ' ').substring(0, 16),
      });
    });
  }
}
