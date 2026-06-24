// 📁 lib/presentation/admin_hopital/advanced_finance/screens/pricing_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/pricing_engine.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_empty_state.dart';

class PricingScreen extends ConsumerStatefulWidget {
  final String? patientId;
  final String? patientName;

  const PricingScreen({
    Key? key,
    this.patientId,
    this.patientName,
  }) : super(key: key);

  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _selectedActs = [];
  double _totalAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    final patientName = widget.patientName ?? 'Patient inconnu';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moteur de tarification'),
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
                const SnackBar(content: Text('Historique des facturations'), backgroundColor: Colors.blue),
              );
            },
            tooltip: 'Historique',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Calcul en cours...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Information patient
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patientName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            'ID: ${widget.patientId ?? 'Non spécifié'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AdminGradientButton(
                      text: 'Changer',
                      onPressed: () {
                        // Naviguer vers la sélection de patient
                      },
                      height: 34,
                      width: 100,
                      gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Moteur de tarification
              PricingEngine(
                patientId: widget.patientId ?? '',
                patientName: patientName,
                onApplyPricing: (acts) {
                  setState(() {
                    _selectedActs = acts;
                    _totalAmount = acts.fold(0.0, (sum, act) {
                      return sum + (act['basePrice'] as double) * (act['quantity'] ?? 1);
                    });
                  });
                },
              ),
              const SizedBox(height: 16),

              // Résumé de la facturation
              if (_selectedActs.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Récapitulatif de la facturation',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._selectedActs.map((act) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${act['label']} (${act['quantity']}x)',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Text(
                              '${(act['basePrice'] * (act['quantity'] ?? 1)).toStringAsFixed(2)} €',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                      const Divider(),
                      Row(
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_totalAmount.toStringAsFixed(2)} €',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AdminGradientButton(
                        text: 'Générer la facture',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Facture générée avec succès'), backgroundColor: Colors.green),
                          );
                          context.push('/admin/billing/invoice/create');
                        },
                        icon: Icons.receipt,
                        gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
