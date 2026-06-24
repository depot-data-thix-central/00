// 📁 lib/presentation/admin_hopital/medications/widgets/medication_inventory_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_status_badge.dart';
import '../../../common/widgets/admin_gradient_button.dart';
import '../../../common/widgets/admin_confirm_dialog.dart';
import '../../common/providers/admin_medication_provider.dart';
import '../../../../data/models/hospital/medication_model.dart';

class MedicationInventoryItem extends ConsumerStatefulWidget {
  final MedicationModel medication;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const MedicationInventoryItem({
    Key? key,
    required this.medication,
    this.onTap,
    this.onEdit,
  }) : super(key: key);

  @override
  ConsumerState<MedicationInventoryItem> createState() => _MedicationInventoryItemState();
}

class _MedicationInventoryItemState extends ConsumerState<MedicationInventoryItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final med = widget.medication;
    final stockLevel = med.quantity;
    final threshold = med.threshold ?? 30;
    final isLow = stockLevel <= threshold;
    final isCritical = stockLevel <= threshold * 0.5;

    Color statusColor;
    String statusLabel;
    if (isCritical) {
      statusColor = Colors.red;
      statusLabel = 'Critique';
    } else if (isLow) {
      statusColor = Colors.orange;
      statusLabel = 'Bas';
    } else {
      statusColor = Colors.green;
      statusLabel = 'Normal';
    }

    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCritical ? Colors.red.shade200 : (isLow ? Colors.orange.shade200 : Colors.grey.shade100),
          ),
          boxShadow: [
            BoxShadow(
              color: (isCritical ? Colors.red : (isLow ? Colors.orange : Colors.grey)).withOpacity(0.03),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ligne principale
            Row(
              children: [
                // Icône
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCritical ? Icons.warning_amber : (isLow ? Icons.info_outline : Icons.medication),
                    size: 22,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 14),
                // Informations
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${med.dosage} • ${med.form ?? 'Comprimé'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (med.batchNumber != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Lot: ${med.batchNumber}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Stock et statut
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$stockLevel unités',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                if (widget.onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: widget.onEdit,
                    color: Colors.grey.shade500,
                  ),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            // Détails étendus
            if (_isExpanded) ...[
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem('Stock', '$stockLevel unités'),
                  ),
                  Expanded(
                    child: _buildDetailItem('Seuil', '$threshold unités'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem('Prix unitaire', med.price != null ? '${med.price!.toStringAsFixed(2)} €' : 'N/A'),
                  ),
                  Expanded(
                    child: _buildDetailItem('Date d\'expiration', med.expiryDate != null ? '${med.expiryDate!.day}/${med.expiryDate!.month}/${med.expiryDate!.year}' : 'N/A'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (isLow)
                    AdminGradientButton(
                      text: 'Réapprovisionner',
                      onPressed: () => _showReorderDialog(med),
                      icon: Icons.add_shopping_cart,
                      height: 36,
                      width: 140,
                      gradient: const LinearGradient(colors: [Colors.orange, Colors.orangeAccent]),
                    ),
                  const Spacer(),
                  AdminGradientButton(
                    text: 'Ajuster le stock',
                    onPressed: () => _showStockAdjustDialog(med),
                    icon: Icons.edit,
                    height: 36,
                    width: 140,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
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

  void _showStockAdjustDialog(MedicationModel med) {
    final quantityCtrl = TextEditingController(text: med.quantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Ajuster le stock - ${med.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Stock actuel: ${med.quantity} unités',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nouvelle quantité',
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
            onPressed: () async {
              final newQuantity = int.tryParse(quantityCtrl.text);
              if (newQuantity == null || newQuantity < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quantité invalide'), backgroundColor: Colors.orange),
                );
                return;
              }
              Navigator.pop(context);
              final success = await ref.read(adminMedicationProvider.notifier)
                  .updateStock(med.id, newQuantity);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stock mis à jour'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Mettre à jour'),
          ),
        ],
      ),
    );
  }
}
