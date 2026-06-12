// lib/presentation/chat/location/location_bubble.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/location_models.dart';
import 'live_location_viewer.dart';

class LocationBubble extends StatelessWidget {
  final LiveLocation location;
  final bool isFromMe;

  const LocationBubble({
    super.key,
    required this.location,
    required this.isFromMe,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = location.expiresAt.isBefore(DateTime.now());

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder: (_, __) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: LiveLocationViewer(locationId: location.id),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isFromMe
              ? const Color(0xFFD4AF37).withOpacity(0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFromMe
                ? const Color(0xFFD4AF37).withOpacity(0.3)
                : Colors.grey[200]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: isExpired ? Colors.grey : const Color(0xFFD4AF37),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    isExpired ? 'Position expirée' : 'Position en direct',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isExpired ? Colors.grey : const Color(0xFFD4AF37),
                    ),
                  ),
                ),
                if (!isExpired)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              location.address ?? 'Position partagée',
              style: TextStyle(
                fontSize: 11,
                color: isExpired ? Colors.grey : Colors.black87,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(location.sharedAt),
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Il y a ${diff.inHours} h';
    return DateFormat('dd/MM/yy').format(date);
  }
}
