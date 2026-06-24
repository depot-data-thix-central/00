// 📁 lib/presentation/admin_hopital/analytics/widgets/cdss_alert_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_gradient_button.dart';

enum CDSSSeverity { low, medium, high, critical }

class CDSSAlertCard extends StatefulWidget {
  final String patientName;
  final String patientId;
  final String alertType;
  final String description;
  final CDSSSeverity severity;
  final String recommendation;
  final DateTime timestamp;
  final VoidCallback? onViewDetails;
  final VoidCallback? onDismiss;

  const CDSSAlertCard({
    Key? key,
    required this.patientName,
    required this.patientId,
    required this.alertType,
    required this.description,
    required this.severity,
    required this.recommendation,
    required this.timestamp,
    this.onViewDetails,
    this.onDismiss,
  }) : super(key: key);

  @override
  State<CDSSAlertCard> createState() => _CDSSAlertCardState();
}

class _CDSSAlertCardState extends State<CDSSAlertCard> {
  bool _isExpanded = false;
  bool _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    final color = _getSeverityColor(widget.severity);
    final icon = _getSeverityIcon(widget.severity);
    final label = _getSeverityLabel(widget.severity);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.alertType,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          widget.patientName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
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
                          '${widget.timestamp.hour}:${widget.timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              if (widget.onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    setState(() => _isDismissed = true);
                    widget.onDismiss!();
                  },
                  color: Colors.grey.shade400,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.3,
            ),
            maxLines: _isExpanded ? null : 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Text(
              _isExpanded ? 'Voir moins' : 'Voir plus',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Recommandation: ${widget.recommendation}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              if (widget.onViewDetails != null)
                Expanded(
                  child: AdminGradientButton(
                    text: 'Voir détails',
                    onPressed: widget.onViewDetails!,
                    icon: Icons.visibility,
                    height: 34,
                    gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: AdminGradientButton(
                  text: 'Marquer lu',
                  onPressed: () {
                    setState(() => _isDismissed = true);
                    if (widget.onDismiss != null) widget.onDismiss!();
                  },
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

  Color _getSeverityColor(CDSSSeverity severity) {
    switch (severity) {
      case CDSSSeverity.low:
        return Colors.green;
      case CDSSSeverity.medium:
        return Colors.orange;
      case CDSSSeverity.high:
        return Colors.deepOrange;
      case CDSSSeverity.critical:
        return Colors.red;
    }
  }

  IconData _getSeverityIcon(CDSSSeverity severity) {
    switch (severity) {
      case CDSSSeverity.low:
        return Icons.info_outline;
      case CDSSSeverity.medium:
        return Icons.notification_important;
      case CDSSSeverity.high:
        return Icons.warning_amber;
      case CDSSSeverity.critical:
        return Icons.error_outline;
    }
  }

  String _getSeverityLabel(CDSSSeverity severity) {
    switch (severity) {
      case CDSSSeverity.low:
        return 'Information';
      case CDSSSeverity.medium:
        return 'Alerte';
      case CDSSSeverity.high:
        return 'Urgent';
      case CDSSSeverity.critical:
        return 'Critique';
    }
  }
}
