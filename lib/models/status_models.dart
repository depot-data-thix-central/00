// lib/models/status_models.dart
class UserStatus {
  final String userId;
  final String status; // 'online', 'away', 'busy', 'offline'
  final String? customStatus;
  final DateTime lastSeen;

  UserStatus({
    required this.userId,
    required this.status,
    this.customStatus,
    required this.lastSeen,
  });

  String get displayStatus {
    if (status == 'online') return 'En ligne';
    if (customStatus != null) return customStatus!;
    if (status == 'away') return 'Absent';
    if (status == 'busy') return 'Occupé';
    return 'Hors ligne';
  }

  Color get statusColor {
    switch (status) {
      case 'online': return Colors.green;
      case 'away': return Colors.orange;
      case 'busy': return Colors.red;
      default: return Colors.grey;
    }
  }
}

class StatusPreset {
  final String id;
  final String text;
  final String emoji;
  final String color;

  StatusPreset({
    required this.id,
    required this.text,
    required this.emoji,
    required this.color,
  });
}
