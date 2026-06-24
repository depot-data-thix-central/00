// 📁 lib/presentation/admin_hopital/beds/widgets/bed_list_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/providers/admin_bed_provider.dart';
import '../../../common/widgets/admin_status_badge.dart';
import '../../../common/widgets/admin_confirm_dialog.dart';
import '../../../../data/models/hospital/bed_model.dart';

class BedListTile extends ConsumerStatefulWidget {
  final BedModel bed;
  final VoidCallback? onTap;
  final VoidCallback? onAssign;
  final VoidCallback? onTransfer;
  final VoidCallback? onClean;

  const BedListTile({
    Key? key,
    required this.bed,
    this.onTap,
    this.onAssign,
    this.onTransfer,
    this.onClean,
  }) : super(key: key);

  @override
  ConsumerState<BedListTile> createState() => _BedListTileState();
}

class _BedListTileState extends ConsumerState<BedListTile> {
  @override
  Widget build(BuildContext context) {
    final bed = widget.bed;
    final color = _getStatusColor(bed.status);
    final icon = _getStatusIcon(bed.status);
    final statusLabel = _getStatusLabel(bed.status);

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _getStatusColor(bed.status).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            // Numéro et icône
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(height: 2),
                    Text(
                      bed.number,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Infos principales
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lit ${bed.number}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bed.service ?? 'Service général',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (bed.patientName != null && bed.status == 'occupied') ...[
                    const SizedBox(height: 2),
                    Text(
                      'Patient: ${bed.patientName}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                  if (bed.status == 'cleaning')
                    const Text(
                      'En cours de nettoyage',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
            // Statut et actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AdminStatusBadge(
                  status: _getStatusType(bed.status),
                  customLabel: statusLabel,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (bed.status == 'available' && widget.onAssign != null)
                      _buildActionButton(
                        icon: Icons.person_add,
                        color: Colors.green,
                        onPressed: widget.onAssign!,
                      ),
                    if (bed.status == 'occupied' && widget.onTransfer != null)
                      _buildActionButton(
                        icon: Icons.swap_horiz,
                        color: Colors.blue,
                        onPressed: widget.onTransfer!,
                      ),
                    if (bed.status != 'cleaning' && bed.status != 'available' && widget.onClean != null)
                      _buildActionButton(
                        icon: Icons.cleaning_services,
                        color: Colors.orange,
                        onPressed: widget.onClean!,
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 16, color: color),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        tooltip: '',
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'occupied':
        return Colors.red;
      case 'available':
        return Colors.green;
      case 'cleaning':
        return Colors.orange;
      case 'reserved':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'occupied':
        return Icons.bed;
      case 'available':
        return Icons.bed_outlined;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'reserved':
        return Icons.bookmark;
      default:
        return Icons.bed;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'occupied':
        return 'Occupé';
      case 'available':
        return 'Disponible';
      case 'cleaning':
        return 'Nettoyage';
      case 'reserved':
        return 'Réservé';
      default:
        return status;
    }
  }

  StatusType _getStatusType(String status) {
    switch (status) {
      case 'occupied':
        return StatusType.active;
      case 'available':
        return StatusType.completed;
      case 'cleaning':
        return StatusType.warning;
      case 'reserved':
        return StatusType.pending;
      default:
        return StatusType.inactive;
    }
  }
}
