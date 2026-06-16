// 📁 lib/presentation/admin_hopital/operations/widgets/waste_disposal_tracker.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class WasteDisposalTracker extends StatefulWidget {
  final String batchId;
  final String wasteType;
  final double quantity;
  final String unit;
  final DateTime disposalDate;
  final String disposedBy;
  final String method;
  final String status; // 'pending', 'processed', 'disposed'

  const WasteDisposalTracker({
    Key? key,
    required this.batchId,
    required this.wasteType,
    required this.quantity,
    required this.unit,
    required this.disposalDate,
    required this.disposedBy,
    required this.method,
    required this.status,
  }) : super(key: key);

  @override
  State<WasteDisposalTracker> createState() => _WasteDisposalTrackerState();
}

class _WasteDisposalTrackerState extends State<WasteDisposalTracker> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isPending = widget.status == 'pending';
    final isProcessed = widget.status == 'processed';
    final isDisposed = widget.status == 'disposed';

    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    if (isPending) {
      statusColor = Colors.orange;
      statusLabel = 'En attente';
      statusIcon = Icons.pending;
    } else if (isProcessed) {
      statusColor = Colors.blue;
      statusLabel = 'Traitement';
      statusIcon = Icons.sync;
    } else {
      statusColor = Colors.green;
      statusLabel = 'Éliminé';
      statusIcon = Icons.check_circle;
    }

    final daysSince = DateTime.now().difference(widget.disposalDate).inDays;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPending ? Colors.orange.shade200 : (isProcessed ? Colors.blue.shade200 : Colors.green.shade200),
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
                child: Icon(statusIcon, size: 22, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Déchet #${widget.batchId}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.wasteType} • ${widget.quantity} ${widget.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          const SizedBox(height: 8),
          Row(
            children: [
              _buildChip(Icons.calendar_today, 'Date: ${widget.disposalDate.day}/${widget.disposalDate.month}/${widget.disposalDate.year}'),
              const SizedBox(width: 8),
              _buildChip(Icons.person, 'Par: ${widget.disposedBy}', color: Colors.blue),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildChip(Icons.factory, 'Méthode: ${widget.method}', color: Colors.purple),
              const SizedBox(width: 8),
              _buildChip(Icons.timer, '$daysSince jours', color: Colors.grey),
            ],
          ),
          if (isPending && daysSince > 2)
            const SizedBox(height: 8),
          if (isPending && daysSince > 2)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '⚠️ En attente de traitement depuis $daysSince jours',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (isPending)
                Expanded(
                  child: AdminGradientButton(
                    text: 'Traiter',
                    onPressed: () {},
                    icon: Icons.play_arrow,
                    height: 34,
                    gradient: const LinearGradient(colors: [Colors.orange, Colors.orangeAccent]),
                  ),
                ),
              if (isProcessed)
                Expanded(
                  child: AdminGradientButton(
                    text: 'Marquer éliminé',
                    onPressed: () {},
                    icon: Icons.check,
                    height: 34,
                    gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: AdminGradientButton(
                  text: 'Détails',
                  onPressed: () {},
                  icon: Icons.visibility,
                  height: 34,
                  gradient: const LinearGradient(colors: [Colors.grey, Colors.grey]),
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
