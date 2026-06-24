// 📁 lib/presentation/admin_hopital/advanced_finance/screens/billing_reminder_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/payment_reminder.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_stats_card.dart';
import '../../common/widgets/admin_gradient_button.dart';

class BillingReminderScreen extends ConsumerStatefulWidget {
  const BillingReminderScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BillingReminderScreen> createState() => _BillingReminderScreenState();
}

class _BillingReminderScreenState extends ConsumerState<BillingReminderScreen> {
  bool _isLoading = true;

  // Données mockées
  final List<Map<String, dynamic>> _invoices = [
    {'id': '1', 'number': 'FACT-2024-001', 'patient': 'Michel Dupont', 'amount': 150.0, 'dueDate': DateTime.now().subtract(const Duration(days: 5)), 'status': 'overdue'},
    {'id': '2', 'number': 'FACT-2024-002', 'patient': 'Sophie Martin', 'amount': 230.0, 'dueDate': DateTime.now().subtract(const Duration(days: 18)), 'status': 'overdue'},
    {'id': '3', 'number': 'FACT-2024-003', 'patient': 'Lucas Bernard', 'amount': 85.0, 'dueDate': DateTime.now().subtract(const Duration(days: 2)), 'status': 'overdue'},
    {'id': '4', 'number': 'FACT-2024-004', 'patient': 'Julie Petit', 'amount': 320.0, 'dueDate': DateTime.now().add(const Duration(days: 10)), 'status': 'pending'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final overdueInvoices = _invoices.where((inv) => inv['status'] == 'overdue').toList();
    final totalOverdue = overdueInvoices.fold(0.0, (sum, inv) => sum + (inv['amount'] as double));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relances de paiement'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Rafraîchir',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export des relances'), backgroundColor: Colors.blue),
              );
            },
            tooltip: 'Exporter',
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
              // Statistiques
              Row(
                children: [
                  Expanded(
                    child: AdminStatsCard(
                      label: 'Factures impayées',
                      value: overdueInvoices.length.toString(),
                      icon: Icons.warning_amber,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AdminStatsCard(
                      label: 'Montant total',
                      value: '${totalOverdue.toStringAsFixed(2)} €',
                      icon: Icons.euro,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Widget de rappel
              PaymentReminder(
                invoices: _invoices,
                onSendReminders: (ids) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${ids.length} rappels envoyés avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Actions
              AdminGradientButton(
                text: 'Voir toutes les factures',
                onPressed: () {
                  context.push('/admin/billing/invoices');
                },
                icon: Icons.receipt,
                gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
