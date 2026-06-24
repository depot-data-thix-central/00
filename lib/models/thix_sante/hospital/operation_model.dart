// 📁 lib/models/thix_sante/hospital/operation_model.dart

class OperationModel {
  final String id;
  final String patientId;
  final String patientName;
  final String surgeonId;
  final String surgeonName;
  final String type;
  final String room;
  final DateTime scheduledDate;
  final String status; // scheduled, in_progress, completed, cancelled
  final String? preopChecklist;
  final String? postopReport;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  OperationModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.surgeonId,
    required this.surgeonName,
    required this.type,
    required this.room,
    required this.scheduledDate,
    required this.status,
    this.preopChecklist,
    this.postopReport,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OperationModel.fromJson(Map<String, dynamic> json) {
    return OperationModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      patientName: json['patient_name'] ?? '',
      surgeonId: json['surgeon_id'] ?? '',
      surgeonName: json['surgeon_name'] ?? '',
      type: json['type'] ?? '',
      room: json['room'] ?? '',
      scheduledDate: DateTime.parse(json['scheduled_date']),
      status: json['status'] ?? 'scheduled',
      preopChecklist: json['preop_checklist'],
      postopReport: json['postop_report'],
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
      'surgeon_id': surgeonId,
      'surgeon_name': surgeonName,
      'type': type,
      'room': room,
      'scheduled_date': scheduledDate.toIso8601String(),
      'status': status,
      'preop_checklist': preopChecklist,
      'postop_report': postopReport,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  OperationModel copyWith({String? status, String? postopReport}) {
    return OperationModel(
      id: id,
      patientId: patientId,
      patientName: patientName,
      surgeonId: surgeonId,
      surgeonName: surgeonName,
      type: type,
      room: room,
      scheduledDate: scheduledDate,
      status: status ?? this.status,
      preopChecklist: preopChecklist,
      postopReport: postopReport ?? this.postopReport,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
