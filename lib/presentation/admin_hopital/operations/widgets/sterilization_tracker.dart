// 📁 lib/presentation/admin_hopital/operations/widgets/sterilization_tracker.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class SterilizationTracker extends StatefulWidget {
  final String batchId;
  final DateTime sterilizationDate;
  final DateTime expiryDate;
  final String technician;
  final String method;
  final String status; // 'active', 'expired', 'used'
  final int itemCount;
  final VoidCallback? onDetails;

  const SterilizationTracker({
    Key? key,
    required this.batchId,
    required this.sterilizationDate,
    required this.expiryDate,
    required this.technician,
    required this.method,
    required this.status,
    required this.itemCount,
    this.onDetails,
  }) : super(key: key);

  @override
  State<SterilizationTracker> createState() => _SterilizationTrackerState();
}

class _SterilizationTrackerState extends State<SterilizationTracker> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.status == 'active';
    final isExpired = widget.status == 'expired';
    final isUsed = widget.status == 'used';
    final daysUntilExpiry = widget.expiryDate.difference(DateTime.now()).inDays;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? Colors.green.shade200 : (isExpired ? Colors.red.shade200 : Colors.grey.shade200),
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
                  color: isActive ? Colors.green.shade50 : (isExpired ? Colors.red.shade50 : Colors.grey.shade50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isActive ? Icons.check_circle : (isExpired ? Icons.warning_amber : Icons.inventory),
                  size: 22,
                  color: isActive ? Colors.green : (isExpired ? Colors.red : Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lot #${widget.batchId}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.itemCount} instruments • ${widget.method}',
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
                  color: isActive ? Colors.green.shade100 : (isExpired ? Colors.red.shade100 : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'Actif' : (isExpired ? 'Expiré' : 'Utilisé'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.green.shade700 : (isExpired ? Colors.red.shade700 : Colors.grey.shade700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildInfoChip(Icons.date_range, 'Stérilisation: ${widget.sterilizationDate.day}/${widget.sterilizationDate.month}/${widget.sterilizationDate.year}'),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.calendar_today, 'Expiration: ${widget.expiryDate.day}/${widget.expiryDate.month}/${widget.expiryDate.year}'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildInfoChip(Icons.person, 'Technicien: ${widget.technician}', color: Colors.blue),
            ],
          ),
          if (isActive && daysUntilExpiry <= 7)
            const SizedBox(height: 8),
          if (isActive && daysUntilExpiry <= 7)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '⚠️ Expiration dans $daysUntilExpiry jours',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (isExpired)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '🚨 Expiré depuis ${daysUntilExpiry.abs()} jours',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (widget.onDetails != null)
            AdminGradientButton(
              text: 'Voir détails',
              onPressed: widget.onDetails,
              icon: Icons.visibility,
              height: 34,
              gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
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
