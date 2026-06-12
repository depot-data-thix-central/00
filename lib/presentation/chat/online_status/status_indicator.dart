// lib/presentation/chat/online_status/status_indicator.dart
import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final String status;
  final double size;
  final bool showBorder;

  const StatusIndicator({
    super.key,
    required this.status,
    this.size = 12,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        shape: BoxShape.circle,
        border: showBorder ? Border.all(color: Colors.white, width: 1.5) : null,
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case 'online':
        return Colors.green;
      case 'away':
        return Colors.orange;
      case 'busy':
        return Colors.red;
      case 'offline':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  final String? customStatus;
  final double size;

  const StatusBadge({
    super.key,
    required this.status,
    this.customStatus,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: size,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: size - 2,
            backgroundImage: const NetworkImage('https://via.placeholder.com/50'),
          ),
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: StatusIndicator(status: status, size: size - 4),
        ),
      ],
    );
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  final String? customStatus;
  final VoidCallback? onTap;

  const StatusChip({
    super.key,
    required this.status,
    this.customStatus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusIndicator(status: status, size: 8),
            const SizedBox(width: 4),
            Text(
              customStatus ?? _getStatusLabel(),
              style: TextStyle(
                fontSize: 10,
                color: _getStatusColor(),
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 14, color: _getStatusColor()),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel() {
    switch (status) {
      case 'online': return 'En ligne';
      case 'away': return 'Absent';
      case 'busy': return 'Occupé';
      case 'offline': return 'Hors ligne';
      default: return 'En ligne';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case 'online': return Colors.green;
      case 'away': return Colors.orange;
      case 'busy': return Colors.red;
      case 'offline': return Colors.grey;
      default: return Colors.green;
    }
  }
}
