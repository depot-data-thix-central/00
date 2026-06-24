// 📁 lib/presentation/admin_hopital/security/widgets/audit_log_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_status_badge.dart';

class AuditLogItem extends StatelessWidget {
  final String action;
  final String user;
  final String userRole;
  final String target;
  final DateTime timestamp;
  final String? details;
  final String? ipAddress;
  final String? userAgent;

  const AuditLogItem({
    Key? key,
    required this.action,
    required this.user,
    required this.userRole,
    required this.target,
    required this.timestamp,
    this.details,
    this.ipAddress,
    this.userAgent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCritical = _isCriticalAction(action);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCritical ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCritical ? Colors.red.shade200 : Colors.grey.shade100,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCritical ? Colors.red.shade100 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getActionIcon(action),
              size: 18,
              color: isCritical ? Colors.red : Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      action,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isCritical ? FontWeight.bold : FontWeight.w600,
                        color: isCritical ? Colors.red : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isCritical)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Critique',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      user,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '($userRole)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      target,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (ipAddress != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.public, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        ipAddress!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
                if (details != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      details!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          AdminStatusBadge(
            status: isCritical ? StatusType.warning : StatusType.completed,
            customLabel: isCritical ? 'Sensible' : 'Standard',
          ),
        ],
      ),
    );
  }

  bool _isCriticalAction(String action) {
    final criticalActions = [
      'Suppression de dossier',
      'Modification de données sensibles',
      'Accès refusé',
      'Échec de connexion',
      'Export de données',
    ];
    return criticalActions.any((a) => action.contains(a));
  }

  IconData _getActionIcon(String action) {
    if (action.contains('Connexion')) return Icons.login;
    if (action.contains('Déconnexion')) return Icons.logout;
    if (action.contains('Création')) return Icons.add_circle_outline;
    if (action.contains('Modification')) return Icons.edit_outlined;
    if (action.contains('Suppression')) return Icons.delete_outline;
    if (action.contains('Consultation')) return Icons.visibility_outlined;
    if (action.contains('Export')) return Icons.download;
    if (action.contains('Erreur') || action.contains('Échec')) return Icons.error_outline;
    return Icons.info_outline;
  }
}
