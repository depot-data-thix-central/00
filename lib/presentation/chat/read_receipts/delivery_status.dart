// lib/presentation/chat/read_receipts/delivery_status.dart
import 'package:flutter/material.dart';

class DeliveryStatus extends StatelessWidget {
  final bool isSent;
  final bool isDelivered;
  final bool isRead;
  final DateTime? deliveredAt;
  final DateTime? readAt;

  const DeliveryStatus({
    super.key,
    required this.isSent,
    required this.isDelivered,
    required this.isRead,
    this.deliveredAt,
    this.readAt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Envoyé
        Icon(
          Icons.check,
          size: 12,
          color: isSent ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 2),
        // Livré
        Icon(
          Icons.check,
          size: 12,
          color: isDelivered ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 2),
        // Lu
        if (isRead)
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 6, color: Colors.white),
          ),
        if (deliveredAt != null)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              _formatTime(deliveredAt!),
              style: const TextStyle(fontSize: 8, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
