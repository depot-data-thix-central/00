// 📁 lib/models/thix_sante/hospital/consultation_model.dart

class ConsultationModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final DateTime date;
  final String motif;
  final String diagnostic;
  final String? traitement;
  final Map<String, dynamic>? vitalSigns;
  final List<Map<String, dynamic>>? prescriptions;
  final List<Map<String, dynamic>>? examOrders;
  final String status; // pending, completed, cancelled
  final DateTime createdAt;
  final DateTime updatedAt;

  ConsultationModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.motif,
    required this.diagnostic,
    this.traitement,
    this.vitalSigns,
    this.prescriptions,
    this.examOrders,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConsultationModel.fromJson(Map<String, dynamic> json) {
    return ConsultationModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      patientName: json['patient_name'] ?? '',
      doctorId: json['doctor_id'] ?? '',
      doctorName: json['doctor_name'] ?? '',
      date: DateTime.parse(json['date']),
      motif: json['motif'] ?? '',
      diagnostic: json['diagnostic'] ?? '',
      traitement: json['traitement'],
      vitalSigns: json['vital_signs'] != null ? Map<String, dynamic>.from(json['vital_signs']) : null,
      prescriptions: json['prescriptions'] != null ? List<Map<String, dynamic>>.from(json['prescriptions']) : null,
      examOrders: json['exam_orders'] != null ? List<Map<String, dynamic>>.from(json['exam_orders']) : null,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'date': date.toIso8601String(),
      'motif': motif,
      'diagnostic': diagnostic,
      'traitement': traitement,
      'vital_signs': vitalSigns,
      'prescriptions': prescriptions,
      'exam_orders': examOrders,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
