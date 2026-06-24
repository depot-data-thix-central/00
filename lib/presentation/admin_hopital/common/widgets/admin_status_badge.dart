
// 📁 lib/presentation/admin_hopital/common/widgets/admin_status_badge.dart

import 'package:flutter/material.dart';

enum StatusType { active, inactive, pending, completed, cancelled, warning }

class AdminStatusBadge extends StatelessWidget {
  final StatusType status;
  final String? customLabel;
  final double fontSize;

  const AdminStatusBadge({
    Key? key,
    required this.status,
    this.customLabel,
    this.fontSize = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: config.color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: config.color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            customLabel ?? config.label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getConfig(StatusType status) {
    switch (status) {
      case StatusType.active:
        return _StatusConfig(Colors.green, 'Actif');
      case StatusType.inactive:
        return _StatusConfig(Colors.grey, 'Inactif');
      case StatusType.pending:
        return _StatusConfig(Colors.orange, 'En attente');
      case StatusType.completed:
        return _StatusConfig(Colors.blue, 'Terminé');
      case StatusType.cancelled:
        return _StatusConfig(Colors.red, 'Annulé');
      case StatusType.warning:
        return _StatusConfig(Colors.deepOrange, 'Alerte');
    }
  }
}

class _StatusConfig {
  final Color color;
  final String label;
  const _StatusConfig(this.color, this.label);
}
