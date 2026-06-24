// 📁 lib/presentation/admin_hopital/operations/widgets/linen_inventory_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_gradient_button.dart';
import '../../../common/widgets/admin_status_badge.dart';

class LinenInventoryItem extends StatefulWidget {
  final String name;
  final String category;
  final int quantity;
  final int threshold;
  final String condition; // 'good', 'fair', 'poor'
  final VoidCallback? onReorder;
  final VoidCallback? onInspect;

  const LinenInventoryItem({
    Key? key,
    required this.name,
    required this.category,
    required this.quantity,
    required this.threshold,
    required this.condition,
    this.onReorder,
    this.onInspect,
  }) : super(key: key);

  @override
  State<LinenInventoryItem> createState() => _LinenInventoryItemState();
}

class _LinenInventoryItemState extends State<LinenInventoryItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isLow = widget.quantity <= widget.threshold;
    final isCritical = widget.quantity <= widget.threshold * 0.5;

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

    Color conditionColor;
    String conditionLabel;
    switch (widget.condition) {
      case 'good':
        conditionColor = Colors.green;
        conditionLabel = 'Bon';
        break;
      case 'fair':
        conditionColor = Colors.orange;
        conditionLabel = 'Moyen';
        break;
      case 'poor':
        conditionColor = Colors.red;
        conditionLabel = 'Mauvais';
        break;
      default:
        conditionColor = Colors.grey;
        conditionLabel = 'Inconnu';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCritical ? Colors.red.shade200 : (isLow ? Colors.orange.shade200 : Colors.grey.shade100),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCritical ? Icons.warning_amber : (isLow ? Icons.info_outline : Icons.checkroom),
                  size: 22,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Catégorie: ${widget.category}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.quantity} unités',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AdminStatusBadge(
                    status: isCritical ? StatusType.cancelled : (isLow ? StatusType.warning : StatusType.completed),
                    customLabel: statusLabel,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildChip(Icons.assessment, 'Seuil: ${widget.threshold}', color: Colors.grey),
              const SizedBox(width: 8),
              _buildChip(Icons.health_and_safety, 'État: $conditionLabel', color: conditionColor),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (widget.onReorder != null && isLow)
                Expanded(
                  child: AdminGradientButton(
                    text: 'Réapprovisionner',
                    onPressed: widget.onReorder,
                    icon: Icons.add_shopping_cart,
                    height: 34,
                    gradient: LinearGradient(
                      colors: isCritical ? [Colors.red, Colors.redAccent] : [Colors.orange, Colors.orangeAccent],
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              if (widget.onInspect != null)
                Expanded(
                  child: AdminGradientButton(
                    text: 'Inspecter',
                    onPressed: widget.onInspect,
                    icon: Icons.visibility,
                    height: 34,
                    gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color ?? Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color ?? Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
