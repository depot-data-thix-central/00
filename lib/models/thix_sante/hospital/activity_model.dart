// 📁 lib/models/thix_sante/hospital/activity_model.dart

class ActivityModel {
  final String id;
  final String title;
  final String subtitle;
  final String type; // admission, consultation, prescription, exam, surgery, discharge
  final DateTime timestamp;
  final String? patientId;
  final String? patientName;
  final String? userId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  ActivityModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.timestamp,
    this.patientId,
    this.patientName,
    this.userId,
    this.metadata,
    required this.createdAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      type: json['type'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      patientId: json['patient_id'],
      patientName: json['patient_name'],
      userId: json['user_id'],
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'patient_id': patientId,
      'patient_name': patientName,
      'user_id': userId,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper pour obtenir le temps écoulé
  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) return 'À l\'instant';
    if (difference.inMinutes < 60) return 'Il y a ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'Il y a ${difference.inHours} h';
    return 'Il y a ${difference.inDays} j';
  }
}
