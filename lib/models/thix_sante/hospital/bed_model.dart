// 📁 lib/models/thix_sante/hospital/bed_model.dart

class BedModel {
  final String id;
  final String number;
  final String? service;
  final String? roomNumber;
  final String? ward;
  final String status; // available, occupied, cleaning, reserved
  final String? patientId;
  final String? patientName;
  final DateTime createdAt;
  final DateTime updatedAt;

  BedModel({
    required this.id,
    required this.number,
    this.service,
    this.roomNumber,
    this.ward,
    required this.status,
    this.patientId,
    this.patientName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BedModel.fromJson(Map<String, dynamic> json) {
    return BedModel(
      id: json['id'] ?? '',
      number: json['number'] ?? '',
      service: json['service'],
      roomNumber: json['room_number'],
      ward: json['ward'],
      status: json['status'] ?? 'available',
      patientId: json['patient_id'],
      patientName: json['patient_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'service': service,
      'room_number': roomNumber,
      'ward': ward,
      'status': status,
      'patient_id': patientId,
      'patient_name': patientName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  BedModel copyWith({
    String? status,
    String? patientId,
    String? patientName,
  }) {
    return BedModel(
      id: id,
      number: number,
      service: service,
      roomNumber: roomNumber,
      ward: ward,
      status: status ?? this.status,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
