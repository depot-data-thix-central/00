// 📁 lib/models/thix_sante/hospital/staff_model.dart

class StaffModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role; // Médecin, Infirmier, Secrétaire, etc.
  final String specialty;
  final String? service;
  final String? registrationNumber;
  final String status; // active, inactive
  final DateTime createdAt;
  final DateTime updatedAt;

  StaffModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.specialty,
    this.service,
    this.registrationNumber,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      role: json['role'] ?? '',
      specialty: json['specialty'] ?? '',
      service: json['service'],
      registrationNumber: json['registration_number'],
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
      'role': role,
      'specialty': specialty,
      'service': service,
      'registration_number': registrationNumber,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  StaffModel copyWith({String? status, String? service}) {
    return StaffModel(
      id: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      role: role,
      specialty: specialty,
      service: service ?? this.service,
      registrationNumber: registrationNumber,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
