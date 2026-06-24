// 📁 lib/models/thix_sante/hospital/prescription_model.dart

class PrescriptionModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final List<PrescriptionItem> items;
  final String status; // pending, validated, sent, completed
  final DateTime date;
  final String? doctorNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PrescriptionModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.items,
    required this.status,
    required this.date,
    this.doctorNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      patientName: json['patient_name'] ?? '',
      doctorId: json['doctor_id'] ?? '',
      doctorName: json['doctor_name'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List).map((i) => PrescriptionItem.fromJson(i)).toList()
          : [],
      status: json['status'] ?? 'pending',
      date: DateTime.parse(json['date']),
      doctorNotes: json['doctor_notes'],
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
      'items': items.map((i) => i.toJson()).toList(),
      'status': status,
      'date': date.toIso8601String(),
      'doctor_notes': doctorNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PrescriptionModel copyWith({String? status}) {
    return PrescriptionModel(
      id: id,
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      items: items,
      status: status ?? this.status,
      date: date,
      doctorNotes: doctorNotes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class PrescriptionItem {
  final String name;
  final String dosage;
  final String frequency;
  final String? duration;
  final String? instructions;
  final int quantity;

  PrescriptionItem({
    required this.name,
    required this.dosage,
    required this.frequency,
    this.duration,
    this.instructions,
    required this.quantity,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) {
    return PrescriptionItem(
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'],
      instructions: json['instructions'],
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
      'quantity': quantity,
    };
  }
}
