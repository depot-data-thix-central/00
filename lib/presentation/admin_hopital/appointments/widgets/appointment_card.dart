// 📁 lib/presentation/admin_hopital/appointments/widgets/appointment_card.dart

import 'package:flutter/material.dart';
import '../../../common/widgets/admin_status_badge.dart';
import '../../../../data/models/hospital/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    this.onTap,
    this.onCancel,
    this.onReschedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = appointment.status;
    final isCompleted = status == 'completed';
    final isCancelled = status == 'cancelled';
    final isPending = status == 'pending';
    final isConfirmed = status == 'confirmed';

    StatusType statusType;
    if (isCompleted) statusType = StatusType.completed;
    else if (isCancelled) statusType = StatusType.cancelled;
    else if (isPending) statusType = StatusType.pending;
    else statusType = StatusType.active;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCancelled ? Colors.red.shade200 : Colors.grey.shade100,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône selon le statut
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getStatusIcon(status),
                size: 22,
                color: _getStatusColor(status),
              ),
            ),
            const SizedBox(width: 14),
            // Infos principales
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.patientName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Dr. ${appointment.doctorName} • ${appointment.specialty}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '${appointment.date.day}/${appointment.date.month}/${appointment.date.year} à ${appointment.time}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      appointment.notes!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Statut et actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AdminStatusBadge(
                  status: statusType,
                  customLabel: _getStatusLabel(status),
                ),
                const SizedBox(height: 6),
                if (!isCancelled && !isCompleted) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onReschedule != null)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: onReschedule,
                          color: Colors.blue,
                        ),
                      if (onCancel != null)
                        IconButton(
                          icon: const Icon(Icons.cancel, size: 18),
                          onPressed: onCancel,
                          color: Colors.red,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_empty;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmé';
      case 'pending':
        return 'En attente';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }
}
