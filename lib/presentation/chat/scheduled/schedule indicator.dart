// lib/presentation/chat/scheduled/schedule_indicator.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleIndicator extends StatelessWidget {
  final DateTime scheduledAt;
  final bool isRecurring;
  final String? recurringPattern;

  const ScheduleIndicator({
    super.key,
    required this.scheduledAt,
    this.isRecurring = false,
    this.recurringPattern,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRecurring ? Icons.repeat : Icons.schedule,
            size: 10,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 2),
          Text(
            _getLabel(),
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _getLabel() {
    if (isRecurring) {
      switch (recurringPattern) {
        case 'daily': return 'Quotidien';
        case 'weekly': return 'Hebdomadaire';
        case 'monthly': return 'Mensuel';
        default: return 'Récurrent';
      }
    }
    return DateFormat('dd/MM HH:mm').format(scheduledAt);
  }
}
