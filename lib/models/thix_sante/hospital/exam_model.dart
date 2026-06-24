// 📁 lib/models/thix_sante/hospital/exam_model.dart

class ExamModel {
  final String id;
  final String patientId;
  final String patientName;
  final String? doctorId;
  final String? doctorName;
  final String type;
  final String priority; // normal, urgent, très urgent
  final DateTime date;
  final String status; // pending, in_progress, completed, cancelled
  final String? result;
  final String? referenceRange;
  final bool? isAbnormal;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExamModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.doctorId,
    this.doctorName,
    required this.type,
    required this.priority,
    required this.date,
    required this.status,
    this.result,
    this.referenceRange,
    this.isAbnormal,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      patientName: json['patient_name'] ?? '',
      doctorId: json['doctor_id'],
      doctorName: json['doctor_name'],
      type: json['type'] ?? '',
      priority: json['priority'] ?? 'normal',
      date: DateTime.parse(json['date']),
      status: json['status'] ?? 'pending',
      result: json['result'],
      referenceRange: json['reference_range'],
      isAbnormal: json['is_abnormal'],
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
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'type': type,
      'priority': priority,
      'date': date.toIso8601String(),
      'status': status,
      'result': result,
      'reference_range': referenceRange,
      'is_abnormal': isAbnormal,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ExamModel copyWith({
    String? status,
    String? result,
    bool? isAbnormal,
  }) {
    return ExamModel(
      id: id,
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      type: type,
      priority: priority,
      date: date,
      status: status ?? this.status,
      result: result ?? this.result,
      referenceRange: referenceRange,
      isAbnormal: isAbnormal ?? this.isAbnormal,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
