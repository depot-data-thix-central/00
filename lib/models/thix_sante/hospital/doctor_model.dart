// 📁 lib/models/thix_sante/hospital/doctor_model.dart

class DoctorModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String specialty;
  final String? rppsNumber; // Numéro RPPS
  final String? hospitalId;
  final List<String>? services; // Services associés
  final String status; // active, inactive, pending
  final DateTime createdAt;
  final DateTime updatedAt;

  DoctorModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.specialty,
    this.rppsNumber,
    this.hospitalId,
    this.services,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      specialty: json['specialty'] ?? '',
      rppsNumber: json['rpps_number'],
      hospitalId: json['hospital_id'],
      services: json['services'] != null ? List<String>.from(json['services']) : [],
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'specialty': specialty,
      'rpps_number': rppsNumber,
      'hospital_id': hospitalId,
      'services': services,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DoctorModel copyWith({
    String? status,
    String? hospitalId,
  }) {
    return DoctorModel(
      id: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      specialty: specialty,
      rppsNumber: rppsNumber,
      hospitalId: hospitalId ?? this.hospitalId,
      services: services,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
