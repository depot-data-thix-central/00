// 📁 lib/presentation/admin_hopital/operations/widgets/equipment_maintenance_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_status_badge.dart';
import '../../../common/widgets/admin_gradient_button.dart';

enum MaintenanceStatus { operational, scheduled, in_progress, overdue }

class EquipmentMaintenanceCard extends StatefulWidget {
  final String equipmentName;
  final String serialNumber;
  final String location;
  final DateTime lastMaintenance;
  final DateTime nextMaintenance;
  final MaintenanceStatus status;
  final VoidCallback? onSchedule;
  final VoidCallback? onViewHistory;

  const EquipmentMaintenanceCard({
    Key? key,
    required this.equipmentName,
    required this.serialNumber,
    required this.location,
    required this.lastMaintenance,
    required this.nextMaintenance,
    required this.status,
    this.onSchedule,
    this.onViewHistory,
  }) : super(key: key);

  @override
  State<EquipmentMaintenanceCard> createState() => _EquipmentMaintenanceCardState();
}

class _EquipmentMaintenanceCardState extends State<EquipmentMaintenanceCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.status);
    final statusLabel = _getStatusLabel(widget.status);
    final daysUntilNext = widget.nextMaintenance.difference(DateTime.now()).inDays;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
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
                  _getStatusIcon(widget.status),
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
                      widget.equipmentName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'N° Série: ${widget.serialNumber} • ${widget.location}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              AdminStatusBadge(
                status: _getBadgeStatus(widget.status),
                customLabel: statusLabel,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.calendar_today,
                label: 'Dernière maintenance: ${widget.lastMaintenance.day}/${widget.lastMaintenance.month}/${widget.lastMaintenance.year}',
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                icon: Icons.timer,
                label: 'Prochaine: ${widget.nextMaintenance.day}/${widget.nextMaintenance.month}/${widget.nextMaintenance.year}',
                color: daysUntilNext <= 7 ? Colors.orange : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (daysUntilNext <= 7 && widget.status != MaintenanceStatus.overdue)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '⚠️ Maintenance dans $daysUntilNext jours',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (widget.status == MaintenanceStatus.overdue)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '🚨 Maintenance en retard de ${daysUntilNext.abs()} jours',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (widget.onSchedule != null)
                Expanded(
                  child: AdminGradientButton(
                    text: 'Planifier',
                    onPressed: widget.onSchedule,
                    icon: Icons.schedule,
                    height: 34,
                    gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                  ),
                ),
              const SizedBox(width: 8),
              if (widget.onViewHistory != null)
                Expanded(
                  child: AdminGradientButton(
                    text: 'Historique',
                    onPressed: widget.onViewHistory,
                    icon: Icons.history,
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

  Widget _buildInfoChip({required IconData icon, required String label, Color? color}) {
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

  Color _getStatusColor(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.operational:
        return Colors.green;
      case MaintenanceStatus.scheduled:
        return Colors.blue;
      case MaintenanceStatus.in_progress:
        return Colors.orange;
      case MaintenanceStatus.overdue:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.operational:
        return Icons.check_circle;
      case MaintenanceStatus.scheduled:
        return Icons.schedule;
      case MaintenanceStatus.in_progress:
        return Icons.sync;
      case MaintenanceStatus.overdue:
        return Icons.warning_amber;
    }
  }

  String _getStatusLabel(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.operational:
        return 'Opérationnel';
      case MaintenanceStatus.scheduled:
        return 'Programmé';
      case MaintenanceStatus.in_progress:
        return 'En cours';
      case MaintenanceStatus.overdue:
        return 'En retard';
    }
  }

  StatusType _getBadgeStatus(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.operational:
        return StatusType.completed;
      case MaintenanceStatus.scheduled:
        return StatusType.pending;
      case MaintenanceStatus.in_progress:
        return StatusType.warning;
      case MaintenanceStatus.overdue:
        return StatusType.cancelled;
    }
  }
}
