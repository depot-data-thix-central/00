// 📁 lib/presentation/admin_hopital/medications/widgets/medication_stock_alert.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_gradient_button.dart';
import '../../common/providers/admin_medication_provider.dart';
import '../../../../data/models/hospital/medication_model.dart';

class MedicationStockAlert extends ConsumerStatefulWidget {
  final MedicationModel medication;
  final VoidCallback? onDismiss;

  const MedicationStockAlert({
    Key? key,
    required this.medication,
    this.onDismiss,
  }) : super(key: key);

  @override
  ConsumerState<MedicationStockAlert> createState() => _MedicationStockAlertState();
}

class _MedicationStockAlertState extends ConsumerState<MedicationStockAlert> {
  bool _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    final med = widget.medication;
    final threshold = med.threshold ?? 30;
    final isCritical = med.quantity <= threshold * 0.5;
    final isLow = med.quantity <= threshold && !isCritical;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCritical ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCritical ? Colors.red.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCritical ? Icons.warning_amber : Icons.info_outline,
                color: isCritical ? Colors.red : Colors.orange,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCritical ? '⚠️ Stock critique !' : '⚠️ Stock faible',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isCritical ? Colors.red : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${med.name} (${med.dosage})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    setState(() => _isDismissed = true);
                    widget.onDismiss!();
                  },
                  color: Colors.grey.shade500,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Stock: ${med.quantity} unités',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isCritical ? Colors.red : Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Seuil: $threshold unités',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
              const Spacer(),
              AdminGradientButton(
                text: 'Réapprovisionner',
                onPressed: () => _showReorderDialog(med),
                gradient: LinearGradient(
                  colors: isCritical ? [Colors.red, Colors.redAccent] : [Colors.orange, Colors.orangeAccent],
                ),
                width: 140,
                height: 34,
                icon: Icons.add_shopping_cart,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReorderDialog(MedicationModel med) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Réapprovisionner ${med.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock actuel: ${med.quantity} unités',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Seuil critique: ${med.threshold} unités',
              style: TextStyle(fontSize: 14, color: Colors.orange),
            ),
            const SizedBox(height: 16),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantité à commander',
                hintText: 'Ex: 100',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Commande de réapprovisionnement envoyée'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Commander'),
          ),
        ],
      ),
    );
  }
}
