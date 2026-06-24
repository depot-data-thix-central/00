// 📁 lib/presentation/admin_hopital/billing/widgets/billing_summary.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/providers/admin_billing_provider.dart';

class BillingSummary extends ConsumerWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const BillingSummary({
    Key? key,
    this.startDate,
    this.endDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminBillingProvider);

    if (state.isLoading && state.invoices.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // Filtrer par dates
    var invoices = state.invoices;
    if (startDate != null) {
      invoices = invoices.where((inv) =>
        inv.date.year >= startDate!.year &&
        inv.date.month >= startDate!.month &&
        inv.date.day >= startDate!.day
      ).toList();
    }
    if (endDate != null) {
      invoices = invoices.where((inv) =>
        inv.date.year <= endDate!.year &&
        inv.date.month <= endDate!.month &&
        inv.date.day <= endDate!.day
      ).toList();
    }

    final total = invoices.length;
    final paid = invoices.where((inv) => inv.status == 'paid').length;
    final pending = invoices.where((inv) => inv.status == 'pending').length;
    final cancelled = invoices.where((inv) => inv.status == 'cancelled').length;

    final totalAmount = invoices.fold(0.0, (sum, inv) => sum + inv.amount);
    final paidAmount = invoices.where((inv) => inv.status == 'paid').fold(0.0, (sum, inv) => sum + inv.amount);
    final pendingAmount = invoices.where((inv) => inv.status == 'pending').fold(0.0, (sum, inv) => sum + inv.amount);

    final paymentRate = total > 0 ? (paid / total * 100) : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.02),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.summarize, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Résumé des factures',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (startDate != null || endDate != null)
                Text(
                  '${startDate != null ? 'Du ${startDate!.day}/${startDate!.month}/${startDate!.year}' : ''}${startDate != null && endDate != null ? ' au ' : ''}${endDate != null ? '${endDate!.day}/${endDate!.month}/${endDate!.year}' : ''}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Statistiques
          Row(
            children: [
              _buildStatItem('Total', '$total', Icons.receipt, Colors.grey),
              _buildStatItem('Payées', '$paid', Icons.check_circle, Colors.green),
              _buildStatItem('En attente', '$pending', Icons.pending, Colors.orange),
              _buildStatItem('Annulées', '$cancelled', Icons.cancel, Colors.red),
            ],
          ),
          const SizedBox(height: 16),

          // Montants
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total facturé',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${totalAmount.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payé',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${paidAmount.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'En attente',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${pendingAmount.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Taux de paiement
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: paymentRate >= 80 ? Colors.green.shade50 : (paymentRate >= 50 ? Colors.orange.shade50 : Colors.red.shade50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Taux de paiement',
                        style: TextStyle(
                          fontSize: 12,
                          color: paymentRate >= 80 ? Colors.green.shade700 : (paymentRate >= 50 ? Colors.orange.shade700 : Colors.red.shade700),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${paymentRate.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: paymentRate >= 80 ? Colors.green.shade700 : (paymentRate >= 50 ? Colors.orange.shade700 : Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: paymentRate / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: paymentRate >= 80 ? Colors.green : (paymentRate >= 50 ? Colors.orange : Colors.red),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
