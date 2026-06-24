// 📁 lib/models/thix_sante/hospital/consent_model.dart

class ConsentModel {
  final String id;
  final String patientId;
  final String patientName;
  final String type; // Médical, Recherche, Traitement de données
  final DateTime date;
  final String status; // active, pending, expired, revoked
  final String duration;
  final bool isDataProcessingAccepted;
  final bool isDataSharingAccepted;
  final bool isThirdPartyAccepted;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConsentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.type,
    required this.date,
    required this.status,
    required this.duration,
    required this.isDataProcessingAccepted,
    required this.isDataSharingAccepted,
    required this.isThirdPartyAccepted,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConsentModel.fromJson(Map<String, dynamic> json) {
    return ConsentModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      patientName: json['patient_name'] ?? '',
      type: json['type'] ?? 'Médical',
      date: DateTime.parse(json['date']),
      status: json['status'] ?? 'active',
      duration: json['duration'] ?? '1 an',
      isDataProcessingAccepted: json['is_data_processing_accepted'] ?? false,
      isDataSharingAccepted: json['is_data_sharing_accepted'] ?? false,
      isThirdPartyAccepted: json['is_third_party_accepted'] ?? false,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'type': type,
      'date': date.toIso8601String(),
      'status': status,
      'duration': duration,
      'is_data_processing_accepted': isDataProcessingAccepted,
      'is_data_sharing_accepted': isDataSharingAccepted,
      'is_third_party_accepted': isThirdPartyAccepted,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
